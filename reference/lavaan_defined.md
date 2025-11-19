# Extract relevant user-defined parameter (e.g., indirect or total effects) indices from lavaan model

Extract relevant user-defined parameters (e.g., indirect or total
effects) indices from lavaan model through
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
lavaan_defined(
  fit,
  underscores_to_symbol = "→",
  lhs_name = "User-Defined Parameter",
  rhs_name = "Paths",
  standardized_se = "model",
  nice_table = FALSE,
  ...
)
```

## Arguments

- fit:

  lavaan fit object to extract fit indices from

- underscores_to_symbol:

  Character to convert underscores to arrows in the first column, like
  for indirect effects. Default to the right arrow symbol, but can be
  set to NULL or "\_", or to any other desired symbol. It is also
  possible to provide a vector of replacements if they they are not all
  the same.

- lhs_name:

  Name of first column, referring to the left-hand side expression
  (lhs).

- rhs_name:

  Name of first column, referring to the right-hand side expression
  (rhs).

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

A dataframe, including the indirect effect ("lhs"), corresponding paths
("rhs"), standardized regression coefficient ("std.all"), corresponding
p-value, as well as the unstandardized regression coefficient ("est")
and its confidence interval ("ci.lower", "ci.upper"). When
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

(mediation <- list(
  speed = "visual",
  textual = "visual",
  visual = c("ageyr", "grade")
))
#> $speed
#> [1] "visual"
#> 
#> $textual
#> [1] "visual"
#> 
#> $visual
#> [1] "ageyr" "grade"
#> 

(indirect <- list(
  IV = c("ageyr", "grade"),
  M = "visual",
  DV = c("speed", "textual")
))
#> $IV
#> [1] "ageyr" "grade"
#> 
#> $M
#> [1] "visual"
#> 
#> $DV
#> [1] "speed"   "textual"
#> 

HS.model <- write_lavaan(mediation,
  indirect = indirect,
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
#> # [-----------Mediations (named paths)-----------]
#> 
#> speed ~ visual_speed*visual
#> textual ~ visual_textual*visual
#> visual ~ ageyr_visual*ageyr + grade_visual*grade
#> 
#> ##################################################
#> # [--------Mediations (indirect effects)---------]
#> 
#> ageyr_visual_speed := ageyr_visual * visual_speed
#> ageyr_visual_textual := ageyr_visual * visual_textual
#> grade_visual_speed := grade_visual * visual_speed
#> grade_visual_textual := grade_visual * visual_textual
#> 

library(lavaan)
fit <- sem(HS.model, data = HolzingerSwineford1939)
lavaan_defined(fit, lhs_name = "Indirect Effect")
#>             Indirect Effect                       Paths         SE         Z
#> 30   ageyr → visual → speed   ageyr_visual*visual_speed 0.02808889 -3.198387
#> 31 ageyr → visual → textual ageyr_visual*visual_textual 0.04191650 -3.461890
#> 32   grade → visual → speed   grade_visual*visual_speed 0.07291514  4.257496
#> 33 grade → visual → textual grade_visual*visual_textual 0.10134908  4.947490
#>               p           b   CI_lower    CI_upper          B CI_lower_B
#> 30 1.381987e-03 -0.08983914 -0.1448924 -0.03478593 -0.1508037 -0.2358595
#> 31 5.363956e-04 -0.14511033 -0.2272652 -0.06295550 -0.1534909 -0.2371048
#> 32 2.067294e-05  0.31043593  0.1675249  0.45334698  0.2477787  0.1503789
#> 33 7.517664e-07  0.50142352  0.3027830  0.70006406  0.2521937  0.1601663
#>     CI_upper_B
#> 30 -0.06574796
#> 31 -0.06987694
#> 32  0.34517843
#> 33  0.34422119
```
