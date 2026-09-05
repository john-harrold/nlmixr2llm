# nlmixr2rpt — Word and PowerPoint reports from an nlmixr2 fit

`nlmixr2rpt` appends figures and tables for a fit to an `onbrand` report object. `onbrand` is a templating layer over `officer`, so the same call produces Word or PowerPoint depending on which template you opened. `read_template()`, `save_report()`, and `template_details()` are onbrand functions; `report_fit()`, `gen_pest_table()`, `yaml_read_fit()`, `build_figures()`, `build_tables()`, and `fetch_fit_example()` are nlmixr2rpt's.

## Workflow

```r
library(nlmixr2rpt)
library(onbrand)

# 1. Open a template (bundled defaults shown; swap in your organisation's)
obnd_docx <- read_template(
  template = system.file("templates", "nlmixr_obnd_template.docx", package = "nlmixr2rpt"),
  mapping  = system.file("templates", "nlmixr_obnd_template.yaml", package = "nlmixr2rpt"))
obnd_pptx <- read_template(
  template = system.file("templates", "nlmixr_obnd_template.pptx", package = "nlmixr2rpt"),
  mapping  = system.file("templates", "nlmixr_obnd_template.yaml", package = "nlmixr2rpt"))

# 2. Append the fit (repeat for several fits; add other onbrand/officer content freely)
obnd_docx <- report_fit(obnd = obnd_docx, fit = fit,
                        cat_covars = c("SEX"), cont_covars = c("WT"))
obnd_pptx <- report_fit(obnd = obnd_pptx, fit = fit)

# 3. Save
save_report(obnd_docx, "report.docx")
save_report(obnd_pptx, "report.pptx")
```

`report_fit()` arguments: `obnd`, `fit`, `rptyaml` (report definition; defaults to the package's `report_fit.yaml`), `placeholders`, `cat_covars`, `cont_covars`, `parameters` (runtime overrides of the YAML sections), `verbose`.

`fetch_fit_example()` returns a stored example fit for trying the pipeline.

## Customising the report: `report_fit.yaml`

```r
file.copy(system.file("templates", "report_fit.yaml", package = "nlmixr2rpt"), "my_report.yaml")
obnd <- report_fit(obnd = obnd, fit = fit, rptyaml = "my_report.yaml")
```

Sections of the YAML:

| Section | Purpose |
|---|---|
| `placeholders` | `===KEY===` tokens substituted in captions, titles, axis labels; values may be R code (`OBJ: sprintf("%3g", fit$objf)`) |
| `parameters` | Display names per model parameter, `md:` for Word/PowerPoint (markdown, e.g. `"CL~int~ (L/hr)"`) and `txt:` for plain text; overrides `label()` in the model |
| `covariates` | `cat:` and `cont:` vectors used by figure / table code |
| `options` | `output_dir`, `resolution`, `figenv_preamble` / `tabenv_preamble` (libraries and helper code loaded before building), `fig_stamp` |
| `figures` | One entry per figure ID: `orientation`, `caption`, `caption_format` (`text` / `md`), `title` (slide title), `notes`, and `cmd` — R code that must create `p_res` |
| `tables` | One entry per table ID with the same fields; `cmd` must create `t_res`, a list with `df` (data frames) and/or `ft` (flextables) and optional `notes` |
| `pptx` | Slide master / placeholder names for figures and tables, figure `width` / `height` in inches, and `content:` — ordered list of `- figure: id` / `- table: id` |
| `docx` | Figure dimensions per orientation and `content:` — ordered list mixing `- text: {text:, style:}`, `- figure: id`, `- table: id` |

Objects available inside `cmd` code: `fit`, `xpdb` (xpose data built in the default preamble), `obnd`, `rptdetails`, `rpttype` (`"Word"` / `"PowerPoint"`), `cat_covars`, `cont_covars`, `output_dir`, `width`, `height`, `resolution`, `fid` / `tid`.

Set `p_res <- NA` or `t_res <- NA` inside `cmd` to skip an element conditionally without a build error.

Default figures (IDs in the shipped `report_fit.yaml`): `dv_vs_pred_ipred`, `res_vs_pred_idv` (CWRES; skipped when absent), `ind_plots`, `prm_vs_iteration` (xpose-based), and `eta_matrix`, `eta_cont`, `eta_cat` (ggPMX-based; the covariate ones are skipped when no covariates are given), plus `skip_figure` as a template for conditional skipping. Default tables: `pest_table` via `gen_pest_table()`, and `skip_table`. Confirm with `names(rptdetails$figures)`.

## Using the elements outside a document

```r
rptdetails <- yaml_read_fit(obnd = obnd, rptyaml = "my_report.yaml", fit = fit)$rptdetails
figs <- build_figures(obnd = obnd, fit = fit, rptdetails = rptdetails)
tabs <- build_tables(obnd = obnd, fit = fit, rptdetails = rptdetails)

names(figs$rptfigs)                            # figure IDs that were built
figs$rptfigs$dv_vs_pred_ipred$figure[[1]]      # path to the PNG
figs$rptfigs$dv_vs_pred_ipred$title_proc       # processed title
tabs$rpttabs$pest_table$table$ft[[1]]    # flextable of parameter estimates
```

This is the route for R Markdown / Quarto: include the PNG paths and flextables directly.

## Parameter table on its own

```r
pt <- gen_pest_table(fit = fit, obnd = obnd, rptdetails = rptdetails)
pt$ft[[1]]      # flextable
pt$df[[1]]      # data frame
```

## Organisational templates

Create Word / PowerPoint templates with the required `onbrand` styles / slide masters and a mapping YAML (see the `onbrand` vignettes). `onbrand::template_details(obnd)` lists what the bundled templates define so you can match them. Pass your template and mapping to `read_template()`; everything else stays the same.

## Pitfalls

- Figure `cmd` code must create `p_res` (ggplot, paginated ggforce object, `ggpubr::ggarrange()` result, `GGally::ggmatrix`, or a vector of image file paths); table `cmd` must create `t_res`.
- Libraries used inside `cmd` must be loaded in `figenv_preamble` / `tabenv_preamble`.
- Parameter names in `parameters:` must match the `ini({})` names exactly.
- PowerPoint figures are generated at the placeholder dimensions — set `width` / `height` in the `pptx` section to match your master.
- Word tables span pages automatically; split into multiple `df` / `ft` list elements only if you want a caption per page.
