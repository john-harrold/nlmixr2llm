# List available agents

The ecosystem is covered by a single combined agent, \`nlmixr2verse\`,
that routes work across the tasks in \[list_tasks()\]. Per-task depth
lives in the skills (see \[list_skills()\]); the agent is the
orchestration layer.

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
