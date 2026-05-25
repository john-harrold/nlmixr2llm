# Read an agent's markdown content

Read an agent's markdown content

## Usage

``` r
get_agent(agent = "nlmixr2verse")
```

## Arguments

- agent:

  One of \[list_agents()\]. Defaults to the single combined
  \`"nlmixr2verse"\` agent.

## Value

A length-one character string with the full markdown content, including
YAML frontmatter.

## Examples

``` r
cat(substr(get_agent(), 1, 200))
#> ---
#> name: nlmixr2verse
#> description: Specialist for the whole nlmixr2 pharmacometric modeling ecosystem in R. Use for any task involving rxode2 (author/simulate ODE-based PK/PD models), nlmixr2 (fit po
```
