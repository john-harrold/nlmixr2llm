# List available agents

The ecosystem is covered by a single combined agent, \`nlmixr2verse\`,
that spans all packages in \[list_packages()\] (rxode2, nlmixr2,
babelmixr2, nonmem2rx, monolix2rx). Per-package depth lives in the
skills (see \[list_skills()\]); the agent is the orchestration layer
over the whole ecosystem.

## Usage

``` r
list_agents()
```

## Value

Character vector of agent names (currently the single
\`"nlmixr2verse"\`).

## Examples

``` r
list_agents()
#> [1] "nlmixr2verse"
```
