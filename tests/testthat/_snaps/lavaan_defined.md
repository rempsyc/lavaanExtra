# nice_fit regular

    Code
      lavaan_defined(fit)
    Output
           User-Defined Parameter                       Paths         SE         Z
      30   ageyr → visual → speed   ageyr_visual*visual_speed 0.02808889 -3.198387
      31 ageyr → visual → textual ageyr_visual*visual_textual 0.04191650 -3.461890
      32   grade → visual → speed   grade_visual*visual_speed 0.07291514  4.257496
      33 grade → visual → textual grade_visual*visual_textual 0.10134908  4.947490
                    p           b   CI_lower    CI_upper          B CI_lower_B
      30 1.381987e-03 -0.08983914 -0.1448924 -0.03478593 -0.1508037 -0.2358595
      31 5.363956e-04 -0.14511033 -0.2272652 -0.06295550 -0.1534909 -0.2371048
      32 2.067294e-05  0.31043593  0.1675249  0.45334698  0.2477787  0.1503789
      33 7.517664e-07  0.50142352  0.3027830  0.70006406  0.2521937  0.1601663
          CI_upper_B
      30 -0.06574796
      31 -0.06987694
      32  0.34517843
      33  0.34422119

# nice_fit as nice_table

    Code
      lavaan_defined(fit, nice_table = TRUE)
    Output
      a flextable object.
      col_keys: `User-Defined Parameter`, `Paths`, `SE`, `Z`, `p`, `b`, `95% CI (b)`, `B`, `95% CI (B)` 
      header has 1 row(s) 
      body has 4 row(s) 
      original dataset sample: 
           User-Defined Parameter                       Paths         SE         Z
      30   ageyr → visual → speed   ageyr_visual*visual_speed 0.02808889 -3.198387
      31 ageyr → visual → textual ageyr_visual*visual_textual 0.04191650 -3.461890
      32   grade → visual → speed   grade_visual*visual_speed 0.07291514  4.257496
      33 grade → visual → textual grade_visual*visual_textual 0.10134908  4.947490
                    p           b     95% CI (b)          B     95% CI (B)
      30 1.381987e-03 -0.08983914 [-0.14, -0.03] -0.1508037 [-0.24, -0.07]
      31 5.363956e-04 -0.14511033 [-0.23, -0.06] -0.1534909 [-0.24, -0.07]
      32 2.067294e-05  0.31043593   [0.17, 0.45]  0.2477787   [0.15, 0.35]
      33 7.517664e-07  0.50142352   [0.30, 0.70]  0.2521937   [0.16, 0.34]

# nice_fit total effects

    Code
      lavaan_defined(fit)
    Output
        User-Defined Parameter   Paths         SE        Z            p         b
      7                     ab     a*b 0.09204847 4.058692 4.934835e-05 0.3735964
      8                  total c+(a*b) 0.12471394 3.287131 1.012138e-03 0.4099510
         CI_lower  CI_upper         B CI_lower_B CI_upper_B
      7 0.1931847 0.5540081 0.2845821  0.1638308  0.4053334
      8 0.1655162 0.6543859 0.3122748  0.1397572  0.4847923

# nice_fit multiple symbols, lhs, rhs

    Code
      lavaan_defined(fit, underscores_to_symbol = c("*", "+", "|", "~"), lhs_name = "Special Parameters",
      rhs_name = "Some paths")
    Output
               Special Parameters                  Some paths         SE         Z
      30   ageyr * visual * speed   ageyr_visual*visual_speed 0.02808889 -3.198387
      31 ageyr + visual + textual ageyr_visual*visual_textual 0.04191650 -3.461890
      32   grade | visual | speed   grade_visual*visual_speed 0.07291514  4.257496
      33 grade ~ visual ~ textual grade_visual*visual_textual 0.10134908  4.947490
                    p           b   CI_lower    CI_upper          B CI_lower_B
      30 1.381987e-03 -0.08983914 -0.1448924 -0.03478593 -0.1508037 -0.2358595
      31 5.363956e-04 -0.14511033 -0.2272652 -0.06295550 -0.1534909 -0.2371048
      32 2.067294e-05  0.31043593  0.1675249  0.45334698  0.2477787  0.1503789
      33 7.517664e-07  0.50142352  0.3027830  0.70006406  0.2521937  0.1601663
          CI_upper_B
      30 -0.06574796
      31 -0.06987694
      32  0.34517843
      33  0.34422119

