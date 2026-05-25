# NA

Whenever changes or updates are made, remember to update documentation
(function examples, vignettes, etc).

After any documentation change (roxygen comments, vignettes, README, or
the agent/skill content), rebuild the generated docs so the rendered
site stays in sync:

- Regenerate man pages from roxygen:
  `Rscript -e 'roxygen2::roxygenise()'`
- Rebuild the pkgdown site:
  `Rscript -e 'pkgdown::build_site(preview = FALSE)'` (or, for a smaller
  diff, `pkgdown::build_article("<name>")` and/or
  [`pkgdown::build_reference()`](https://pkgdown.r-lib.org/reference/build_reference.html)
  for just the changed pages).
