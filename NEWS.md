## lavaanExtra 0.1.2
* `rempsyc` package dependency is now on CRAN, so we can rely on it normally now (yeah!).
* Adding test coverage (100% so far!).
* Preparing for CRAN.

## lavaanExtra 0.1.1
* `nice_tidySEM`: Gains the `label_location` and `...` arguments.

## lavaanExtra 0.1.0
* `nice_tidySEM`: Corrected bug when not providing a structure/matrix layout.

## lavaanExtra 0.0.9
* Added new function: `nice_tidySEM`, for a quick and decent-looking `tidySEM` plot with sensical (but customizable) defaults.

## lavaanExtra 0.0.8
* `write_lavaan`: Exciting news! Automatic indirect effects now seemingly support any combination of IV, moderator, and DV!

## lavaanExtra 0.0.7
* `write_lavaan`: Automatic indirect effects now support another scenario: two mediators and three IVs!

## lavaanExtra 0.0.6
* Added new function: `nice_lavaanPlot`, for a quick and decent-looking `lavaanPlot` with sensical (but customizable) defaults.
* `write_lavaan`: Automatic indirect effects now support another scenario: two mediators and two IVs!

## lavaanExtra 0.0.5
* `write_lavaan`: Fixed bug with automatic indirect effects when more than 1 mediator making forbidden paths (two mediators tested successfully)

## lavaanExtra 0.0.4
* `cfa_fit_plot`: 
  * Adds ellipsis to pass any desired argument to `lavaan::cfa`, and thus removes the default `missing = "fiml"` which was causing a bug with `estimator = DWLS`.
  * Changes the default from saving to PDF to opening in RStudio Viewer, and adds an additional `save.as.pdf` argument to save as PDF.
  * Now imports `flextable::save_as_docx` (and `save_as_html`, `save_as_image`, `save_as_pptx`...) to support saving the `nice_fit` tables to Word without having to explicitly load `flextable` or `rempsyc`.
  * Added package logo!

## lavaanExtra 0.0.3
* Added new function: `cfa_fit_plot` to simultaneously print, save, and plot the CFA results.

## lavaanExtra 0.0.2
* Added new arguments/symbols: `constraint.equal` (`==`), `constraint.smaller` (`<`), `constraint.larger` (`>`), `custom` (accepts a single, lavaan-like string)

## lavaanExtra 0.0.1.0
* Added automatic indirect effects

## lavaanExtra 0.0.0.9
* First package version
