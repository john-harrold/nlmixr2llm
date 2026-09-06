# List the nlmixr2-universe packages covered by this package

Packages are covered through the task skills (see \[list_tasks()\]);
this helper reports which packages the bundled content addresses,
optionally restricted to a subset of tasks.

## Usage

``` r
list_packages(tasks = NULL)
```

## Arguments

- tasks:

  Character vector of tasks (from \[list_tasks()\]) to restrict the
  result to. Defaults to all tasks.

## Value

Character vector of package names.

## Examples

``` r
list_packages()
#>  [1] "babelmixr2"    "ggPMX"         "monolix2rx"    "nlmixr2"      
#>  [5] "nlmixr2est"    "nlmixr2extra"  "nlmixr2lib"    "nlmixr2plot"  
#>  [9] "nlmixr2rpt"    "nonmem2rx"     "rxode2"        "shinyMixR"    
#> [13] "xpose.nlmixr2"
list_packages(tasks = "interop")
#> [1] "babelmixr2" "monolix2rx" "nonmem2rx" 
```
