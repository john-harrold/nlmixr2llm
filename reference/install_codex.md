# Install agents and skills as an AGENTS.md file for OpenAI Codex CLI

Concatenates the requested content into a single \`AGENTS.md\` and
writes it to the location Codex CLI reads from. Codex CLI loads
\`\$CODEX_HOME/AGENTS.md\` (default \`~/.codex/AGENTS.md\`) globally,
and \`AGENTS.md\` files walked from the git root toward the current
working directory.

## Usage

``` r
install_codex(
  scope = c("user", "project"),
  packages = NULL,
  path = ".",
  mode = c("write", "append", "error"),
  include = c("both", "agents", "skills")
)
```

## Arguments

- scope:

  \`"user"\` writes to \`~/.codex/AGENTS.md\`; \`"project"\` writes to
  \`\<path\>/AGENTS.md\`. The user-scope base is \`\$CODEX_HOME\` if
  set, otherwise the home directory returned by
  \`getOption("nlmixr2llm.home")\` (defaulting to \`~\`); set
  \`options(nlmixr2llm.home = tempdir())\` to redirect user-scope writes
  away from the real home (used by the package's tests).

- packages:

  Character vector of nlmixr2-universe packages to include. Defaults to
  all available packages.

- path:

  Project root when \`scope = "project"\`. Defaults to the current
  working directory.

- mode:

  How to handle an existing file: \* \`"write"\` (default) – overwrite
  if present \* \`"append"\` – append a clearly delimited section to the
  existing file \* \`"error"\` – fail if the file exists

- include:

  Which content to include: \`"both"\` (default), \`"agents"\`, or
  \`"skills"\`.

## Value

Invisibly, the path written.

## Details

Codex has a default limit of ~32 KiB for combined AGENTS.md content
(\`project_doc_max_bytes\`); a warning is issued if the written file
exceeds that size.

For \`scope = "user"\` (which writes under your home directory) the
function asks for confirmation in interactive sessions before writing.
Non-interactive callers proceed without prompting; set
\`options(nlmixr2llm.consent = TRUE)\` to pre-approve.

## Note

On case-insensitive filesystems (macOS, Windows) the project-scope
\`AGENTS.md\` and Positron's \`agents.md\` (see \[install_positron()\]
with \`style = "agents_md"\`) are the \*\*same file\*\*, so installing
both into one project means the second call overwrites the first. With
default arguments the instruction content is identical, so this is
harmless; if you pass different \`packages\`/\`include\` to each, only
the last call's selection survives.

## Examples

``` r
if (FALSE) { # \dontrun{
install_codex(scope = "project", packages = c("rxode2", "nlmixr2"))
install_codex(scope = "user", mode = "append")
} # }
```
