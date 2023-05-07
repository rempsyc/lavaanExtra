# Development objectives (to-do list)

- `cfa_fit_plot`, add covariances of items on plot?
- All extraction functions: provide both standardized and unstandardized coefficients, as well as the 95% CI.
- `lavaan_cov`: rename r to covariance, σ(x, y) ("\U03C3"), or just covariance for simplicity if people are not likely to understand that.
- Create new function: `lavaan_cor` (then keep r but remove residual covariances)
- Add 95% confidence intervals whenever possible
- `nice_tidySEM`: improve algorithm when odd number of variables for layout matrix by adding two empty rows around the odd levels, and one empty row in the middle of the even levels.
- Add automatic covariances (specify levels, e.g.,: "level1 = IV", "level2 = M", "level3 = DV")
- Get community feedback
