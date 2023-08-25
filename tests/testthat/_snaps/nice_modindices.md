# nice_modindices regular

    Code
      nice_modindices(fit, maximum.number = 5)
    Output
            lhs op rhs     mi
      1  visual =~  x9 35.699
      2  visual =~  x7 16.659
      3 textual =~  x3  9.833
      4      x2 ~~  x7  9.673
      5      x7 ~~  x8  9.479

# nice_modindices labels

    Code
      nice_modindices(fit, maximum.number = 10, labels = data_labels, op = "~~")
    Output
        lhs op rhs    mi                           lhs.labels
      1  x2 ~~  x7 9.673          I have good cube perception
      2  x7 ~~  x8 9.479 I am quick at doing mental additions
      3  x2 ~~  x3 8.746          I have good cube perception
      4  x1 ~~  x9 8.408        I have good visual perception
      5  x3 ~~  x5 7.601    I have good at lozenge perception
                                                       rhs.labels similarity similar
      1                      I am quick at doing mental additions      0.381   FALSE
      2                               I am quick at counting dots      0.698    TRUE
      3                         I have good at lozenge perception      0.800    TRUE
      4 I am quick at discriminating straight and curved capitals      0.326   FALSE
      5                          I am good at sentence completion      0.677    TRUE

# nice_modindices auto-labels

    Code
      nice_modindices(fit, maximum.number = 10, op = "~~")
    Output
        lhs op rhs    mi
      1  x2 ~~  x7 9.673
      2  x7 ~~  x8 9.479
      3  x2 ~~  x3 8.746
      4  x1 ~~  x9 8.408
      5  x3 ~~  x5 7.601

