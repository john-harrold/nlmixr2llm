# Build a combined system prompt for use with any LLM client

Concatenates the combined \`nlmixr2verse\` agent and the per-package
skill content into a single character string suitable for use as a
system prompt with \`ellmer\`, the Anthropic SDK, the OpenAI SDK, or any
other LLM client. YAML frontmatter is stripped so the result is plain
markdown.

## Usage

``` r
system_prompt(packages = NULL, include = c("both", "agents", "skills"))
```

## Arguments

- packages:

  Character vector of nlmixr2-universe packages whose skills to include.
  Defaults to all available packages (see \[list_packages()\]).

- include:

  Which content to include: \`"both"\` (default), \`"agents"\`, or
  \`"skills"\`.

## Value

A length-one character string.

## Details

There is a single ecosystem-wide agent (\`nlmixr2verse\`) rather than
one per package, so when agents are requested it is always included in
full regardless of \`packages\`; \`packages\` only subsets the skills.

## See also

\[list_packages()\], \[get_agent()\], \[get_skill()\]

## Examples

``` r
prompt <- system_prompt(packages = "rxode2")
nchar(prompt)
#> [1] 37288
```
