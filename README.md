
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

[Regression
example](#regression-example)<a name = 'Regression example'/>

[CFA example](#cfa-example)<a name = 'CFA example'/>

[SEM example](#sem-example)<a name = 'SEM example'/>

[Saturated model](#saturated-model)<a name = 'Saturated model'/>

[Path analysis
model](#path-analysis-model)<a name = 'Path analysis model'/>

[Latent model](#latent-model)<a name = 'Latent model'/>

[Special cases](#special-cases)<a name = 'Special cases'/>

## Regression example

``` r
# Define our regression terms
(regression <- list(mpg = names(mtcars)[2:5],
                    disp = names(mtcars)[4:7]))
#> $mpg
#> [1] "cyl"  "disp" "hp"   "drat"
#> 
#> $disp
#> [1] "hp"   "drat" "wt"   "qsec"

# Load library
library(lavaanExtra)
#> Suggested citation: Thériault, R. (2022). lavaanExtra: Convenience functions for lavaan (R package version 0.0.3) [Computer software]. https://lavaanExtra.remi-theriault.com/

# Write the model, and check it
mtcars.model <- write_lavaan(regression = regression)
cat(mtcars.model)
#> ##################################################
#> # [---------Regressions (Direct effects)---------]
#> 
#> mpg ~ cyl + disp + hp + drat
#> disp ~ hp + drat + wt + qsec

# Fit the model with `lavaan`
library(lavaan)
fit.reg <- lavaan(mtcars.model, data = mtcars, auto.var = TRUE)

# Get regression parameters only
lavaan_reg(fit.reg)
#>   Outcome Predictor      B     p
#> 1     mpg       cyl -0.242 0.244
#> 2     mpg      disp -0.287 0.123
#> 3     mpg        hp -0.264 0.128
#> 4     mpg      drat  0.192 0.159
#> 5    disp        hp  0.175 0.177
#> 6    disp      drat -0.177 0.034
#> 7    disp        wt  0.614 0.000
#> 8    disp      qsec -0.186 0.061

# We can get it prettier with the `rempsyc::nice_table` integration
lavaan_reg(fit.reg, nice_table = TRUE, highlight = TRUE)
```

<img src="man/figures/README-reg-1.png" width="30%" />

## CFA example

``` r
# Define latent variables
(latent <- list(visual = paste0("x", 1:3),
                textual = paste0("x", 4:6),
                speed = paste0("x", 7:9)))
#> $visual
#> [1] "x1" "x2" "x3"
#> 
#> $textual
#> [1] "x4" "x5" "x6"
#> 
#> $speed
#> [1] "x7" "x8" "x9"

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
# Fit the model fit and plot to PDF with `lavaanExtra::cfa_fit_plot`
# to get the factor loadings
fit.cfa <- cfa_fit_plot(cfa.model, HolzingerSwineford1939)
```

<img src="man/figures/cfaplot.png" width="30%" />

    #> lavaan 0.6-12 ended normally after 35 iterations
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
    #>   Sample-size adjusted Bayesian (BIC)         7528.739
    #> 
    #> Root Mean Square Error of Approximation:
    #> 
    #>   RMSEA                                          0.092
    #>   90 Percent confidence interval - lower         0.071
    #>   90 Percent confidence interval - upper         0.114
    #>   P-value RMSEA <= 0.05                          0.001
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
    #>                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
    #>   visual =~                                                             
    #>     x1                1.000                               0.900    0.772
    #>     x2                0.554    0.100    5.554    0.000    0.498    0.424
    #>     x3                0.729    0.109    6.685    0.000    0.656    0.581
    #>   textual =~                                                            
    #>     x4                1.000                               0.990    0.852
    #>     x5                1.113    0.065   17.014    0.000    1.102    0.855
    #>     x6                0.926    0.055   16.703    0.000    0.917    0.838
    #>   speed =~                                                              
    #>     x7                1.000                               0.619    0.570
    #>     x8                1.180    0.165    7.152    0.000    0.731    0.723
    #>     x9                1.082    0.151    7.155    0.000    0.670    0.665
    #> 
    #> Covariances:
    #>                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
    #>   visual ~~                                                             
    #>     textual           0.408    0.074    5.552    0.000    0.459    0.459
    #>     speed             0.262    0.056    4.660    0.000    0.471    0.471
    #>   textual ~~                                                            
    #>     speed             0.173    0.049    3.518    0.000    0.283    0.283
    #> 
    #> Variances:
    #>                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
    #>    .x1                0.549    0.114    4.833    0.000    0.549    0.404
    #>    .x2                1.134    0.102   11.146    0.000    1.134    0.821
    #>    .x3                0.844    0.091    9.317    0.000    0.844    0.662
    #>    .x4                0.371    0.048    7.779    0.000    0.371    0.275
    #>    .x5                0.446    0.058    7.642    0.000    0.446    0.269
    #>    .x6                0.356    0.043    8.277    0.000    0.356    0.298
    #>    .x7                0.799    0.081    9.823    0.000    0.799    0.676
    #>    .x8                0.488    0.074    6.573    0.000    0.488    0.477
    #>    .x9                0.566    0.071    8.003    0.000    0.566    0.558
    #>     visual            0.809    0.145    5.564    0.000    1.000    1.000
    #>     textual           0.979    0.112    8.737    0.000    1.000    1.000
    #>     speed             0.384    0.086    4.451    0.000    1.000    1.000
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

``` r
# Get fit indices
nice_fit(fit.cfa)
#>     Model   chi2 df chi2.df p   CFI   TLI RMSEA  SRMR     AIC      BIC
#> 1 fit.cfa 85.306 24   3.554 0 0.931 0.896 0.092 0.065 7517.49 7595.339

# We can get it prettier with the `rempsyc::nice_table` integration
nice_fit(fit.cfa, nice_table = TRUE)
```

<img src="man/figures/README-cfa2-1.png" width="90%" />

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

# Check what we have
head(data)
#>   id sex ageyr agemo  school grade       x1   x2    x3       x4   x5        x6
#> 1  1   1    13     1 Pasteur     7 3.333333 7.75 0.375 2.333333 5.75 1.2857143
#> 2  2   2    13     7 Pasteur     7 5.333333 5.25 2.125 1.666667 3.00 1.2857143
#> 3  3   2    13     1 Pasteur     7 4.500000 5.25 1.875 1.000000 1.75 0.4285714
#> 4  4   1    13     2 Pasteur     7 5.333333 7.75 3.000 2.666667 4.50 2.4285714
#> 5  5   2    12     2 Pasteur     7 4.833333 4.75 0.875 2.666667 4.00 2.5714286
#> 6  6   2    14     1 Pasteur     7 5.333333 5.00 2.250 1.000000 3.00 0.8571429
#>         x7   x8       x9   visual  textual    speed
#> 1 3.391304 5.75 6.361111 3.819444 3.123016 5.167472
#> 2 3.782609 6.25 7.916667 4.236111 1.984127 5.983092
#> 3 3.260870 3.90 4.416667 3.875000 1.059524 3.859179
#> 4 3.000000 5.30 4.861111 5.361111 3.198413 4.387037
#> 5 3.695652 6.30 5.916667 3.486111 3.079365 5.304106
#> 6 4.347826 6.65 7.500000 4.194444 1.619048 6.165942

# Define our variables
(M <- "visual")
#> [1] "visual"
(IV <- c("ageyr", "grade"))
#> [1] "ageyr" "grade"
(DV <- c("speed", "textual"))
#> [1] "speed"   "textual"

# Define our lavaan lists
(mediation <- list(speed = M,
                   textual = M,
                   visual = IV))
#> $speed
#> [1] "visual"
#> 
#> $textual
#> [1] "visual"
#> 
#> $visual
#> [1] "ageyr" "grade"
(regression <- list(speed = IV,
                    textual = IV))
#> $speed
#> [1] "ageyr" "grade"
#> 
#> $textual
#> [1] "ageyr" "grade"
(covariance <- list(speed = "textual",
                    ageyr = "grade"))
#> $speed
#> [1] "textual"
#> 
#> $ageyr
#> [1] "grade"

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
(indirect <- list(ageyr_visual_speed = c("ageyr_visual", "visual_speed"),
                  ageyr_visual_textual = c("ageyr_visual", "visual_textual"),
                  grade_visual_speed = c("grade_visual", "visual_speed"),
                  grade_visual_textual = c("grade_visual", "visual_textual")))
#> $ageyr_visual_speed
#> [1] "ageyr_visual" "visual_speed"
#> 
#> $ageyr_visual_textual
#> [1] "ageyr_visual"   "visual_textual"
#> 
#> $grade_visual_speed
#> [1] "grade_visual" "visual_speed"
#> 
#> $grade_visual_textual
#> [1] "grade_visual"   "visual_textual"

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
(indirect <- list(ageyr_visual_speed = c("a_visual", "a_speed"),
                  ageyr_visual_textual = c("a_visual", "a_textual"),
                  grade_visual_speed = c("b_visual", "a_speed"),
                  grade_visual_textual = c("b_visual", "a_textual")))
#> $ageyr_visual_speed
#> [1] "a_visual" "a_speed" 
#> 
#> $ageyr_visual_textual
#> [1] "a_visual"  "a_textual"
#> 
#> $grade_visual_speed
#> [1] "b_visual" "a_speed" 
#> 
#> $grade_visual_textual
#> [1] "b_visual"  "a_textual"

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
dependent and mediator variables as “DV” and “M”, respectively, in the
`indirect` object. In our case, we have already defined those earlier,
so we can just feed the proper objects.

``` r
# Define indirect object
(indirect <- list(M = M, 
                  DV = DV))
#> $M
#> [1] "visual"
#> 
#> $DV
#> [1] "speed"   "textual"

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
(regression <- list(speed = "grade",
                    textual = IV))
#> $speed
#> [1] "grade"
#> 
#> $textual
#> [1] "ageyr" "grade"
# We check that we have removed "ageyr" correctly from "speed". OK.

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
(indirect <- list(age_visual_speed = c("visual_speed", "ageyr_visual"),
                  grade_visual_textual = c("visual_textual", "grade_visual")))
#> $age_visual_speed
#> [1] "visual_speed" "ageyr_visual"
#> 
#> $grade_visual_textual
#> [1] "visual_textual" "grade_visual"

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
#> age_visual_speed := visual_speed * ageyr_visual
#> grade_visual_textual := visual_textual * grade_visual

# Fit the model with `lavaan`
fit.path <- lavaan(model.path, data = data, auto.var = TRUE)

# Get regression parameters only and make it pretty with the `rempsyc::nice_table` integration
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
# Get fit indices
nice_fit(fit.cfa, fit.saturated, fit.path)
#>           Model   chi2 df chi2.df     p   CFI   TLI RMSEA  SRMR      AIC
#> 1       fit.cfa 85.306 24   3.554 0.000 0.931 0.896 0.092 0.065 7517.490
#> 2 fit.saturated  0.000  0     NaN    NA 1.000 1.000 0.000 0.000 3483.460
#> 3      fit.path  0.327  1   0.327 0.568 1.000 1.028 0.000 0.007 3481.787
#>        BIC
#> 1 7595.339
#> 2 3539.017
#> 3 3533.640

# We can get it prettier with the `rempsyc::nice_table` integration
nice_fit(fit.cfa, fit.saturated, fit.path, nice_table = TRUE)
```

<img src="man/figures/README-path2-1.png" width="90%" />

``` r
# Let's get the indirect effects only
lavaan_ind(fit.path)
#>         Indirect.Effect                       Paths      B     p
#> 15     age_visual_speed   visual_speed*ageyr_visual -0.033 0.037
#> 16 grade_visual_textual visual_textual*grade_visual  0.066 0.002

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
#> age_visual_speed := visual_speed * ageyr_visual
#> grade_visual_textual := visual_textual * grade_visual

# Run model
fit.latent <- lavaan(model.latent, data = HolzingerSwineford1939, auto.var = TRUE, 
              auto.fix.first = TRUE, auto.cov.lv.x = TRUE)

# Get fit indices
nice_fit(fit.cfa, fit.saturated, fit.path, fit.latent)
#>           Model    chi2 df chi2.df     p   CFI   TLI RMSEA  SRMR      AIC
#> 1       fit.cfa  85.306 24   3.554 0.000 0.931 0.896 0.092 0.065 7517.490
#> 2 fit.saturated   0.000  0     NaN    NA 1.000 1.000 0.000 0.000 3483.460
#> 3      fit.path   0.327  1   0.327 0.568 1.000 1.028 0.000 0.007 3481.787
#> 4    fit.latent 118.917 37   3.214 0.000 0.924 0.888 0.086 0.061 8638.789
#>        BIC
#> 1 7595.339
#> 2 3539.017
#> 3 3533.640
#> 4 8746.198

# We can get it prettier with the `rempsyc::nice_table` integration
nice_fit(fit.cfa, fit.saturated, fit.path, fit.latent, nice_table = TRUE)
```

<img src="man/figures/README-latent-1.png" width="90%" />

# Special cases

Finally, intercepts and various constraints can also be specified, e.g.:

``` r
intercept <- c("mpg", "cyl", "disp")
constraint.equal <- list(b1 = "(b2 + b3)^2")
constraint.smaller <- list(b1 = "exp(b2 + b3)")
constraint.larger <- list(b1 = "exp(b2 + b3)")
custom <- "y1 + y2 ~ f1 + f2 + x1 + x2"

model.custom <- write_lavaan(
  intercept = intercept, constraint.equal = constraint.equal, 
  constraint.smaller = constraint.smaller, 
  constraint.larger = constraint.larger, custom = custom)
cat(model.custom)
#> ##################################################
#> # [------------------Intercepts------------------]
#> 
#> mpg ~ 1
#> cyl ~ 1
#> disp ~ 1
#> 
#> ##################################################
#> # [-----------------Constraints------------------]
#> 
#> b1 == (b2 + b3)^2
#> b1 < exp(b2 + b3)
#> b1 > exp(b2 + b3)
#> 
#> ##################################################
#> # [------------Custom Specifications-------------]
#> 
#> y1 + y2 ~ f1 + f2 + x1 + x2
```

### Final note

This is an experimental package in a *very* early stage. Any feedback or
feature request is appreciated, and the package will likely change and
evolve over time based on community feedback. Feel free to open an issue
or discussion to share your questions or concerns.

## Support me and this package

Thank you for your support. You can support me and this package here:
<https://github.com/sponsors/rempsyc>
