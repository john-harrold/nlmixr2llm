# Read a skill's markdown content

Read a skill's markdown content

## Usage

``` r
get_skill(package)
```

## Arguments

- package:

  One of \[list_skills()\].

## Value

A length-one character string with the full SKILL.md content, including
YAML frontmatter.

## Examples

``` r
cat(substr(get_skill("rxode2"), 1, 200))
#> ---
#> name: rxode2
#> description: Use this skill when the user is creating, editing, or running ODE-based pharmacometric models with the R package rxode2. Triggers include writing PK/PD models with `ini({
```
