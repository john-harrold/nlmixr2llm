Whenever changes or updates are made, remember to update documentation
(function examples, vignettes, etc).

After any documentation change (roxygen comments, vignettes, README, or the
agent/skill content), rebuild the generated docs so the rendered site stays in
sync:

- Regenerate man pages from roxygen: `Rscript -e 'roxygen2::roxygenise()'`
- Rebuild the pkgdown site: `Rscript -e 'pkgdown::build_site(preview = FALSE)'`
  (or, for a smaller diff, `pkgdown::build_article("<name>")` and/or
  `pkgdown::build_reference()` for just the changed pages).


After updating agents or skills you should do the following:
 - Spawn an agent to review the code in the agents and skills. Use fable as the model running the review. Please check against current sources.
 - Once that's done: Generate tests to test all of the code examples in the agents and skills (where possible).
   The harness lives in `tests/testthat/test-examples.R` + `helper-examples.R`; it runs every fenced
   R block against a shared fixture and fails on unexpected warnings. Run it with
   `NLMIXR2LLM_RUN_EXAMPLES=true Rscript -e 'testthat::test_local(filter = "examples")'`
   (several minutes; needs the nlmixr2 stack installed). New snippets must either use the fixture
   objects (`fit`, `mod`, `ev`, `data`, `obnd`, `rptdetails`, `nSub`, `dose`) or define what they use;
   add blocks that cannot run here to `example_skips` with a reason. CI runs the same harness in
   `.github/workflows/skill-examples.yaml` (weekly + on content changes); the modeling packages are
   installed there via `extra-packages`, not declared in DESCRIPTION.