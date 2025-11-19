# Extract relevant variance indices from lavaan model

Extract relevant variance indices from lavaan model through
[lavaan::parameterEstimates](https://rdrr.io/pkg/lavaan/man/parameterEstimates.html)
(when estimate = "sigma", `est` column)) or
[lavaan::standardizedsolution](https://rdrr.io/pkg/lavaan/man/standardizedSolution.html)
(when estimate = "r2", `est.std` column). R2 values are then calculated
as `1 - est.std`, and the new *p* values for the R2, with the following
formula: `stats::pnorm((1 - est) / se)`.

## Usage

``` r
lavaan_var(fit, estimate = "r2", nice_table = FALSE, ...)
```

## Arguments

- fit:

  lavaan fit object to extract covariance indices from

- estimate:

  What estimate to use, either the standardized estimate ("r2",
  default), or unstandardized estimate ("sigma2").

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
lavaan_var(fit)
#>    Variable   p    R2 CI_lower CI_upper
#> 18       x1   0 0.605    0.436    0.773
#> 19       x2   0 0.180    0.081    0.280
#> 20       x3   0 0.333    0.208    0.458
#> 21       x4   0 0.732    0.659    0.806
#> 22       x5   0 0.736    0.663    0.809
#> 23       x6   0 0.689    0.612    0.765
#> 24       x7   0 0.359    0.241    0.476
#> 25       x8   0 0.563    0.428    0.699
#> 26       x9   0 0.390    0.270    0.511
#> 27    ageyr   0 0.161    0.068    0.255
#> 28    grade   0 0.191    0.095    0.287
#> 29   visual NaN 0.000    0.000    0.000
#> 30  textual NaN 0.000    0.000    0.000
#> 31    speed   0 0.000    0.000    0.000
```
