# Vector-based lavaan syntax interpreter

Vector-based lavaan syntax interpreter.

## Usage

``` r
write_lavaan(
  mediation = NULL,
  regression = NULL,
  covariance = NULL,
  indirect = NULL,
  latent = NULL,
  intercept = NULL,
  threshold = NULL,
  constraint.equal = NULL,
  constraint.smaller = NULL,
  constraint.larger = NULL,
  custom = NULL,
  label = FALSE,
  use.letters = FALSE
)
```

## Arguments

- mediation:

  Mediation indicators (`~` symbol: "is regressed on"). Differs from
  argument `regression` because path names can be optionally specified
  automatically with argument `label`.

- regression:

  Regression indicators (`~` symbol: "is regressed on").

- covariance:

  (Residual) (co)variance indicators (`~~` symbol: "is correlated
  with").

- indirect:

  Indirect effect indicators (`:=` symbol: "indirect effect defined
  as"). If a named list is provided, with names "IV" (independent
  variables), "M" (mediator), and "DV" (dependent variables),
  `write_lavaan` attempts to write indirect effects automatically. In
  this case, the `mediation` argument must be specified too.

- latent:

  Latent variable indicators (`=~` symbol: "is measured by").

- intercept:

  Intercept indicators (`~ 1` symbol: "intercept").

- threshold:

  Threshold indicators (`|` symbol: "threshold").

- constraint.equal:

  Equality indicators (`==` symbol).

- constraint.smaller:

  Smaller than indicators (`<` symbol).

- constraint.larger:

  Greater than indicators (`>` symbol).

- custom:

  Custom specifications. Takes a *single* string just like regular
  `lavaan` syntax would. Always added at the end of the model.

- label:

  Logical, whether to display path names for the mediation argument.

- use.letters:

  Logical, for the labels, whether to use letters instead of the
  variable names.

## Value

A character string, representing the specified `lavaan` model.

## See also

The corresponding vignette:
<https://lavaanextra.remi-theriault.com/articles/write_lavaan.html>

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

HS.model <- write_lavaan(latent = latent)
cat(HS.model)
#> ##################################################
#> # [-----Latent variables (measurement model)-----]
#> 
#> visual =~ x1 + x2 + x3
#> textual =~ x4 + x5 + x6
#> speed =~ x7 + x8 + x9
#> 

library(lavaan)
fit <- lavaan(HS.model,
  data = HolzingerSwineford1939,
  auto.var = TRUE, auto.fix.first = TRUE,
  auto.cov.lv.x = TRUE
)
summary(fit, fit.measures = TRUE)
#> lavaan 0.6-20 ended normally after 35 iterations
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                        21
#> 
#>   Number of observations                           301
#> 
#> Model Test User Model:
#>                                                       
#>   Test statistic                                85.306
#>   Degrees of freedom                                24
#>   P-value (Chi-square)                           0.000
#> 
#> Model Test Baseline Model:
#> 
#>   Test statistic                               918.852
#>   Degrees of freedom                                36
#>   P-value                                        0.000
#> 
#> User Model versus Baseline Model:
#> 
#>   Comparative Fit Index (CFI)                    0.931
#>   Tucker-Lewis Index (TLI)                       0.896
#> 
#> Loglikelihood and Information Criteria:
#> 
#>   Loglikelihood user model (H0)              -3737.745
#>   Loglikelihood unrestricted model (H1)      -3695.092
#>                                                       
#>   Akaike (AIC)                                7517.490
#>   Bayesian (BIC)                              7595.339
#>   Sample-size adjusted Bayesian (SABIC)       7528.739
#> 
#> Root Mean Square Error of Approximation:
#> 
#>   RMSEA                                          0.092
#>   90 Percent confidence interval - lower         0.071
#>   90 Percent confidence interval - upper         0.114
#>   P-value H_0: RMSEA <= 0.050                    0.001
#>   P-value H_0: RMSEA >= 0.080                    0.840
#> 
#> Standardized Root Mean Square Residual:
#> 
#>   SRMR                                           0.065
#> 
#> Parameter Estimates:
#> 
#>   Standard errors                             Standard
#>   Information                                 Expected
#>   Information saturated (h1) model          Structured
#> 
#> Latent Variables:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   visual =~                                           
#>     x1                1.000                           
#>     x2                0.554    0.100    5.554    0.000
#>     x3                0.729    0.109    6.685    0.000
#>   textual =~                                          
#>     x4                1.000                           
#>     x5                1.113    0.065   17.014    0.000
#>     x6                0.926    0.055   16.703    0.000
#>   speed =~                                            
#>     x7                1.000                           
#>     x8                1.180    0.165    7.152    0.000
#>     x9                1.082    0.151    7.155    0.000
#> 
#> Covariances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   visual ~~                                           
#>     textual           0.408    0.074    5.552    0.000
#>     speed             0.262    0.056    4.660    0.000
#>   textual ~~                                          
#>     speed             0.173    0.049    3.518    0.000
#> 
#> Variances:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>    .x1                0.549    0.114    4.833    0.000
#>    .x2                1.134    0.102   11.146    0.000
#>    .x3                0.844    0.091    9.317    0.000
#>    .x4                0.371    0.048    7.779    0.000
#>    .x5                0.446    0.058    7.642    0.000
#>    .x6                0.356    0.043    8.277    0.000
#>    .x7                0.799    0.081    9.823    0.000
#>    .x8                0.488    0.074    6.573    0.000
#>    .x9                0.566    0.071    8.003    0.000
#>     visual            0.809    0.145    5.564    0.000
#>     textual           0.979    0.112    8.737    0.000
#>     speed             0.384    0.086    4.451    0.000
#> 
```
