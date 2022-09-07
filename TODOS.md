# Development objectives (to-do list)

- All extraction functions: provide both standardized and unstandardized coefficients, as well as the 95% CI.
- `lavaan_cov`: rename r for something else
- `nice_tidySEM`: improve algorithm when odd number of variables for layout matrix by adding two empty rows around the odd levels, and one empty row in the middle of the even levels.
- Automatic indirect effects: fix bug when length(DV) != 2 
- Add automatic covariances (specify levels, e.g.,: "level1 = IV", "level2 = M", "level3 = DV")
- Get community feedback
