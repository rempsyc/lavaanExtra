# Extract relevant regression indices from lavaan model

Extract relevant regression indices from lavaan model through
[lavaan::parameterEstimates](https://rdrr.io/pkg/lavaan/man/parameterEstimates.html)
and
[lavaan::standardizedsolution](https://rdrr.io/pkg/lavaan/man/standardizedSolution.html).

**Uncertainty for standardized coefficients**: When
`standardized_se = "delta"`, standard errors (SE) and confidence
intervals (CI) for standardized coefficients are computed via the delta
method (as in
[lavaan::standardizedsolution](https://rdrr.io/pkg/lavaan/man/standardizedSolution.html)).
When `standardized_se = "bootstrap"`, CIs for standardized coefficients
are obtained from the bootstrap distribution of the standardized
statistic (std.all) returned by
[lavaan::parameterEstimates](https://rdrr.io/pkg/lavaan/man/parameterEstimates.html)
with `standardized = TRUE`. In this case, lavaan reports SE for the
corresponding unstandardized parameter; a bootstrap SE for standardized
coefficients is not provided by lavaan. lavaanExtra preserves this
behavior and labels the SE source in the output.

The default `standardized_se = "model"` chooses "bootstrap" if the
fitted model used `se = "bootstrap"` (and `bootstrap > 0`), and "delta"
otherwise.

## Usage

``` r
lavaan_reg(fit, standardized_se = "model", nice_table = FALSE, ...)
```

## Arguments

- fit:

  lavaan fit object to extract fit indices from

- standardized_se:

  Character string indicating the method to use for computing standard
  errors and confidence intervals of standardized estimates. Options are
  "model" (default, auto-detects based on model fitting method), "delta"
  (uses delta method via
  [lavaan::standardizedsolution](https://rdrr.io/pkg/lavaan/man/standardizedSolution.html)),
  or "bootstrap" (uses bootstrap method via
  [lavaan::parameterEstimates](https://rdrr.io/pkg/lavaan/man/parameterEstimates.html)
  with `standardized = TRUE`, only available when the model was fitted
  with bootstrap standard errors). When `standardized_se = "model"`, the
  function chooses "bootstrap" if the fitted model used
  `se = "bootstrap"` (and `bootstrap > 0`), and "delta" otherwise.

- nice_table:

  Logical, whether to print the table as a
  [rempsyc::nice_table](https://rempsyc.remi-theriault.com/reference/nice_table.html)
  as well as print the reference values at the bottom of the table.

- ...:

  Arguments to be passed to
  [rempsyc::nice_table](https://rempsyc.remi-theriault.com/reference/nice_table.html)

## Value

A dataframe, including the outcome ("lhs"), predictor ("rhs"),
standardized regression coefficient ("std.all"), corresponding p-value,
as well as the unstandardized regression coefficient ("est") and its
confidence interval ("ci.lower", "ci.upper"). When
`standardized_se = "delta"`, standardized SE and CI are computed using
the delta method. When `standardized_se = "bootstrap"`, standardized CI
are computed using bootstrap and SE represents the unstandardized
bootstrap SE (lavaan limitation). The SE computation method is stored as
an attribute (`standardized_se_method`) for verification.

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

HS.model <- write_lavaan(latent = latent, regression = regression)
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

library(lavaan)
fit <- sem(HS.model, data = HolzingerSwineford1939)
lavaan_reg(fit)
#>    Outcome Predictor         SE          Z            p           b    CI_lower
#> 10   ageyr    visual 0.10223059 -0.6515452 5.146946e-01 -0.06660785 -0.26697612
#> 11   ageyr   textual 0.07452101 -4.3003671 1.705154e-05 -0.32046768 -0.46652617
#> 12   ageyr     speed 0.13527746  4.2102536 2.550842e-05  0.56955240  0.30441346
#> 13   grade    visual 0.04763058  0.2303820 8.177950e-01  0.01097323 -0.08238099
#> 14   grade   textual 0.03444008  1.4407968 1.496421e-01  0.04962116 -0.01788016
#> 15   grade     speed 0.06427861  4.6357654 3.556191e-06  0.29798057  0.17199681
#>      CI_upper           B  CI_lower_B CI_upper_B
#> 10  0.1337604 -0.05753255 -0.22998065  0.1149156
#> 11 -0.1744092 -0.30377383 -0.43682901 -0.1707186
#> 12  0.8346913  0.35378347  0.20775141  0.4998155
#> 13  0.1043274  0.01993320 -0.14957182  0.1894382
#> 14  0.1171225  0.09892078 -0.03509861  0.2329402
#> 15  0.4239643  0.38926587  0.24802239  0.5305094
```
