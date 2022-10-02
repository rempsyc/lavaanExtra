# Development objectives (to-do list)

- Submit to CRAN
- Add return value to all functions
- Make sure to save to temp directory in examples and vignettes
- Change all \\dontrun by \\donttest
- Don't write information messages to the console that cannot be easily suppressed
- All extraction functions: provide both standardized and unstandardized coefficients, as well as the 95% CI.
- `lavaan_cov`: rename r for something more meaningful
- `nice_tidySEM`: improve algorithm when odd number of variables for layout matrix by adding two empty rows around the odd levels, and one empty row in the middle of the even levels.
- Add automatic covariances (specify levels, e.g.,: "level1 = IV", "level2 = M", "level3 = DV")
- Get community feedback
