# Install agents and skills for Positron Assistant

Positron Assistant auto-discovers project-scoped instruction files in
the workspace root (per
\`https://positron.posit.co/assistant-chat-instructions.html\`). Two
styles are supported:

## Usage

``` r
install_positron(
  workspace = ".",
  style = c("agents_md", "instructions"),
  packages = NULL,
  overwrite = FALSE,
  prune = TRUE,
  apply_to = "**/*.R"
)
```

## Arguments

- workspace:

  Workspace (project) root. Defaults to the current working directory.

- style:

  One of \`"agents_md"\` (default) or \`"instructions"\`.

- packages:

  Character vector of nlmixr2-universe packages to include. Defaults to
  all available packages.

- overwrite:

  If \`TRUE\`, replace existing files. If \`FALSE\` (default), existing
  files are kept and a message is shown.

- prune:

  If \`TRUE\` (default), \`style = "instructions"\` removes previously
  installed \`\*.instructions.md\` files that the current package
  version no longer ships, tracked via a manifest
  (\`.github/instructions/.nlmixr2llm-manifest\`). Only files nlmixr2llm
  created are removed. Ignored by \`style = "agents_md"\`, which writes
  a single fixed-name file with nothing to orphan.

- apply_to:

  Glob used in each \`\*.instructions.md\` frontmatter when \`style =
  "instructions"\`. Defaults to \`"\*\*/\*.R"\`.

## Value

Invisibly, a character vector of files written.

## Details

\* \`style = "agents_md"\` (default) – writes a single \`agents.md\` at
the workspace root. This is the file Positron looks for first, and it is
also the shared \`AGENTS.md\` convention used by Codex, Cursor, Aider,
Zed, and others, so this option gives broad coverage with one file. \*
\`style = "instructions"\` – writes one \`\<package\>.instructions.md\`
per selected package (skill content) plus a single
\`nlmixr2verse.instructions.md\` (the combined ecosystem agent) into
\`.github/instructions/\`, each with \`applyTo: "\*\*/\*.R"\` so
Positron Assistant attaches the content when editing R files.

Positron does not document a user-level (cross-workspace) instructions
location. To get user-wide coverage, set up a per-project hook (for
example, in a project template) that calls \`install_positron()\`.

## Note

On case-insensitive filesystems (macOS, Windows) the \`agents.md\` file
written by \`style = "agents_md"\` and Codex's \`AGENTS.md\` (see
\[install_codex()\] with \`scope = "project"\`) are the \*\*same
file\*\*, so installing both into one project means the second call
overwrites the first. With default arguments the instruction content is
identical, so this is harmless; if you pass different
\`packages\`/\`include\` to each, only the last call's selection
survives. The \`style = "instructions"\` files
(\`.github/instructions/\*.instructions.md\`) do not collide.

## Examples

``` r
if (FALSE) { # \dontrun{
install_positron(workspace = ".", style = "agents_md")
install_positron(workspace = ".", style = "instructions",
                 packages = c("rxode2", "nlmixr2"))
} # }
```
