## lavaanExtra 0.0.5
- Fixed bug with automatic indirect effects when more than 1 mediator making forbidden paths (two mediators tested successfully)

## lavaanExtra 0.0.4
* `cfa_fit_plot`: 
  * Adds ellipsis to pass any desired argument to `lavaan::cfa`, and thus removes the default `missing = "fiml"` which was causing a bug with `estimator = DWLS`.
  * Changes the default from saving to PDF to opening in RStudio Viewer, and adds an additional `save.as.pdf` argument to save as PDF.
  * Now imports `flextable::save_as_docx` (and `save_as_html`, `save_as_image`, `save_as_pptx`...) to support saving the `nice_fit` tables to Word without having to explicitely load `flextable` or `rempsyc`.
  * Added package logo!

## lavaanExtra 0.0.3
* Added new function: `cfa_fit_plot` to simultaneously print, save, and plot the CFA results.

## lavaanExtra 0.0.2
* Added new arguments/symbols: `constraint.equal` (`==`), `constraint.smaller` (`<`), `constraint.larger` (`>`), `custom` (accepts a single, lavaan-like string)

## lavaanExtra 0.0.1.0
* Added automatic indirect effects

## lavaanExtra 0.0.0.9
* First package version
