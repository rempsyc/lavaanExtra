# Development objectives (to-do list)

- `cfa_fit_plot`, add covariances of items on plot? Problem is that is does not keep a vertical structure so does not look pretty when putting the default to `TRUE`. Perhaps there is a programmatic way in `lavaanPlot` to specify a vertical structure at all times.
- `nice_fit`: automatically pick robust fit indices, if available(?)
- `nice_tidySEM`: 
  - Allow specifying BOTH standardized and unstandardized coefficients on the same figure, e.g., `c("b", "B")`.
  - improve algorithm when odd number of variables for layout matrix by adding two empty rows around the odd levels, and one empty row in the middle of the even levels?
- Add automatic covariances (specify levels, e.g.,: "level1 = IV", "level2 = M", "level3 = DV")
- Get community feedback
