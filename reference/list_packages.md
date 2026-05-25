# List the nlmixr2-universe packages covered by this package

Each covered package ships a skill
(\`inst/skills/\<package\>/SKILL.md\`). The ecosystem is also covered by
a single combined agent, \`nlmixr2verse\` (see \[list_agents()\]), which
is not itself a package and is therefore not listed here.

## Usage

``` r
list_packages()
```

## Value

Character vector of package names with skill content shipped by
\`nlmixr2llm\`.

## Examples

``` r
list_packages()
#> [1] "babelmixr2" "monolix2rx" "nlmixr2"    "nonmem2rx"  "rxode2"    
```
