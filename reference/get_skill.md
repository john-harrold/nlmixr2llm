# Read a skill's markdown content

Returns the \`SKILL.md\` for a task. Supporting reference files that
ship alongside it (see \[list_skill_files()\]) are not included; use
\[system_prompt()\] with \`references = TRUE\` to concatenate them.

## Usage

``` r
get_skill(task)
```

## Arguments

- task:

  One of \[list_tasks()\].

## Value

A length-one character string with the full SKILL.md content, including
YAML frontmatter.

## Examples

``` r
cat(substr(get_skill("simulation"), 1, 200))
#> ---
#> name: simulation
#> description: Use this skill when the user wants to simulate a pharmacokinetic or pharmacodynamic model in R with the nlmixr2 ecosystem — writing or editing an ODE model, building 
```
