
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lavaanExtra: Convenience functions for `lavaan`

<!-- badges: start -->

[![R-CMD-check](https://github.com/rempsyc/lavaanExtra/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rempsyc/lavaanExtra/actions/workflows/R-CMD-check.yaml)
[![r-universe](https://rempsyc.r-universe.dev/badges/lavaanExtra)](https://rempsyc.r-universe.dev/ui#package:lavaanExtra)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Last-commit](https://img.shields.io/github/last-commit/rempsyc/lavaanExtra)](https://github.com/rempsyc/lavaanExtra/commits/main)
![size](https://img.shields.io/github/repo-size/rempsyc/lavaanExtra)
[![sponsors](https://img.shields.io/github/sponsors/rempsyc)](https://github.com/sponsors/rempsyc)
[![followers](https://img.shields.io/github/followers/rempsyc?style=social)](https://github.com/rempsyc?tab=followers)
[![forks](https://img.shields.io/github/forks/rempsyc/lavaanExtra?style=social)](https://github.com/rempsyc/lavaanExtra/network/members)
[![stars](https://img.shields.io/github/stars/rempsyc/lavaanExtra?style=social)](https://github.com/rempsyc/lavaanExtra/stargazers)

<!-- badges: end -->

Affords an alternative, vector-based syntax to `lavaan`, as well as
other convenience functions such as naming paths and defining indirect
links automatically. Also offers convenience formatting optimized for a
publication and script sharing workflow.

## Installation

You can install the development version of `lavaanExtra` like so:

``` r
install.packages("lavaanExtra", repos = c(
  rempsyc = "https://rempsyc.r-universe.dev",
  CRAN = "https://cloud.r-project.org"))
```

## Why use `lavaanExtra`?

1.  **Reusable code**. Don’t repeat yourself anymore when you only want
    to change a few things when comparing and fitting models.
2.  **Shorter code**. Because of point 1, you can have shorter code,
    since you write it once and simply reuse it. For items with similar
    patterns, you can also use `paste0()` with appropriate item numbers
    instead of typing each one every time.
3.  **Less error-prone code**. Because of point 1, you can have less
    risk of human errors since you don’t have possibly multiple
    different version of the same thing (which makes it easier to
    correct too).
4.  **Better control over your code**. Because of point 1, you are in
    control of the whole flow. You change it once, and it will change it
    everywhere else in the script, without having to change it manually
    for each model.
5.  **More readable code**. Because of point 1, other people (but also
    yourself) only have to process the information the first time to
    make sure it’s been specified correctly, and not every time you
    check the new models.
6.  **Prettier code**. Because it will format the model for you in a
    pretty way, every time. You don’t have to worry about manually
    making your model good-looking and readable anymore.
7.  **More accessible code**. You don’t have to remember the exact
    syntax (although it is recommended) for it to work. It uses
    intuitive variable names that most people can understand. This
    benefit is most apparent for beginners, but it also saves precious
    typing time for veterans.

## Overview

[CFA example](#cfa-example)<a name = 'CFA example'/>

[SEM example](#sem-example)<a name = 'SEM example'/>

[Saturated model](#saturated-model)<a name = 'Saturated model'/>

[Path analysis
model](#path-analysis-model)<a name = 'Path analysis model'/>

[Latent model](#latent-model)<a name = 'Latent model'/>

## CFA example

``` r
# Load library
library(lavaanExtra)
#> Suggested citation: Thériault, R. (2022). lavaanExtra: Convenience functions for lavaan 
#> (R package version 0.0.5) [Computer software]. https://lavaanExtra.remi-theriault.com/

# Define latent variables
latent <- list(visual = paste0("x", 1:3),
               textual = paste0("x", 4:6),
               speed = paste0("x", 7:9))

# Write the model, and check it
cfa.model <- write_lavaan(latent = latent)
cat(cfa.model)
#> ##################################################
#> # [---------------Latent variables---------------]
#> 
#> visual =~ x1 + x2 + x3
#> textual =~ x4 + x5 + x6
#> speed =~ x7 + x8 + x9
```

``` r
# Fit the model fit and plot with `lavaanExtra::cfa_fit_plot`
# to get the factor loadings visually (optionally as PDF)
fit.cfa <- cfa_fit_plot(cfa.model, HolzingerSwineford1939)
#> lavaan 0.6-12 ended normally after 35 iterations
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                        21
#> 
#>   Number of observations                           301
#> 
#> Model Test User Model:
#>                                               Standard      Robust
#>   Test Statistic                                85.306      87.132
#>   Degrees of freedom                                24          24
#>   P-value (Chi-square)                           0.000       0.000
#>   Scaling correction factor                                  0.979
#>     Yuan-Bentler correction (Mplus variant)                       
#> 
#> Model Test Baseline Model:
#> 
#>   Test statistic                               918.852     880.082
#>   Degrees of freedom                                36          36
#>   P-value                                        0.000       0.000
#>   Scaling correction factor                                  1.044
#> 
#> User Model versus Baseline Model:
#> 
#>   Comparative Fit Index (CFI)                    0.931       0.925
#>   Tucker-Lewis Index (TLI)                       0.896       0.888
#>                                                                   
#>   Robust Comparative Fit Index (CFI)                         0.930
#>   Robust Tucker-Lewis Index (TLI)                            0.895
#> 
#> Loglikelihood and Information Criteria:
#> 
#>   Loglikelihood user model (H0)              -3737.745   -3737.745
#>   Scaling correction factor                                  1.133
#>       for the MLR correction                                      
#>   Loglikelihood unrestricted model (H1)      -3695.092   -3695.092
#>   Scaling correction factor                                  1.051
#>       for the MLR correction                                      
#>                                                                   
#>   Akaike (AIC)                                7517.490    7517.490
#>   Bayesian (BIC)                              7595.339    7595.339
#>   Sample-size adjusted Bayesian (BIC)         7528.739    7528.739
#> 
#> Root Mean Square Error of Approximation:
#> 
#>   RMSEA                                          0.092       0.093
#>   90 Percent confidence interval - lower         0.071       0.073
#>   90 Percent confidence interval - upper         0.114       0.115
#>   P-value RMSEA <= 0.05                          0.001       0.001
#>                                                                   
#>   Robust RMSEA                                               0.092
#>   90 Percent confidence interval - lower                     0.072
#>   90 Percent confidence interval - upper                     0.114
#> 
#> Standardized Root Mean Square Residual:
#> 
#>   SRMR                                           0.065       0.065
#> 
#> Parameter Estimates:
#> 
#>   Standard errors                             Sandwich
#>   Information bread                           Observed
#>   Observed information based on                Hessian
#> 
#> Latent Variables:
#>                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
#>   visual =~                                                             
#>     x1                1.000                               0.900    0.772
#>     x2                0.554    0.132    4.191    0.000    0.498    0.424
#>     x3                0.729    0.141    5.170    0.000    0.656    0.581
#>   textual =~                                                            
#>     x4                1.000                               0.990    0.852
#>     x5                1.113    0.066   16.946    0.000    1.102    0.855
#>     x6                0.926    0.061   15.089    0.000    0.917    0.838
#>   speed =~                                                              
#>     x7                1.000                               0.619    0.570
#>     x8                1.180    0.130    9.046    0.000    0.731    0.723
#>     x9                1.082    0.266    4.060    0.000    0.670    0.665
#> 
#> Covariances:
#>                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
#>   visual ~~                                                             
#>     textual           0.408    0.099    4.110    0.000    0.459    0.459
#>     speed             0.262    0.060    4.366    0.000    0.471    0.471
#>   textual ~~                                                            
#>     speed             0.173    0.056    3.081    0.002    0.283    0.283
#> 
#> Variances:
#>                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
#>    .x1                0.549    0.156    3.509    0.000    0.549    0.404
#>    .x2                1.134    0.112   10.135    0.000    1.134    0.821
#>    .x3                0.844    0.100    8.419    0.000    0.844    0.662
#>    .x4                0.371    0.050    7.382    0.000    0.371    0.275
#>    .x5                0.446    0.057    7.870    0.000    0.446    0.269
#>    .x6                0.356    0.047    7.658    0.000    0.356    0.298
#>    .x7                0.799    0.097    8.222    0.000    0.799    0.676
#>    .x8                0.488    0.120    4.080    0.000    0.488    0.477
#>    .x9                0.566    0.119    4.768    0.000    0.566    0.558
#>     visual            0.809    0.180    4.486    0.000    1.000    1.000
#>     textual           0.979    0.121    8.075    0.000    1.000    1.000
#>     speed             0.384    0.107    3.596    0.000    1.000    1.000
#> 
#> R-Square:
#>                    Estimate
#>     x1                0.596
#>     x2                0.179
#>     x3                0.338
#>     x4                0.725
#>     x5                0.731
#>     x6                0.702
#>     x7                0.324
#>     x8                0.523
#>     x9                0.442
```

<img src="man/figures/cfaplot.png" width="30%" />

``` r
# Get fit indices
nice_fit(fit.cfa)
#>     Model   chi2 df chi2.df p   CFI   TLI RMSEA  SRMR     AIC      BIC
#> 1 fit.cfa 85.306 24   3.554 0 0.931 0.896 0.092 0.065 7517.49 7595.339

# We can get it prettier with the `rempsyc::nice_table` integration
nice_fit(fit.cfa, nice_table = TRUE)
```

<img src="man/figures/README-cfa2-1.png" width="90%" />

But let’s say you had a bad fit and wanted to remove the three items
with the lowest loadings, you can do so without have to respecify the
model, only what items you wish to remove:

``` r
# Fit the model fit and plot with `lavaanExtra::cfa_fit_plot`
# to get the factor loadings visually (as PDF)
fit.cfa2 <- cfa_fit_plot(cfa.model, HolzingerSwineford1939,
                         remove.items = paste0("x", c(2:3, 7)))
#> lavaan 0.6-12 ended normally after 29 iterations
#> 
#>   Estimator                                         ML
#>   Optimization method                           NLMINB
#>   Number of model parameters                        14
#> 
#>   Number of observations                           301
#> 
#> Model Test User Model:
#>                                               Standard      Robust
#>   Test Statistic                                 8.442       7.313
#>   Degrees of freedom                                 7           7
#>   P-value (Chi-square)                           0.295       0.397
#>   Scaling correction factor                                  1.154
#>     Yuan-Bentler correction (Mplus variant)                       
#> 
#> Model Test Baseline Model:
#> 
#>   Test statistic                               674.095     599.025
#>   Degrees of freedom                                15          15
#>   P-value                                        0.000       0.000
#>   Scaling correction factor                                  1.125
#> 
#> User Model versus Baseline Model:
#> 
#>   Comparative Fit Index (CFI)                    0.998       0.999
#>   Tucker-Lewis Index (TLI)                       0.995       0.999
#>                                                                   
#>   Robust Comparative Fit Index (CFI)                         0.999
#>   Robust Tucker-Lewis Index (TLI)                            0.999
#> 
#> Loglikelihood and Information Criteria:
#> 
#>   Loglikelihood user model (H0)              -2429.864   -2429.864
#>   Scaling correction factor                                  1.137
#>       for the MLR correction                                      
#>   Loglikelihood unrestricted model (H1)      -2425.644   -2425.644
#>   Scaling correction factor                                  1.143
#>       for the MLR correction                                      
#>                                                                   
#>   Akaike (AIC)                                4887.729    4887.729
#>   Bayesian (BIC)                              4939.628    4939.628
#>   Sample-size adjusted Bayesian (BIC)         4895.228    4895.228
#> 
#> Root Mean Square Error of Approximation:
#> 
#>   RMSEA                                          0.026       0.012
#>   90 Percent confidence interval - lower         0.000       0.000
#>   90 Percent confidence interval - upper         0.079       0.069
#>   P-value RMSEA <= 0.05                          0.713       0.814
#>                                                                   
#>   Robust RMSEA                                               0.013
#>   90 Percent confidence interval - lower                     0.000
#>   90 Percent confidence interval - upper                     0.078
#> 
#> Standardized Root Mean Square Residual:
#> 
#>   SRMR                                           0.016       0.016
#> 
#> Parameter Estimates:
#> 
#>   Standard errors                             Sandwich
#>   Information bread                           Observed
#>   Observed information based on                Hessian
#> 
#> Latent Variables:
#>                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
#>   visual =~                                                             
#>     x1                1.000                               1.165    1.000
#>   textual =~                                                            
#>     x4                1.000                               0.990    0.852
#>     x5                1.115    0.066   16.910    0.000    1.104    0.857
#>     x6                0.923    0.061   15.181    0.000    0.914    0.835
#>   speed =~                                                              
#>     x8                1.000                               0.515    0.510
#>     x9                1.722    0.398    4.322    0.000    0.887    0.881
#> 
#> Covariances:
#>                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
#>   visual ~~                                                             
#>     textual           0.462    0.087    5.292    0.000    0.400    0.400
#>     speed             0.266    0.072    3.674    0.000    0.443    0.443
#>   textual ~~                                                            
#>     speed             0.149    0.055    2.726    0.006    0.291    0.291
#> 
#> Variances:
#>                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
#>    .x1                0.000                               0.000    0.000
#>    .x4                0.370    0.050    7.356    0.000    0.370    0.274
#>    .x5                0.441    0.056    7.822    0.000    0.441    0.266
#>    .x6                0.362    0.047    7.689    0.000    0.362    0.302
#>    .x8                0.756    0.090    8.407    0.000    0.756    0.740
#>    .x9                0.228    0.167    1.359    0.174    0.228    0.224
#>     visual            1.358    0.120   11.367    0.000    1.000    1.000
#>     textual           0.981    0.121    8.093    0.000    1.000    1.000
#>     speed             0.266    0.082    3.248    0.001    1.000    1.000
#> 
#> R-Square:
#>                    Estimate
#>     x1                1.000
#>     x4                0.726
#>     x5                0.734
#>     x6                0.698
#>     x8                0.260
#>     x9                0.776
```

<img src="man/figures/cfaplot2.png" width="30%" />

Let’s compare the fit to see if it’s better now:

``` r
nice_fit(fit.cfa, fit.cfa2, nice_table = TRUE)
```

<img src="man/figures/README-cfaplot5-1.png" width="90%" />

It is! If you like this table, you may also wish to save it to Word.
Also easy:

``` r
# Save fit table as an object
fit_table <- nice_fit(fit.cfa, fit.cfa2, nice_table = TRUE)

# Save fit table to Word!
save_as_docx(fit_table, path = "fit_table.docx")
```

## SEM example

Here is a structural equation model example. We start with a path
analysis first.

### Saturated model

One might decide to look at the saturated `lavaan` model first.

``` r
# Calculate scale averages
data <- HolzingerSwineford1939
data$visual <- rowMeans(data[paste0("x", 1:3)])
data$textual <- rowMeans(data[paste0("x", 4:6)])
data$speed <- rowMeans(data[paste0("x", 7:9)])

# Define our variables
M <- "visual"
IV <- c("ageyr", "grade")
DV <- c("speed", "textual")

# Define our lavaan lists
mediation <- list(speed = M, textual = M, visual = IV)
regression <- list(speed = IV, textual = IV)
covariance <- list(speed = "textual", ageyr = "grade")

# Write the model, and check it
model.saturated <- write_lavaan(mediation, regression, covariance)
cat(model.saturated)
#> ##################################################
#> # [-----------Mediations (named paths)-----------]
#> 
#> speed ~ visual
#> textual ~ visual
#> visual ~ ageyr + grade
#> 
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> speed ~ ageyr + grade
#> textual ~ ageyr + grade
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
```

This looks good so far, but we might also want to check our indirect
effects (mediations). For this, we have to obtain the path names by
setting `label = TRUE`. This will allow us to define our indirect
effects and feed them back to `write_lavaan`.

``` r
# We can run the model again. However, we set `label = TRUE` to get the path names
model.saturated <- write_lavaan(mediation, regression, covariance, label = TRUE)
cat(model.saturated)
#> ##################################################
#> # [-----------Mediations (named paths)-----------]
#> 
#> speed ~ visual_speed*visual
#> textual ~ visual_textual*visual
#> visual ~ ageyr_visual*ageyr + grade_visual*grade
#> 
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> speed ~ ageyr + grade
#> textual ~ ageyr + grade
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
```

Here, if we check the mediation section of the model, we see that it has
been “augmented” with the path names. Those are `visual_speed`,
`visual_textual`, `ageyr_visual`, and `grade_visual`. The logic for the
determination of the path names is predictable: it is always the
predictor variable, on the left, followed by the predicted variable, on
the right. So if we were to test all possible indirect effects, we would
define our `indirect` object as such:

``` r
# Define indirect object
indirect <- list(ageyr_visual_speed = c("ageyr_visual", "visual_speed"),
                 ageyr_visual_textual = c("ageyr_visual", "visual_textual"),
                 grade_visual_speed = c("grade_visual", "visual_speed"),
                 grade_visual_textual = c("grade_visual", "visual_textual"))

# Write the model, and check it
model.saturated <- write_lavaan(mediation, regression, covariance, 
                                indirect, label = TRUE)
cat(model.saturated)
#> ##################################################
#> # [-----------Mediations (named paths)-----------]
#> 
#> speed ~ visual_speed*visual
#> textual ~ visual_textual*visual
#> visual ~ ageyr_visual*ageyr + grade_visual*grade
#> 
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> speed ~ ageyr + grade
#> textual ~ ageyr + grade
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
#> 
#> ##################################################
#> # [--------Mediations (indirect effects)---------]
#> 
#> ageyr_visual_speed := ageyr_visual * visual_speed
#> ageyr_visual_textual := ageyr_visual * visual_textual
#> grade_visual_speed := grade_visual * visual_speed
#> grade_visual_textual := grade_visual * visual_textual
```

If preferred (e.g., when dealing with long variable names), one can
choose to use letters for the predictor variables. Note however that
this tends to be somewhat more confusing and ambiguous.

``` r
# Write the model, and check it
model.saturated <- write_lavaan(mediation, regression, covariance, 
                                label = TRUE, use.letters = TRUE)
cat(model.saturated)
#> ##################################################
#> # [-----------Mediations (named paths)-----------]
#> 
#> speed ~ a_speed*visual
#> textual ~ a_textual*visual
#> visual ~ a_visual*ageyr + b_visual*grade
#> 
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> speed ~ ageyr + grade
#> textual ~ ageyr + grade
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
```

In this case, the path names are `a_speed`, `a_textual`, `a_visual`, and
`b_visual`. So we would define our `indirect` object as such:

``` r
# Define indirect object
indirect <- list(ageyr_visual_speed = c("a_visual", "a_speed"),
                 ageyr_visual_textual = c("a_visual", "a_textual"),
                 grade_visual_speed = c("b_visual", "a_speed"),
                 grade_visual_textual = c("b_visual", "a_textual"))

# Write the model, and check it
model.saturated <- write_lavaan(mediation, regression, covariance, 
                                indirect, label = TRUE, use.letters = TRUE)
cat(model.saturated)
#> ##################################################
#> # [-----------Mediations (named paths)-----------]
#> 
#> speed ~ a_speed*visual
#> textual ~ a_textual*visual
#> visual ~ a_visual*ageyr + b_visual*grade
#> 
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> speed ~ ageyr + grade
#> textual ~ ageyr + grade
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
#> 
#> ##################################################
#> # [--------Mediations (indirect effects)---------]
#> 
#> ageyr_visual_speed := a_visual * a_speed
#> ageyr_visual_textual := a_visual * a_textual
#> grade_visual_speed := b_visual * a_speed
#> grade_visual_textual := b_visual * a_textual
```

There is also an experimental feature that attempts to produce the
indirect effects automatically. This feature requires specifying your
independent, dependent, and mediator variables as “IV”, “M”, and “DV”,
respectively, in the `indirect` object. In our case, we have already
defined those earlier, so we can just feed the proper objects.

``` r
# Define indirect object
indirect <- list(IV = IV, M = M, DV = DV)

# Write the model, and check it
model.saturated <- write_lavaan(mediation, regression, covariance, 
                                indirect, label = TRUE)
cat(model.saturated)
#> ##################################################
#> # [-----------Mediations (named paths)-----------]
#> 
#> speed ~ visual_speed*visual
#> textual ~ visual_textual*visual
#> visual ~ ageyr_visual*ageyr + grade_visual*grade
#> 
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> speed ~ ageyr + grade
#> textual ~ ageyr + grade
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
#> 
#> ##################################################
#> # [--------Mediations (indirect effects)---------]
#> 
#> ageyr_visual_speed := ageyr_visual * visual_speed
#> ageyr_visual_textual := ageyr_visual * visual_textual
#> grade_visual_speed := grade_visual * visual_speed
#> grade_visual_textual := grade_visual * visual_textual
```

We are now satisfied with our model, so we can finally fit it!

``` r
# Fit the model with `lavaan`
library(lavaan)
fit.saturated <- lavaan(model.saturated, data = data, auto.var = TRUE)

# Get regression parameters only and make it pretty with the `rempsyc::nice_table` integration
lavaan_reg(fit.saturated, nice_table = TRUE, highlight = TRUE)
```

<img src="man/figures/README-saturated-1.png" width="30%" />

So `speed` as predicted by `ageyr` isn’t significant. We could remove
that path from the model it if we are trying to make a more parsimonious
model. Let’s make the non-saturated path analysis model next.

### Path analysis model

Because we use `lavaanExtra`, we don’t have to redefine the entire
model: simply what we want to update. In this case, the regressions and
the indirect effects.

``` r
regression <- list(speed = "grade", textual = IV)

# We can run the model again, setting `label = TRUE` to get the path names
model.path <- write_lavaan(mediation, regression, covariance, label = TRUE)
cat(model.path)
#> ##################################################
#> # [-----------Mediations (named paths)-----------]
#> 
#> speed ~ visual_speed*visual
#> textual ~ visual_textual*visual
#> visual ~ ageyr_visual*ageyr + grade_visual*grade
#> 
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> speed ~ grade
#> textual ~ ageyr + grade
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
# We check that we have removed "ageyr" correctly from "speed" in the 
# regression section. OK.

# Define just our indirect effects of interest
indirect <- list(age_visual_speed = c("ageyr_visual", "visual_speed"),
                 grade_visual_textual = c("grade_visual", "visual_textual"))

# We run the model again, with the indirect effects
model.path <- write_lavaan(mediation, regression, covariance, 
                           indirect, label = TRUE)
cat(model.path)
#> ##################################################
#> # [-----------Mediations (named paths)-----------]
#> 
#> speed ~ visual_speed*visual
#> textual ~ visual_textual*visual
#> visual ~ ageyr_visual*ageyr + grade_visual*grade
#> 
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> speed ~ grade
#> textual ~ ageyr + grade
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
#> 
#> ##################################################
#> # [--------Mediations (indirect effects)---------]
#> 
#> age_visual_speed := ageyr_visual * visual_speed
#> grade_visual_textual := grade_visual * visual_textual

# Fit the model with `lavaan`
fit.path <- lavaan(model.path, data = data, auto.var = TRUE)

# Get regression parameters only
lavaan_reg(fit.path)
#>   Outcome Predictor      B     p
#> 1   speed    visual  0.206 0.000
#> 2 textual    visual  0.235 0.000
#> 3  visual     ageyr -0.161 0.014
#> 4  visual     grade  0.281 0.000
#> 5   speed     grade  0.327 0.000
#> 6 textual     ageyr -0.403 0.000
#> 7 textual     grade  0.358 0.000

# We can get it prettier with the `rempsyc::nice_table` integration
lavaan_reg(fit.path, nice_table = TRUE, highlight = TRUE)
```

<img src="man/figures/README-indirect1-1.png" width="30%" />

``` r
# We only kept significant regressions. Good (for this demo).

# Get covariance indices
lavaan_cov(fit.path)
#>    Variable.1 Variable.2     r     p
#> 8       speed    textual 0.131 0.024
#> 9       ageyr      grade 0.511 0.000
#> 10      speed      speed 0.824 0.000
#> 11    textual    textual 0.765 0.000
#> 12     visual     visual 0.942 0.000
#> 13      ageyr      ageyr 1.000 0.000
#> 14      grade      grade 1.000 0.000

# We can get it prettier with the `rempsyc::nice_table` integration
lavaan_cov(fit.path, nice_table = TRUE)
```

<img src="man/figures/README-covariance-1.png" width="30%" />

``` r
# Get nice fit indices with the `rempsyc::nice_table` integration
nice_fit(fit.cfa, fit.saturated, fit.path, nice_table = TRUE)
```

<img src="man/figures/README-path2-1.png" width="90%" />

``` r
# Let's get the indirect effects only
lavaan_ind(fit.path)
#>         Indirect.Effect                       Paths      B     p
#> 15     age_visual_speed   ageyr_visual*visual_speed -0.033 0.037
#> 16 grade_visual_textual grade_visual*visual_textual  0.066 0.002

# We can get it prettier with the `rempsyc::nice_table` integration
lavaan_ind(fit.path, nice_table = TRUE)
```

<img src="man/figures/README-indirect2-1.png" width="50%" />

``` r
# Get modification indices only
modindices(fit.path, sort = TRUE, maximum.number = 5)
#>       lhs op     rhs    mi    epc sepc.lv sepc.all sepc.nox
#> 29 visual  ~ textual 0.326  1.622   1.622    1.975    1.975
#> 35  grade  ~ textual 0.326 -0.228  -0.228   -0.488   -0.488
#> 34  grade  ~   speed 0.326 -0.038  -0.038   -0.062   -0.062
#> 19  speed ~~   grade 0.326 -0.021  -0.021   -0.056   -0.056
#> 25  speed  ~ textual 0.326 -0.067  -0.067   -0.087   -0.087
```

For reference, this is our model, visually speaking

![](man/figures/holzinger_model.png)

### Latent model

Finally, perhaps we change our mind and decide to run a full SEM
instead, with latent variables. Fear not: we don’t have to redo
everything again. We can simply define our latent variables and proceed.
In this example, we have *already* defined our latent variable for our
CFA earlier, so we don’t even need to write that again!

``` r
model.latent <- write_lavaan(mediation, regression, covariance, 
                             indirect, latent, label = TRUE)
cat(model.latent)
#> ##################################################
#> # [---------------Latent variables---------------]
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
#> # [---------Regressions (Direct effects)---------]
#> 
#> speed ~ grade
#> textual ~ ageyr + grade
#> 
#> ##################################################
#> # [------------------Covariances-----------------]
#> 
#> speed ~~ textual
#> ageyr ~~ grade
#> 
#> ##################################################
#> # [--------Mediations (indirect effects)---------]
#> 
#> age_visual_speed := ageyr_visual * visual_speed
#> grade_visual_textual := grade_visual * visual_textual

# Run model
fit.latent <- lavaan(model.latent, data = HolzingerSwineford1939, auto.var = TRUE, 
              auto.fix.first = TRUE, auto.cov.lv.x = TRUE)

# Get nice fit indices with the `rempsyc::nice_table` integration
nice_fit(fit.cfa, fit.saturated, fit.path, fit.latent, nice_table = TRUE)
```

<img src="man/figures/README-latent-1.png" width="90%" />

### Final note

This is an experimental package in a *very* early stage. Any feedback or
feature request is appreciated, and the package will likely change and
evolve over time based on community feedback. Feel free to open an issue
or discussion to share your questions or concerns.

## Support me and this package

Thank you for your support. You can support me and this package here:
<https://github.com/sponsors/rempsyc>
