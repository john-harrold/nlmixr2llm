---
name: nonmem2rx
description: Use this skill when the user wants to convert a NONMEM control stream + output into an rxode2 / nlmixr2 model object for simulation, VPC, or sharing in an open-source workflow. Triggers include calls to `nonmem2rx()`, references to `.ctl`/`.mod`/`.lst`/`.xml`/`.phi` files, "translate this NONMEM run", or "qualify a NONMEM model in R".
---

# nonmem2rx — NONMEM → rxode2 conversion

`nonmem2rx` reads a NONMEM control stream together with its run outputs and produces an rxode2 UI object that contains the model, the final estimates, the ETA table, and per-row predictions. The result can be solved like any other rxode2 model and (optionally) promoted to an `nlmixr2` fit-like object.

## When to use this skill

Activate whenever the user is:

- Converting a finished NONMEM run into rxode2/nlmixr2 for simulation or VPC.
- Validating ("qualifying") a NONMEM model by reproducing PRED/IPRED in rxode2.
- Pulling THETA / OMEGA / ETAs out of a NONMEM listing into R.
- Setting up a babelmixr2 workflow whose NONMEM step needs to be read back.

## Minimum viable example

```r
library(nonmem2rx)

# Pass the listing file (.res or .lst) directly — ctl is found alongside it
resFile <- system.file("mods/cpt/runODE032.res", package = "nonmem2rx")
mod <- nonmem2rx(resFile, validate = TRUE, save = FALSE)

mod                                   # rxode2 UI object with NONMEM estimates baked in
cat(deparse(as.function(mod)), sep="\n")  # see the generated rxode2 model body
plot(mod)                             # built-in qualification plot
plot(mod, page = 1, log = "y")        # log-scale page

mod$nonmemData    # NONMEM table output as a data.frame
mod$etaData       # per-ID empirical Bayes ETAs
mod$ini           # parameter table (THETA + variability)
mod$props$pop     # names of population (THETA) parameters
```

The returned object **is** an rxode2 UI, so anything that works on an rxode2 model works here: `rxSolve(mod, ev)`, `plot()`, `nlmixr2est::vpcSim()`, etc.

## Authoring rules

1. **Inputs.** `nonmem2rx()` accepts either the control stream (`.ctl`/`.mod`) or the listing file (`.lst`/`.res`) as its first argument and finds the rest alongside. The XML output, `.phi`, and the input dataset should also live in the same directory. If passing a control stream and the listing has a non-default extension, use `lst="..."` to point at it.
2. **`validate = TRUE`.** Pass this on the conversion call to run rxode2-vs-NONMEM qualification automatically and populate the `$ipredCompare` / `$predCompare` slots. Make this the default in any script you write.
3. **`save=`.** Defaults to `FALSE`. Set `save = TRUE` to cache the parsed object as an `.rds` next to the source — useful for big runs you'll re-load.
4. **Returned object is rxode2 UI, not a fit.** Treat it like a model. To see the generated rxode2 model body: `cat(deparse(as.function(mod)), sep="\n")`. To get nlmixr2-style post-processing (residuals, VPCs against the original data) convert it via the conversion vignette workflow rather than calling `nlmixr2()` again from scratch.
5. **Useful slots on the result:**
   - `$nonmemData` — NONMEM table merged with the dataset
   - `$etaData` — per-ID empirical Bayes ETAs (great for resampling-based sims)
   - `$ini` — parameter table (THETA + variability), tidy data.frame form
   - `$props$pop` — names of population (THETA) parameters
   - `$thetaMat` — variance/covariance of fixed effects (for uncertainty sims)
   - `$predData`, `$ipredData` — NONMEM PRED/IPRED
   - `$ipredCompare`, `$predCompare`, `$iwresCompare` — rxode2-vs-NONMEM diffs
6. **Qualification first.** Before doing *anything* downstream (sim, VPC, reporting), call `plot(mod)` (and `plot(mod, page=1, log="y")` for log-scale) and check `$ipredCompare` / `$predCompare`. If rxode2 and NONMEM disagree on IPRED, the translation has a problem and downstream results are not trustworthy.
7. **Simulating new dosing.** Build a fresh `et()` event table and call `rxSolve(mod, ev)` — same pattern as any rxode2 model. Use `thetaMat=` from the converted object to propagate parameter uncertainty.
8. **Resampling fitted subjects** (preferred over re-drawing from `omega` when you want to honor post-hoc ETAs):

   ```r
   # Build a per-subject parameter table from the fitted ETAs + THETAs
   sub_orig <- mod$ini |>
     dplyr::filter(name %in% mod$props$pop) |>
     dplyr::select(name, est) |>
     tidyr::pivot_wider(names_from = name, values_from = est) |>
     cbind(mod$etaData) |>
     dplyr::rename(id = ID)

   # Resample with replacement to a new sim size
   nSub   <- 200
   sub_sim <- sub_orig[sample(nrow(sub_orig), nSub, replace = TRUE), ] |>
     dplyr::mutate(id = seq_len(nSub))

   sim <- rxSolve(mod, params = sub_sim, events = ev)
   confint(sim, "ipred", level = 0.95) |> plot()
   ```

## Required files on disk (typical NONMEM run)

| File | Role |
|---|---|
| `run.ctl` / `run.mod` | control stream (passed to `nonmem2rx()`) |
| `run.lst` / `run.res` | listing — pointed at via `lst=` |
| `run.xml` | structured output (THETA/OMEGA/SE) |
| `run.phi` | per-ID ETAs in focei |
| dataset CSV | as referenced inside `$DATA` of the control stream |
| output tables | as referenced inside `$TABLE` of the control stream |

If any of these are missing, expect an error or a partially populated object — flag the missing piece to the user instead of silently continuing.

## Workflow

The skill is "done" only when the converted model has been **executed and qualified**, not just loaded:

1. Run `nonmem2rx(..., validate = TRUE)` and confirm the object prints without warnings.
2. Call `plot(mod)` and inspect `mod$ipredCompare`. The IPRED diff should be ~0 to working precision.
3. *Then* run whatever the user actually asked for — new-dose sim, VPC, augPred, etc.
4. Set `set.seed()` *and* `rxode2::rxSetSeed()` if the result needs to be reproducible across runs.
5. Report qualification status alongside results.

## Debugging quick reference

| Symptom | Likely cause |
|---|---|
| `cannot find lst file` | wrong `lst=` extension; check the actual filename |
| `dataset not found` | `$DATA` path is relative to the ctl directory — `setwd()` or pass an absolute path |
| `rounding errors` in listing | NONMEM run didn't fully converge; use the `read-rounding` vignette workflow before trusting estimates |
|  mismatch in `$ipredCompare` | unsupported NONMEM construct, or model uses an ADVAN/feature nonmem2rx doesn't translate cleanly — inspect the generated rxode2 model and reconcile by hand |
| Duplicate ETA / parameter names | known limitation — nonmem2rx will not auto-rename; fix in the source ctl |

## What NOT to do

- Don't trust the converted model without checking IPRED qualification.
- Don't rebuild the NONMEM model from scratch in rxode2 by hand "to be safe" — that defeats the qualification story. Use the converted object and only patch what the diff shows is broken.
- Don't promise nlmixr2 fit semantics from a bare `nonmem2rx()` call — it returns an rxode2 UI, not a fit object.

## In-repo references

- `vignettes/import-nonmem.Rmd` — basic conversion walkthrough
- `vignettes/articles/convert-nlmixr2.Rmd` — promoting to an nlmixr2 fit-like object
- `vignettes/articles/rxode2-validate.Rmd` — qualification / IPRED comparison workflow
- `vignettes/articles/simulate-new-dosing.Rmd`, `simulate-uncertainty.Rmd`, `simulate-extra-items.Rmd`, `simulate-with-covs.Rmd` — downstream simulation patterns
- `vignettes/articles/create-vpc.Rmd`, `create-augPred.Rmd`, `create-office.Rmd` — reporting
- `vignettes/articles/read-rounding.Rmd` — handling NONMEM rounding errors

## Relationship to babelmixr2

`babelmixr2` uses `nonmem2rx` to read NONMEM results back when you fit a model with `est = "nonmem"`. If a babelmixr2 NONMEM fit looks wrong, the translation problem is usually in nonmem2rx — debug it by loading the same `.ctl` directly with `nonmem2rx()` and inspecting `$ipredCompare`.
