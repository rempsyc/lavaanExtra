# nice_fit regular

    Code
      lavaan_defined(fit)
    Output
           User-Defined Parameter                       Paths           b   CI_lower
      30   ageyr → visual → speed   ageyr_visual*visual_speed -0.08983914 -0.1448924
      31 ageyr → visual → textual ageyr_visual*visual_textual -0.14511033 -0.2272652
      32   grade → visual → speed   grade_visual*visual_speed  0.31043593  0.1675249
      33 grade → visual → textual grade_visual*visual_textual  0.50142352  0.3027830
            CI_upper          B         SE         Z            p CI_lower_B
      30 -0.03478593 -0.1508037 0.04339660 -3.475013 5.108293e-04 -0.2358595
      31 -0.06295550 -0.1534909 0.04266095 -3.597924 3.207668e-04 -0.2371048
      32  0.45334698  0.2477787 0.04969467  4.986021 6.163552e-07  0.1503789
      33  0.70006406  0.2521937 0.04695364  5.371122 7.824837e-08  0.1601663
          CI_upper_B
      30 -0.06574796
      31 -0.06987694
      32  0.34517843
      33  0.34422119

# nice_fit total effects

    Code
      lavaan_defined(fit)
    Output
        User-Defined Parameter   Paths         b  CI_lower  CI_upper         B
      7                     ab     a*b 0.3735964 0.1931847 0.5540081 0.2845821
      8                  total c+(a*b) 0.4099510 0.1655162 0.6543859 0.3122748
                SE        Z            p CI_lower_B CI_upper_B
      7 0.06160894 4.619168 3.852813e-06  0.1638308  0.4053334
      8 0.08802080 3.547738 3.885542e-04  0.1397572  0.4847923

# nice_fit multiple symbols, lhs, rhs

    Code
      lavaan_defined(fit, underscores_to_symbol = c("*", "+", "|", "~"), lhs_name = "Special Parameters",
      rhs_name = "Some paths")
    Output
               Special Parameters                  Some paths           b   CI_lower
      30   ageyr * visual * speed   ageyr_visual*visual_speed -0.08983914 -0.1448924
      31 ageyr + visual + textual ageyr_visual*visual_textual -0.14511033 -0.2272652
      32   grade | visual | speed   grade_visual*visual_speed  0.31043593  0.1675249
      33 grade ~ visual ~ textual grade_visual*visual_textual  0.50142352  0.3027830
            CI_upper          B         SE         Z            p CI_lower_B
      30 -0.03478593 -0.1508037 0.04339660 -3.475013 5.108293e-04 -0.2358595
      31 -0.06295550 -0.1534909 0.04266095 -3.597924 3.207668e-04 -0.2371048
      32  0.45334698  0.2477787 0.04969467  4.986021 6.163552e-07  0.1503789
      33  0.70006406  0.2521937 0.04695364  5.371122 7.824837e-08  0.1601663
          CI_upper_B
      30 -0.06574796
      31 -0.06987694
      32  0.34517843
      33  0.34422119

