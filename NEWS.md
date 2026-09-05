# nlmixr2llm 0.2.0

## Task-oriented content

* Skills are now organized around **tasks** instead of individual packages:
  `simulation`, `estimation`, `reporting`, and `interop` (NONMEM / Monolix /
  PKNCA). The per-package skills (`rxode2`, `nlmixr2`, `babelmixr2`,
  `nonmem2rx`, `monolix2rx`) are gone; their content lives in the task skills.
* New `reporting` skill covers goodness-of-fit diagnostics, VPCs, parameter
  tables, and Word / PowerPoint reports (nlmixr2plot, xpose.nlmixr2, ggPMX,
  nlmixr2rpt, shinyMixR) -- content that had no home before.
* Skills may carry supporting `references/*.md` files for depth (e.g.
  `interop/references/nonmem.md`). `install_claude_code()` copies them with
  the skill; `system_prompt()` and the single-file installers include them
  when `references = TRUE`.
* The `nlmixr2verse` agent is now a compact orchestration layer (ecosystem map
  by task, routing, shared conventions, stage handoffs, self-check) at roughly
  a quarter of its previous size. The agent plus up to three skills fits under
  Codex's 32 KiB `AGENTS.md` cap.
* Event-table examples use `et(time = ...)` for sampling times; the unnamed
  form (`ev |> et(0:24)`) errors when piped in current rxode2.

## Verification

* Every fenced R code block in the agent and skills is now executed by an
  opt-in test (`tests/testthat/test-examples.R`) against a real SAEM fit, the
  bundled nonmem2rx / monolix2rx examples, and the nlmixr2rpt templates.
  Unexpected warnings fail the block (rxode2 only warns when a dose targets a
  compartment the model does not have). Run with
  `NLMIXR2LLM_RUN_EXAMPLES=true`; blocks that need NONMEM or Monolix are
  skipped. A dedicated GitHub Actions job (`skill-examples.yaml`) runs them
  weekly and on content changes against current CRAN releases.
* Content was reviewed against the installed packages and the upstream
  repositories. Fixes include the multi-endpoint residual syntax
  (`| endpoint`, a bare name, not `| dvid("name")`), the default nlmixr2rpt
  figure IDs, ggPMX's VPC being disabled for nlmixr2 fits, monolix2rx argument
  semantics and result-file layout, `nonmem2rx(save=)` writing `.qs`, and the
  behaviour of SAEM fits whose OFV is computed lazily.

## API changes (breaking)

* The `packages =` argument of `system_prompt()`, `install_claude_code()`,
  `install_codex()`, `install_agents_md()`, and `install_positron()` is
  replaced by `tasks =`. Passing a package name errors with the list of valid
  tasks.
* `get_skill()` takes a task name.
* New: `list_tasks()`, `list_skill_files()`, and a `references` argument on
  `system_prompt()` and the single-file installers.
* `list_packages()` now reports the packages the task skills cover and accepts
  `tasks =` to subset; `list_skills()` returns task names.
* Re-running `install_claude_code()` / `install_positron(style =
  "instructions")` after upgrading prunes the old per-package files
  automatically (manifest-tracked).

# nlmixr2llm 0.1.0

* Initial version.
* Ships a single combined `nlmixr2verse` agent spanning the nlmixr2
  pharmacometrics ecosystem (`rxode2`, `nlmixr2`, `nonmem2rx`, `monolix2rx`,
  `babelmixr2`), plus one skill per package.
* Accessor functions: `list_packages()`, `list_agents()`, `list_skills()`,
  `get_agent()`, `get_skill()`, and `system_prompt()` for use as a system
  prompt with any LLM client.
* Installer functions write the content into the locations expected by Claude
  Code (`install_claude_code()`), OpenAI Codex CLI (`install_codex()`),
  Positron Assistant (`install_positron()`), and any tool that reads
  `AGENTS.md` (`install_agents_md()`). Multi-file installers track what they
  write in a manifest and can prune content the package no longer ships.
* `nlmixr2llm_status()` reports whether the content installed into each target
  is up to date with the package.
