# Install agents and skills as a project-root AGENTS.md

Writes a single \`AGENTS.md\` at the project root in the format defined
by the cross-tool agents.md specification (\`https://agents.md\`). The
file is read by many tools that follow that convention, including OpenAI
Codex CLI, Cursor, Aider, GitHub Copilot, Zed, Warp, Jules, and Devin.

## Usage

``` r
install_agents_md(
  path = ".",
  tasks = NULL,
  mode = c("write", "append", "error"),
  include = c("both", "agents", "skills"),
  references = FALSE
)
```

## Arguments

- path:

  Project root. Defaults to the current working directory.

- tasks:

  Character vector of tasks whose skills to include. Defaults to all
  available tasks (see \[list_tasks()\]).

- mode:

  How to handle an existing file: \`"write"\` (default), \`"append"\`,
  or \`"error"\`.

- include:

  Which content to include: \`"both"\` (default), \`"agents"\`, or
  \`"skills"\`.

- references:

  If \`TRUE\`, also include each skill's supporting reference files (see
  \[list_skill_files()\]). Defaults to \`FALSE\`.

## Value

Invisibly, the path written.

## Details

For Codex-specific installation that also supports the user-level
\`~/.codex/AGENTS.md\` location and warns about the Codex byte cap, see
\[install_codex()\]. For Claude Code's separate skill/agent tree, see
\[install_claude_code()\].

## Examples

``` r
if (FALSE) { # \dontrun{
install_agents_md(path = ".", tasks = c("simulation", "estimation"))
} # }
```
