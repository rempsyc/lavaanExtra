# lavaanExtra 0.1.9
* ✨Incoming✨

## lavaanExtra 0.1.8.1
* `?lavaanExtra` now works as expected.

# lavaanExtra 0.1.8
* CRAN resubmission
* New function: `nice_modindices`, which outputs modification indices along item labels and a similarity score between the left-hand side and right-hand side items. Useful to assess item redundancy when considering modification indices.

# lavaanExtra 0.1.7
* CRAN resubmission: suggested dependencies now check for the correct version with `rlang::check_installed()`.

# lavaanExtra 0.1.6
* CRAN resubmission: tests now run even without suggested dependencies.

# lavaanExtra 0.1.5
* CRAN resubmission

## lavaanExtra 0.1.4.7
* `nice_tidySEM`: new argument: `reduce_items`, to change the size of the nodes (boxes) of the items defining the latent variables (which often require less emphasis).

## lavaanExtra 0.1.4.6
* `nice_tidySEM`: now omit the leading zero when using standardized coefficients (for APA style).
* `nice_fit`:
  * Update fit indices recommendations from Schreiber et al. (2006) to Schreiber (2017). Only benchmark that has changed is RMSEA, moving to `< .05 [.00, .08]` from  `< .06-.08 [.00, .10]`.
  * Make table shorter by combining the RMSEA column and its confidence interval and shortening the AIC and BIC interpretations.

## lavaanExtra 0.1.4.5
* `lavaan_cov`: renamed r column to covariance since in some cases standardized residual variances were not real correlations.
* New function: `lavaan_cor`, which is the same as `lavaan_cov` but only for actual correlations
* `lavaan_reg`, `lavaan_ind`, and `lavaan_cov`: new argument `estimate` which can be either "B" to obtain standardized estimates and corresponding p values and confidence interval, or "b" for unstandardized values.
* `nice_lavaanPlot`: stars now appear not only for regression per default, but also for latent variables and covariances `c("regress", "latent", "covs")`.

## lavaanExtra 0.1.4.4
* `nice_tidySEM`: corrected a bug whereas if the layout contained columns named c("IV", "M", "DV"), it would remove any extra columns (such as items), explicitly ignoring part of the layout provided.
* `nice_lavaanPlot`: now default to black path lines instead of gray.

## lavaanExtra 0.1.4.3
* In examples and internal tests, now check for package availability to satisfy CRAN requirements.
* Remove vignettes from package, to satisfy CRAN package size requirements (they are still available on the website however).

## lavaanExtra 0.1.4.2
* `nice_fit`: better error message when not providing a lavaan object.
* `tmvnsim` package now required for nice_tidySEM as it seems necessary to use `tidySEM`'s new version.

## lavaanExtra 0.1.4.1
* `nice_tidySEM`: New argument to hide covariances: `hide_cov` (defaults to `FALSE`).

# lavaanExtra 0.1.4
* CRAN resubmission

## lavaanExtra 0.1.3.3
* Breaking changes: 
    - We remove the copied/reexported `save_as_docx` and the like in favour of explicitly calling `flextable::save_as_docx`. This way we are not creating namespace conflicts for these functions, we are consistent with the new approach in `rempsyc`, and it also gives credit to the `flextable` package, as this is the powerhouse that produces the tables under the hood.
    - `nice_fit` now requires a list of models (or a single model), so it will not accept models loosely provided in the function as different arguments. This is because we get rid of the dot-dot-dot `...` argument in favour of supporting list objects.
* `nice_fit` now has an added footnote reference to Schreiber et al. (2006) for fit indices references when using `nice_table = TRUE`.

## lavaanExtra 0.1.3.2
* `nice_fit`: gains a `model.labels` argument to customize the model names in the table.

## lavaanExtra 0.1.3.1
* `lavaan_ind` gains an argument, `underscores_to_arrows`, to replace underscores by arrows for the indirect effect column, so that indirect effects are more quickly visually interpretable.
* `nice_tidySEM`: More meaningful error message when providing unmatching label names.
* `nice_fit` look improved when using `nice_table = TRUE`

# lavaanExtra 0.1.3
* CRAN resubmission

# lavaanExtra 0.1.2
* `rempsyc` package dependency is now on CRAN, so we can rely on it normally now (yeah!).
* Adding test coverage (100% so far!).
* Preparing for CRAN.

# lavaanExtra 0.1.1
* `nice_tidySEM`: Gains the `label_location` and `...` arguments.

# lavaanExtra 0.1.0
* `nice_tidySEM`: Corrected bug when not providing a structure/matrix layout.

# lavaanExtra 0.0.9
* Added new function: `nice_tidySEM`, for a quick and decent-looking `tidySEM` plot with sensical (but customizable) defaults.

# lavaanExtra 0.0.8
* `write_lavaan`: Exciting news! Automatic indirect effects now seemingly support any combination of IV, moderator, and DV!

# lavaanExtra 0.0.7
* `write_lavaan`: Automatic indirect effects now support another scenario: two mediators and three IVs!

# lavaanExtra 0.0.6
* Added new function: `nice_lavaanPlot`, for a quick and decent-looking `lavaanPlot` with sensical (but customizable) defaults.
* `write_lavaan`: Automatic indirect effects now support another scenario: two mediators and two IVs!

# lavaanExtra 0.0.5
* `write_lavaan`: Fixed bug with automatic indirect effects when more than 1 mediator making forbidden paths (two mediators tested successfully)

# lavaanExtra 0.0.4
* `cfa_fit_plot`: 
  * Adds ellipsis to pass any desired argument to `lavaan::cfa`, and thus removes the default `missing = "fiml"` which was causing a bug with `estimator = DWLS`.
  * Changes the default from saving to PDF to opening in RStudio Viewer, and adds an additional `save.as.pdf` argument to save as PDF.
  * Now imports `flextable::save_as_docx` (and `save_as_html`, `save_as_image`, `save_as_pptx`...) to support saving the `nice_fit` tables to Word without having to explicitly load `flextable` or `rempsyc`.
  * Added package logo!

# lavaanExtra 0.0.3
* Added new function: `cfa_fit_plot` to simultaneously print, save, and plot the CFA results.

# lavaanExtra 0.0.2
* Added new arguments/symbols: `constraint.equal` (`==`), `constraint.smaller` (`<`), `constraint.larger` (`>`), `custom` (accepts a single, lavaan-like string)

## lavaanExtra 0.0.1.0
* Added automatic indirect effects

## lavaanExtra 0.0.0.9
* First package version
