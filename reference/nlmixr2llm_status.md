# Report whether installed coding-agent content is up to date

Compares the agent and skill content this version of \`nlmixr2llm\`
bundles against the copies previously installed into each supported
coding-agent target, so you can tell when an upgrade of the package
ships newer agents or skills than the files those tools are currently
loading. The installers write \*\*independent copies\*\*, so they do not
change when the package is upgraded until you re-install.

## Usage

``` r
nlmixr2llm_status(path = ".", quiet = FALSE)
```

## Arguments

- path:

  Project root used for project-scoped targets. Defaults to the current
  working directory. User-scoped targets (\`~/.claude\`, \`~/.codex\`)
  are always checked at their fixed locations.

- quiet:

  If \`TRUE\`, suppress the printed summary and only return the data
  frame.

## Value

Invisibly, a data frame with columns \`target\`, \`location\`, \`item\`,
\`status\`, and \`refresh\` (the command that would refresh that
target).

## Details

Targets checked: \* \*\*Claude Code\*\* (\`~/.claude/\` user scope and
\`\<path\>/.claude/\` project scope) – discrete agent/skill files,
compared by content. \* \*\*Codex / \`AGENTS.md\`\*\*
(\`~/.codex/AGENTS.md\` and \`\<path\>/AGENTS.md\`, the latter shared
with \[install_agents_md()\]). \* \*\*Positron\*\* \`agents.md\`
(\`\<path\>/agents.md\`) and per-package \`\*.instructions.md\` files
(\`\<path\>/.github/instructions/\`).

Concatenated single-file targets carry an embedded version stamp, so
they are compared by the package version recorded at install time;
Claude Code files are compared by content. Each file is classified
\`"current"\`, \`"outdated"\`, or \`"not installed"\`. Only targets that
actually have installed content are mentioned in the printed summary.

When the package is attached interactively, it runs this check
automatically (read-only) and prints a one-line notice if any installed
copy is out of date. Disable that startup check with
\`options(nlmixr2llm.startup_check = FALSE)\`.

## See also

\[install_claude_code()\], \[install_codex()\], \[install_positron()\]

## Examples

``` r
if (FALSE) { # \dontrun{
nlmixr2llm_status()
} # }
```
