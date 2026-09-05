# Population simulation patterns

Two ways to populate a simulation with subjects. Pick deliberately.

## A. Re-draw new subjects from `omega`

Standard for "what would a new population look like". Requires the model to carry between-subject variability (`eta.cl ~ 0.1` in `ini({})`), or an explicit `omega=` matrix.

```r
set.seed(5446); rxode2::rxSetSeed(5446)

sim <- rxSolve(mod, ev, nSub = 500)
confint(sim, "cp", level = 0.9) |> plot()
```

Add residual error draws with `sigma=` (or a `~ add()/prop()` line in the model) when simulating *observations* rather than true concentrations.

## B. Resample fitted subjects (post-hoc ETAs)

Preferred when the sim should honor the individuals that were actually fitted — e.g. simulating a new regimen in the same population, or when covariates must stay paired with their ETAs. Works the same for an nlmixr2 fit and an imported NONMEM (`nonmem2rx`) model.

From an nlmixr2 fit (`mod` is the fitted model, e.g. `fit$ui`; the model has `depot` and `cp`):

```r
sub_orig <- fit$etaObf |>                       # per-ID ETAs (plus an OBJI column, ignored)
  dplyr::rename(id = ID)
theta    <- fit$theta                           # population parameters (named vector)
sub_orig <- cbind(sub_orig, as.list(theta))     # THETAs as columns

# Resample with replacement to the desired size, renumber ids
nSub    <- 200
sub_sim <- sub_orig[sample(nrow(sub_orig), nSub, replace = TRUE), ] |>
  dplyr::mutate(id = seq_len(nSub))

ev  <- et(amt = 100, addl = 6, ii = 24, cmt = "depot") |> et(time = 0:168) |> et(id = 1:nSub)
sim <- rxSolve(mod, params = sub_sim, events = ev)
confint(sim, "cp", level = 0.95) |> plot()
```

From a nonmem2rx object. The compartment and output names come from the NONMEM model, so look them up first (`mod$state`, and the model body via `cat(deparse(as.function(mod)), sep = "\n")`) rather than assuming `depot` / `cp`; the bundled example has states `CENTRAL` / `PERI` and an `ipred` output:

```r
sub_orig <- mod$ini |>
  dplyr::filter(name %in% mod$props$pop) |>
  dplyr::select(name, est) |>
  tidyr::pivot_wider(names_from = name, values_from = est) |>
  cbind(mod$etaData) |>
  dplyr::rename(id = ID)

nSub    <- 200
sub_sim <- sub_orig[sample(nrow(sub_orig), nSub, replace = TRUE), ] |>
  dplyr::mutate(id = seq_len(nSub))

mod$state                                        # compartment names to dose into
ev  <- et(amt = 100, addl = 6, ii = 24, cmt = "CENTRAL") |> et(time = 0:168) |> et(id = 1:nSub)
sim <- rxSolve(mod, params = sub_sim, events = ev)
confint(sim, "ipred", level = 0.95) |> plot()
```

Rules:

- `params=` must have an `id` column matching the event table's ids, one row per subject.
- Columns named like model parameters / ETAs override the model's values; unknown columns are ignored, so covariates can ride along.
- Because ETAs are supplied, do **not** also pass `nSub` (that would re-draw them). rxode2 then warns `multi-subject simulation without 'omega'`; that is expected here.
- rxode2 only **warns** (`dose to compartment ... ignored`) when `cmt=` names a compartment the model does not have, and the simulation comes back all zeros. Read warnings.

## C. Parameter uncertainty across trials

```r
sim <- rxSolve(mod, ev, nSub = 100, nStud = 200,
               thetaMat = fit$cov,        # or mod$thetaMat from nonmem2rx
               dfSub = 120)               # optional: omega uncertainty (inverse-Wishart, df = subjects in the fit)
confint(sim, "cp", level = 0.95) |> plot()
```

`nStud` replicates the trial; each replicate draws population parameters from `thetaMat`. `dfSub` / `dfObs` add uncertainty in `omega` / `sigma`.

## D. Covariates

- **Non-time-varying**: columns in the `params=` data frame (one row per id).
- **Time-varying**: columns in the event table (`as.data.frame(ev) |> dplyr::left_join(cov_df, by = c("id", "time"))`), then `rxSolve(mod, events = ev_with_covs)`. rxode2 interpolates between rows (`covsInterpolation=` controls how).
- The model must reference the covariate by its column name exactly.

## E. Trial design loops

For dose-finding or scenario comparisons, build one event table per arm with distinct `id` ranges (or an `arm` column carried in `params=`), `etRbind()` them, solve once, and summarise by arm. Keep the seed fixed across arms so differences are due to the design, not the draws.

## Checks before reporting

- Number of subjects and studies in the output matches the request (`length(unique(sim$sim.id))`, `length(unique(sim$id))`).
- Concentrations are non-negative and finite; steady state reached when `ss = 1` or enough `addl`.
- The summary (median, 5th/95th percentiles) is computed on the right variable (`cp` vs `central`).
