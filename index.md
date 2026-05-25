# nlmixr2llm

LLM-facing documentation for the [nlmixr2](https://nlmixr2.org/)
pharmacometric modeling ecosystem in R, distributed as an R package and
as a Claude Code plugin.

The same content — a single combined `nlmixr2verse` agent plus
per-package skill files for `rxode2`, `nlmixr2`, `nonmem2rx`,
`monolix2rx`, and `babelmixr2` — is shipped two ways:

- **As an R package**, with accessor functions for use as a system
  prompt with any LLM client (`ellmer`, the Anthropic SDK, the OpenAI
  SDK, …) and installers that write the files into the locations
  expected by Claude Code, OpenAI Codex CLI, Positron Assistant, and
  other tools that follow the [`AGENTS.md`](https://agents.md)
  convention.
- **As a Claude Code plugin** via the `.claude-plugin/` directory at the
  repo root, so users who already use the Claude Code plugin marketplace
  can install without touching R.

## Coverage

A single combined **`nlmixr2verse`** agent spans the whole ecosystem
(the orchestration layer), and each package ships a **skill** for
on-demand depth:

| Package | Skill | Purpose |
|----|----|----|
| [`rxode2`](https://github.com/nlmixr2/rxode2) | ✓ | ODE-based PK/PD modeling and simulation |
| [`nlmixr2`](https://github.com/nlmixr2/nlmixr2) | ✓ | Population PK/PD parameter estimation (SAEM, FOCEi, …) |
| [`nonmem2rx`](https://github.com/nlmixr2/nonmem2rx) | ✓ | Convert finished NONMEM runs into rxode2 / nlmixr2 objects |
| [`monolix2rx`](https://github.com/nlmixr2/monolix2rx) | ✓ | Convert Monolix projects into rxode2 / nlmixr2 objects |
| [`babelmixr2`](https://github.com/nlmixr2/babelmixr2) | ✓ | Fit nlmixr2 models via NONMEM, Monolix, or PKNCA backends |

The `nlmixr2verse` agent covers all five packages and the end-to-end
workflow that connects them (author in rxode2 → fit in nlmixr2 → run on
other engines with babelmixr2 → import legacy runs with nonmem2rx /
monolix2rx).

## Install (R package)

``` r

# install.packages("remotes")
remotes::install_github("john-harrold/nlmixr2llm")
```

## Usage

### Use as a system prompt with any LLM client

``` r

library(nlmixr2llm)

prompt <- system_prompt(packages = c("rxode2", "nlmixr2"))

# Example: with ellmer
chat <- ellmer::chat_anthropic(system_prompt = prompt)
chat$chat("Write a one-compartment PK model with first-order absorption in rxode2.")
```

### Install into Claude Code

``` r

# User-level (~/.claude/agents/, ~/.claude/skills/)
install_claude_code(scope = "user")

# Or project-local (.claude/agents/, .claude/skills/) under the current project
install_claude_code(scope = "project")
```

### Install into OpenAI Codex CLI

``` r

# Project AGENTS.md at the repo root
install_codex(scope = "project", packages = c("rxode2", "nlmixr2"))

# Global ~/.codex/AGENTS.md
install_codex(scope = "user", mode = "append")
```

Codex enforces a default 32 KiB cap on combined `AGENTS.md` content. The
full corpus (~62 KiB) exceeds that. The combined `nlmixr2verse` agent is
~29 KiB on its own and is included whole whenever agents are requested,
so `packages = ...` only subsets the skills. For Codex, install
`include = "agents"` (just the agent, ~29 KiB) or `include = "skills"`
with a `packages = ...` subset.

### Install into Positron Assistant

``` r

# Project-root agents.md (also picked up by Codex, Cursor, Aider, Zed, ...)
install_positron(workspace = ".", style = "agents_md")

# Per-package .github/instructions/*.instructions.md with applyTo: "**/*.R"
install_positron(workspace = ".", style = "instructions")
```

### Install for any tool that reads `AGENTS.md`

``` r

install_agents_md(path = ".", packages = c("rxode2", "nlmixr2"))
```

Covered by the [`agents.md`](https://agents.md) cross-tool spec: Codex,
Cursor, Aider, GitHub Copilot, Zed, Warp, Jules, Devin, and others.

### Keeping installs in sync

The installers write independent copies, so re-run them after upgrading
the package (pass `overwrite = TRUE` / `mode = "write"` to refresh
existing files).
[`install_claude_code()`](https://john-harrold.github.io/nlmixr2llm/reference/install_claude_code.md)
and `install_positron(style = "instructions")` keep a manifest
(`.nlmixr2llm-manifest`) and, by default (`prune = TRUE`), remove files
they installed in an earlier version but no longer ship — so a renamed
agent or dropped package doesn’t leave an orphan behind. Only files
nlmixr2llm created are ever removed.

To check whether your installed content is current without reinstalling,
run
[`nlmixr2llm_status()`](https://john-harrold.github.io/nlmixr2llm/reference/nlmixr2llm_status.md)
— it inspects every install target (Claude Code user/project, Codex /
`AGENTS.md`, and both Positron styles), reports any files that are out
of date, and prints the refresh command for each. The `nlmixr2verse`
agent also runs this check itself once per session and tells you when a
refresh is available.

When you load the package interactively
([`library(nlmixr2llm)`](https://github.com/john-harrold/nlmixr2llm)),
it runs this check automatically (read-only) and prints a one-line
notice if any installed copy is out of date — staying silent otherwise.
Disable it with `options(nlmixr2llm.startup_check = FALSE)`.

## Use as a Claude Code plugin (no R required)

The bundled plugin manifest lives in `.claude-plugin/` at the repo root
(pointing at the same `inst/agents/` and `inst/skills/` content the R
package uses) so the repo doubles as a plugin source:

``` text
/plugin marketplace add john-harrold/nlmixr2llm
/plugin install nlmixr2llm@nlmixr2llm
```

## API

| Function | Purpose |
|----|----|
| [`list_packages()`](https://john-harrold.github.io/nlmixr2llm/reference/list_packages.md), [`list_agents()`](https://john-harrold.github.io/nlmixr2llm/reference/list_agents.md), [`list_skills()`](https://john-harrold.github.io/nlmixr2llm/reference/list_skills.md) | Discovery |
| [`get_agent()`](https://john-harrold.github.io/nlmixr2llm/reference/get_agent.md), `get_skill(pkg)` | Raw markdown ([`get_agent()`](https://john-harrold.github.io/nlmixr2llm/reference/get_agent.md) returns the combined `nlmixr2verse` agent) |
| `system_prompt(packages, include)` | Combined prompt for LLM clients |
| `install_claude_code(scope, packages, ...)` | Claude Code skill/agent tree |
| `install_codex(scope, packages, mode, include)` | Codex CLI `AGENTS.md` |
| `install_agents_md(path, packages, ...)` | Project-root `AGENTS.md` for any `agents.md`-aware tool |
| `install_positron(workspace, style, packages, ...)` | Positron Assistant instructions |
| `nlmixr2llm_status(path)` | Report whether installed files (Claude Code, Codex, Positron) are out of date vs the package |

## Layout

    nlmixr2llm/
    ├── DESCRIPTION
    ├── NAMESPACE
    ├── LICENSE
    ├── R/
    │   ├── content.R
    │   ├── claude_code.R
    │   ├── codex.R
    │   ├── agents_md.R
    │   └── positron.R
    ├── man/
    ├── .claude-plugin/        # Claude Code plugin manifest (not shipped in R tarball)
    └── inst/
        ├── agents/
        └── skills/

## Contributing

The skill and agent files are plain Markdown with YAML frontmatter —
edit them in `inst/agents/` and `inst/skills/`. Vignette references
point at filenames in each package’s source repo
(`github.com/nlmixr2/<pkg>/tree/main/vignettes/`); please verify any new
references against the live repo before merging.

## License

BSD 3-Clause. See
[LICENSE](https://john-harrold.github.io/nlmixr2llm/LICENSE).
