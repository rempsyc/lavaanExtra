# nice_modindices regular

    Code
      nice_modindices(fit, maximum.number = 5)
    Output
            lhs op   rhs     mi
      1  visual =~    x9 35.699
      2  visual =~    x7 16.659
      3      x7 ~~ grade 16.511
      4      x7 ~~ ageyr 10.030
      5 textual =~    x3  9.833

# nice_modindices labels

    Code
      nice_modindices(fit, maximum.number = 10, labels = data_labels, op = "~~")
    Output
        lhs op   rhs     mi                           lhs.labels
      1  x7 ~~ grade 16.511 I am quick at doing mental additions
      2  x7 ~~ ageyr 10.030 I am quick at doing mental additions
      3  x2 ~~    x7  9.673          I have good cube perception
      4  x7 ~~    x8  9.479 I am quick at doing mental additions
      5  x2 ~~    x3  8.746          I have good cube perception
      6  x1 ~~    x9  8.408        I have good visual perception
                                                       rhs.labels similarity similar
      1                                                      <NA>         NA   FALSE
      2                                                      <NA>         NA   FALSE
      3                      I am quick at doing mental additions      0.381   FALSE
      4                               I am quick at counting dots      0.698    TRUE
      5                         I have good at lozenge perception      0.800    TRUE
      6 I am quick at discriminating straight and curved capitals      0.326   FALSE

# nice_modindices auto-labels

    Code
      nice_modindices(fit, maximum.number = 10, op = "~~")
    Output
        lhs op   rhs     mi
      1  x7 ~~ grade 16.511
      2  x7 ~~ ageyr 10.030
      3  x2 ~~    x7  9.673
      4  x7 ~~    x8  9.479
      5  x2 ~~    x3  8.746
      6  x1 ~~    x9  8.408

