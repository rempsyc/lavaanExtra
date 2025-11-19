# Extract relevant modification indices along item labels

Extract relevant modification indices along item labels, with a
similarity score provided to help guide decision-making for removing
redundant items with high covariance.

## Usage

``` r
nice_modindices(fit, labels = NULL, method = "lcs", sort = TRUE, ...)
```

## Arguments

- fit:

  lavaan fit object to extract modification indices from

- labels:

  Dataframe of labels. If the original data frame is provided, and that
  it contains labelled variables, will automatically attempt to extract
  the correct labels from the dataframe.

- method:

  Method for distance calculation from
  [stringdist::stringsim](https://rdrr.io/pkg/stringdist/man/stringsim.html).
  Defaults to `"lcs"`.

- sort:

  Logical. If TRUE, sort the output using the values of the modification
  index values. Higher values appear first. Defaults to `TRUE`.

- ...:

  Arguments to be passed to
  [lavaan::modindices](https://rdrr.io/pkg/lavaan/man/modificationIndices.html)

## Value

A dataframe, including the outcome ("lhs"), predictor ("rhs"),
standardized regression coefficient ("std.all"), corresponding p-value,
as well as the unstandardized regression coefficient ("est") and its
confidence interval ("ci.lower", "ci.upper").

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
nice_modindices(fit, maximum.number = 5)
#>       lhs op   rhs     mi
#> 1  visual =~    x9 35.699
#> 2  visual =~    x7 16.659
#> 3      x7 ~~ grade 16.511
#> 4      x7 ~~ ageyr 10.030
#> 5 textual =~    x3  9.833
data_labels <- data.frame(
  x1 = "I have good visual perception",
  x2 = "I have good cube perception",
  x3 = "I have good at lozenge perception",
  x4 = "I have paragraph comprehension",
  x5 = "I am good at sentence completion",
  x6 = "I excel at finding the meaning of words",
  x7 = "I am quick at doing mental additions",
  x8 = "I am quick at counting dots",
  x9 = "I am quick at discriminating straight and curved capitals"
)
nice_modindices(fit, maximum.number = 10, labels = data_labels, op = "~~")
#>   lhs op   rhs     mi                           lhs.labels
#> 1  x7 ~~ grade 16.511 I am quick at doing mental additions
#> 2  x7 ~~ ageyr 10.030 I am quick at doing mental additions
#> 3  x2 ~~    x7  9.673          I have good cube perception
#> 4  x7 ~~    x8  9.479 I am quick at doing mental additions
#> 5  x2 ~~    x3  8.746          I have good cube perception
#> 6  x1 ~~    x9  8.408        I have good visual perception
#>                                                  rhs.labels similarity similar
#> 1                                                      <NA>         NA   FALSE
#> 2                                                      <NA>         NA   FALSE
#> 3                      I am quick at doing mental additions      0.381   FALSE
#> 4                               I am quick at counting dots      0.698    TRUE
#> 5                         I have good at lozenge perception      0.800    TRUE
#> 6 I am quick at discriminating straight and curved capitals      0.326   FALSE

x <- HolzingerSwineford1939
x <- sjlabelled::set_label(x, label = c(rep("", 6), data_labels))
fit <- sem(HS.model, data = x)
nice_modindices(fit, maximum.number = 10, op = "~~")
#>   lhs op   rhs     mi
#> 1  x7 ~~ grade 16.511
#> 2  x7 ~~ ageyr 10.030
#> 3  x2 ~~    x7  9.673
#> 4  x7 ~~    x8  9.479
#> 5  x2 ~~    x3  8.746
#> 6  x1 ~~    x9  8.408
```
