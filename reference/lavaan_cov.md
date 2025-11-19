# Extract relevant covariance/correlation indices from lavaan model

Extract relevant covariance/correlation indices from lavaan
[lavaan::parameterEstimates](https://rdrr.io/pkg/lavaan/man/parameterEstimates.html)
and
[lavaan::standardizedsolution](https://rdrr.io/pkg/lavaan/man/standardizedSolution.html).

## Usage

``` r
lavaan_cov(fit, nice_table = FALSE, ...)

lavaan_cor(fit, nice_table = FALSE, ...)
```

## Arguments

- fit:

  lavaan fit object to extract covariance indices from

- nice_table:

  Logical, whether to print the table as a
  [rempsyc::nice_table](https://rempsyc.remi-theriault.com/reference/nice_table.html)
  as well as print the reference values at the bottom of the table.

- ...:

  Arguments to be passed to
  [rempsyc::nice_table](https://rempsyc.remi-theriault.com/reference/nice_table.html)

## Value

A dataframe of covariances/correlation, including the covaried
variables, the covariance/correlation, and corresponding p-value.

## Functions

- `lavaan_cor()`: Shortcut for `lavaan_cov(fit, estimate = "r")`

## Examples

``` r
x <- paste0("x", 1:9)
(latent <- list(
  visual = x[1:3],
  textual = x[4:6],
  speed = x[7:9]
))
#> $visual
#> [1] "x1" "x2" "x3"
#> 
#> $textual
#> [1] "x4" "x5" "x6"
#> 
#> $speed
#> [1] "x7" "x8" "x9"
#> 

(regression <- list(
  ageyr = c("visual", "textual", "speed"),
  grade = c("visual", "textual", "speed")
))
#> $ageyr
#> [1] "visual"  "textual" "speed"  
#> 
#> $grade
#> [1] "visual"  "textual" "speed"  
#> 

(covariance <- list(speed = "textual", ageyr = "grade"))
#> $speed
#> [1] "textual"
#> 
#> $ageyr
#> [1] "grade"
#> 

HS.model <- write_lavaan(
  regression = regression, covariance = covariance,
  latent = latent, label = TRUE
)
cat(HS.model)
#> ##################################################
#> # [-----Latent variables (measurement model)-----]
#> 
#> visual =~ x1 + x2 + x3
#> textual =~ x4 + x5 + x6
#> speed =~ x7 + x8 + x9
#> 
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> ageyr ~ visual + textual + speed
#> grade ~ visual + textual + speed
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
#> 

library(lavaan)
fit <- sem(HS.model, data = HolzingerSwineford1939)
lavaan_cov(fit)
#>    Variable 1 Variable 2         SE        Z            p     sigma   CI_lower
#> 16    textual      speed 0.05102682 3.411223 6.467214e-04 0.1740639 0.07405313
#> 17      ageyr      grade 0.03077116 7.488490 6.972201e-14 0.2304295 0.17011916
#> 32     visual    textual 0.07430296 5.572306 2.513899e-08 0.4140388 0.26840769
#> 33     visual      speed 0.05710260 4.545270 5.486495e-06 0.2595467 0.14762767
#>     CI_upper         r CI_lower_r CI_upper_r
#> 16 0.2740746 0.2679391  0.1331814  0.4026968
#> 17 0.2907399 0.5332236  0.4471455  0.6193016
#> 32 0.5596700 0.4583362  0.3334309  0.5832415
#> 33 0.3714657 0.4384508  0.2944977  0.5824039
```
