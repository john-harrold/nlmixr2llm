# Using nlmixr2llm with different LLM clients and IDEs

`nlmixr2llm` ships LLM-facing documentation for the nlmixr2
pharmacometric modeling ecosystem: `rxode2`, `nlmixr2`, `nonmem2rx`,
`monolix2rx`, and `babelmixr2`. It bundles a single combined
`nlmixr2verse` agent (the orchestration layer spanning all five
packages) plus one skill per package for on-demand depth. The same
content can be used three ways:

1.  **As a system prompt** with any LLM client library (the
    [`ellmer`](https://ellmer.tidyverse.org) R package, the Anthropic
    SDK, the OpenAI SDK, etc.).
2.  **As tool-native files** installed into Claude Code, OpenAI Codex
    CLI, Positron Assistant, or any tool that reads
    [`AGENTS.md`](https://agents.md).
3.  **As a Claude Code plugin** for users who prefer the plugin
    marketplace path and don’t want to touch R.

This vignette walks through each path.

``` r

library(nlmixr2llm)
```

## Discovering what’s available

``` r

list_packages()
#> [1] "babelmixr2" "monolix2rx" "nlmixr2"    "nonmem2rx"  "rxode2"
list_agents()
#> [1] "nlmixr2verse"
list_skills()
#> [1] "babelmixr2" "monolix2rx" "nlmixr2"    "nonmem2rx"  "rxode2"
```

[`list_agents()`](https://john-harrold.github.io/nlmixr2llm/reference/list_agents.md)
returns the single combined `nlmixr2verse` agent;
[`list_packages()`](https://john-harrold.github.io/nlmixr2llm/reference/list_packages.md)
and
[`list_skills()`](https://john-harrold.github.io/nlmixr2llm/reference/list_skills.md)
enumerate the five packages whose skills provide per-package depth. You
can read any single document directly:

``` r

agent_text <- get_agent()        # the combined nlmixr2verse agent
substr(agent_text, 1, 200)
#> [1] "---\nname: nlmixr2verse\ndescription: Specialist for the whole nlmixr2 pharmacometric modeling ecosystem in R. Use for any task involving rxode2 (author/simulate ODE-based PK/PD models), nlmixr2 (fit po"

skill_text <- get_skill("rxode2")
substr(skill_text, 1, 200)
#> [1] "---\nname: rxode2\ndescription: Use this skill when the user is creating, editing, or running ODE-based pharmacometric models with the R package rxode2. Triggers include writing PK/PD models with `ini({"
```

## 1. Use as a system prompt with any LLM client

[`system_prompt()`](https://john-harrold.github.io/nlmixr2llm/reference/system_prompt.md)
returns a single character string with the agent and skill content
concatenated and YAML frontmatter stripped. Pass it as the system prompt
to whichever client you use.

``` r

prompt <- system_prompt(packages = c("rxode2", "nlmixr2"))
nchar(prompt)
#> [1] 45047
```

By default
[`system_prompt()`](https://john-harrold.github.io/nlmixr2llm/reference/system_prompt.md)
includes both agents and skills for all packages. Subset with
`packages = ...` or `include = c("agents", "skills")`.

### With `ellmer` (Anthropic, OpenAI, Gemini, Ollama, …)

`ellmer` is the recommended path for R users — it abstracts over
multiple LLM providers and is the same client Positron Assistant is
built on.

``` r

library(ellmer)

chat <- chat_anthropic(
  system_prompt = system_prompt(packages = c("rxode2", "nlmixr2")),
  model = "claude-sonnet-4-6"
)

chat$chat(
  "Write a one-compartment PK model with first-order absorption ",
  "in rxode2, then simulate a single 100 mg dose for 24 hours."
)
```

The same prompt works with any `ellmer` backend (`chat_openai()`,
`chat_google_gemini()`, `chat_ollama()`, …).

### With the Anthropic SDK directly (e.g., via `httr2`)

``` r

req <- httr2::request("https://api.anthropic.com/v1/messages") |>
  httr2::req_headers(
    "x-api-key" = Sys.getenv("ANTHROPIC_API_KEY"),
    "anthropic-version" = "2023-06-01"
  ) |>
  httr2::req_body_json(list(
    model = "claude-sonnet-4-6",
    max_tokens = 1024,
    system = system_prompt(packages = "rxode2"),
    messages = list(list(role = "user", content = "..."))
  ))
```

### With the OpenAI SDK directly

Same pattern — pass
[`system_prompt()`](https://john-harrold.github.io/nlmixr2llm/reference/system_prompt.md)
as the `system` (or `instructions`) field.

## 2. Install for specific coding environments

Each installer writes the bundled content into the location its target
tool reads from. None of these clobber existing files unless you ask:
pass `overwrite = TRUE` (Claude Code, Positron) or
`mode = "write"`/`"append"` (Codex, AGENTS.md) to control behavior.

### Claude Code (Anthropic CLI / IDE extensions)

Claude Code looks for agents at `~/.claude/agents/<name>.md` and skills
at `~/.claude/skills/<name>/SKILL.md` (user scope), or under
`./.claude/` at the project root (project scope).

``` r

# User-wide — every Claude Code session sees these
install_claude_code(scope = "user")

# Project-local — only when Claude Code runs in this project
install_claude_code(scope = "project", path = ".")

# Selective install
install_claude_code(scope = "user", packages = c("rxode2", "nlmixr2"))

# Replace existing files
install_claude_code(scope = "user", overwrite = TRUE)
```

### OpenAI Codex CLI

Codex reads `~/.codex/AGENTS.md` globally and `AGENTS.md` files at and
above the current working directory in a project. The installer
concatenates the requested content into a single `AGENTS.md` and writes
it to either location.

``` r

# Project AGENTS.md at the repo root
install_codex(scope = "project", path = ".",
              packages = c("rxode2", "nlmixr2"))

# Global ~/.codex/AGENTS.md (append rather than overwrite)
install_codex(scope = "user", mode = "append")
```

Codex enforces a default 32 KiB cap on combined `AGENTS.md` content
(`project_doc_max_bytes` in `~/.codex/config.toml`). The full corpus
(~62 KiB) is larger than that. The combined `nlmixr2verse` agent is ~29
KiB and is always included whole when agents are requested, so
`packages = ...` only subsets the skills. For Codex you’ll typically
want to subset:

``` r

# Just the combined agent (~29 KiB, high-signal), not the long skill files
install_codex(scope = "project", include = "agents")

# Or just the skills for the packages you're actually using
install_codex(scope = "project", include = "skills",
              packages = c("rxode2", "nlmixr2"))
```

[`install_codex()`](https://john-harrold.github.io/nlmixr2llm/reference/install_codex.md)
warns when the written file exceeds 32 KiB so you know to subset or
raise Codex’s cap.

### Positron Assistant

Positron Assistant auto-discovers instruction files in the workspace
root. The package supports two styles:

**`style = "agents_md"` (default)** writes a single `agents.md` at the
workspace root. Positron picks it up, and the same file is the
cross-tool [`AGENTS.md`](https://agents.md) convention used by Codex,
Cursor, Aider, Zed, and others — so one file covers many tools at once.

``` r

install_positron(workspace = ".", style = "agents_md")
```

> **Note — `AGENTS.md` vs `agents.md` on case-insensitive filesystems.**
> On macOS and Windows, `agents.md` (this Positron style) and
> `AGENTS.md` (`install_codex(scope = "project")` /
> [`install_agents_md()`](https://john-harrold.github.io/nlmixr2llm/reference/install_agents_md.md))
> are the *same file*. Installing both into one project means the second
> call overwrites the first. With default arguments the instruction body
> is identical so this is harmless; if you give each a different
> `packages`/`include`, only the last call’s selection survives. On
> case-sensitive filesystems (most Linux) they are distinct files.
> [`nlmixr2llm_status()`](https://john-harrold.github.io/nlmixr2llm/reference/nlmixr2llm_status.md)
> collapses them into a single reported entry when they resolve to the
> same file.

**`style = "instructions"`** writes one
`.github/instructions/<package>.instructions.md` per selected package
(skill content), plus a single `nlmixr2verse.instructions.md` (the
combined ecosystem agent), each with `applyTo: "**/*.R"` in its
frontmatter. Positron attaches the relevant content when the model is
editing R files. This is the more selective option: the LLM only sees
this guidance when actually working on R code.

``` r

install_positron(
  workspace = ".",
  style = "instructions",
  packages = c("rxode2", "nlmixr2")
)
```

Positron does not currently document a user-level (cross-workspace)
instructions location. To get user-wide coverage, call
[`install_positron()`](https://john-harrold.github.io/nlmixr2llm/reference/install_positron.md)
from a project template or a setup hook.

### Cursor, Aider, GitHub Copilot, Zed, Warp, …

Any tool that follows the [`agents.md`](https://agents.md) spec reads a
project-root `AGENTS.md`. Use the generic installer:

``` r

install_agents_md(path = ".", packages = c("rxode2", "nlmixr2"))
```

This is a thin wrapper around `install_codex(scope = "project")` since
the file format is the same.

## 3. Install as a Claude Code plugin (no R required)

The plugin manifest in `.claude-plugin/` at the repo root points at the
same `inst/agents/` and `inst/skills/` content the R package ships, so
the GitHub repo also functions as a Claude Code plugin marketplace.
Users who don’t want to install the R package can do:

``` text
/plugin marketplace add john-harrold/nlmixr2llm
/plugin install nlmixr2llm@nlmixr2llm
```

The plugin and the R-package installer write the same content into the
same location, so either path works.

## Choosing a path

| You want to … | Use |
|----|----|
| Call an LLM from R code (e.g., in a script or app) | [`system_prompt()`](https://john-harrold.github.io/nlmixr2llm/reference/system_prompt.md) + `ellmer` |
| Always have nlmixr2 guidance in Claude Code | `install_claude_code(scope = "user")` |
| Add nlmixr2 guidance to one Codex project | `install_codex(scope = "project")` |
| Add nlmixr2 guidance to one Positron workspace | [`install_positron()`](https://john-harrold.github.io/nlmixr2llm/reference/install_positron.md) |
| Cover Cursor / Aider / Zed / Copilot / Codex in one file | [`install_agents_md()`](https://john-harrold.github.io/nlmixr2llm/reference/install_agents_md.md) |
| Use Claude Code without touching R | `/plugin install nlmixr2llm@nlmixr2llm` |

## Keeping content in sync

Upgrading the `nlmixr2llm` R package updates the content bundled *in
your R library*, but the installers write **independent copies** into
each tool’s location — those copies don’t change until you re-run the
installer. After an upgrade, re-run it for whichever environment you
use. Installers don’t overwrite by default, so pass `overwrite = TRUE`
(or `mode = "write"`) to refresh existing files.

To make that safe to do blindly,
[`install_claude_code()`](https://john-harrold.github.io/nlmixr2llm/reference/install_claude_code.md)
and
[`install_positron()`](https://john-harrold.github.io/nlmixr2llm/reference/install_positron.md)
compare each existing file against the current bundled content and tell
you which are stale. With `overwrite = FALSE` you’ll see, per file,
`up to date` or `out of date (overwrite = TRUE to refresh)`, and the
summary line reports how many are out of date — so a no-op re-install
still tells you whether an update is waiting.

``` r

install_claude_code(scope = "user", overwrite = TRUE)
install_codex(scope = "user", mode = "write")
install_positron(workspace = ".", overwrite = TRUE)
```

### Pruning files the package no longer ships

[`install_claude_code()`](https://john-harrold.github.io/nlmixr2llm/reference/install_claude_code.md)
and `install_positron(style = "instructions")` record what they wrote in
a manifest (`.nlmixr2llm-manifest`) in the install location. On
re-install they **prune** files this package installed in an earlier
version but no longer ships — for example, if an agent is renamed or a
package is dropped, the stale file is removed rather than left behind as
a duplicate. Pruning is on by default (`prune = TRUE`) and only ever
touches files nlmixr2llm itself created; your own agents and skills are
never removed. Selecting a subset with `packages = ...` does not prune
the skills of packages you leave out — only content the current version
no longer ships at all is removed.

``` r

# Full sync: refresh existing files and drop any the package no longer ships
install_claude_code(scope = "user", overwrite = TRUE, prune = TRUE)

# Keep stale files in place if you've customized them
install_claude_code(scope = "user", overwrite = TRUE, prune = FALSE)
```

The single-file installers
([`install_codex()`](https://john-harrold.github.io/nlmixr2llm/reference/install_codex.md),
[`install_agents_md()`](https://john-harrold.github.io/nlmixr2llm/reference/install_agents_md.md),
and `install_positron(style = "agents_md")`) always write one fixed-name
file, so there is nothing to orphan and no manifest is used.

### Checking what’s current without reinstalling

[`nlmixr2llm_status()`](https://john-harrold.github.io/nlmixr2llm/reference/nlmixr2llm_status.md)
compares the content this version of the package bundles against the
copies installed into **every** target — Claude Code (user and project
scope), Codex / `AGENTS.md`, and both Positron styles — and reports
which files are `current`, `outdated`, or `not installed`, along with
the refresh command for each stale target.

``` r

nlmixr2llm_status()
```

Claude Code files are discrete, so they’re compared by content; the
concatenated single-file targets (Codex `AGENTS.md`, Positron
`agents.md`, and the Positron `*.instructions.md` files) carry an
embedded version stamp and are compared by the package version recorded
at install time. Only targets that actually have installed content
appear in the summary.

The `nlmixr2verse` agent runs this check itself, once per session, and
proactively tells you when the installed content lags the package — so
after you upgrade `nlmixr2llm`, the agent will let you know there’s a
newer version to install rather than silently running stale guidance.
