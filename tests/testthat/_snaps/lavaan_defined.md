# nice_fit regular

    Code
      lavaan_defined(fit)
    Output
         User.Defined.Parameter                       Paths     p      B CI_lower
      30 ageyr → visual → speed   ageyr_visual*visual_speed 0.001 -0.151   -0.236
      31 ageyr → visual → speed ageyr_visual*visual_textual 0.000 -0.153   -0.237
      32 ageyr → visual → speed   grade_visual*visual_speed 0.000  0.248    0.150
      33 ageyr → visual → speed grade_visual*visual_textual 0.000  0.252    0.160
         CI_upper
      30   -0.066
      31   -0.070
      32    0.345
      33    0.344

# nice_fit as nice_table

    Code
      lavaan_defined(fit, nice_table = TRUE)
    Output
      a flextable object.
      col_keys: `User-Defined Parameter`, `Paths`, `p`, `B`, `95% CI` 
      header has 1 row(s) 
      body has 4 row(s) 
      original dataset sample: 
         User-Defined Parameter                       Paths            p          B
      30 ageyr → visual → speed   ageyr_visual*visual_speed 5.108293e-04 -0.1508037
      31 ageyr → visual → speed ageyr_visual*visual_textual 3.207669e-04 -0.1534909
      32 ageyr → visual → speed   grade_visual*visual_speed 6.163554e-07  0.2477787
      33 ageyr → visual → speed grade_visual*visual_textual 7.824837e-08  0.2521937
                 95% CI
      30 [-0.24, -0.07]
      31 [-0.24, -0.07]
      32   [0.15, 0.35]
      33   [0.16, 0.34]

# nice_fit estimates

    Code
      lavaan_defined(fit, estimate = "b")
    Output
         User.Defined.Parameter                       Paths     p      b CI_lower
      30 ageyr → visual → speed   ageyr_visual*visual_speed 0.001 -0.090   -0.145
      31 ageyr → visual → speed ageyr_visual*visual_textual 0.001 -0.145   -0.227
      32 ageyr → visual → speed   grade_visual*visual_speed 0.000  0.310    0.168
      33 ageyr → visual → speed grade_visual*visual_textual 0.000  0.501    0.303
         CI_upper
      30   -0.035
      31   -0.063
      32    0.453
      33    0.700

---

    Code
      lavaan_defined(fit, estimate = "B")
    Output
         User.Defined.Parameter                       Paths     p      B CI_lower
      30 ageyr → visual → speed   ageyr_visual*visual_speed 0.001 -0.151   -0.236
      31 ageyr → visual → speed ageyr_visual*visual_textual 0.000 -0.153   -0.237
      32 ageyr → visual → speed   grade_visual*visual_speed 0.000  0.248    0.150
      33 ageyr → visual → speed grade_visual*visual_textual 0.000  0.252    0.160
         CI_upper
      30   -0.066
      31   -0.070
      32    0.345
      33    0.344

# nice_fit multiple symbols, lhs, rhs

    Code
      lavaan_defined(fit, underscores_to_symbol = c("*", "+", "|", "~"), lhs_name = "Special Parameters",
      rhs_name = "Some paths")
    Output
               Special.Parameters                  Some.paths     p      B CI_lower
      30   ageyr * visual * speed   ageyr_visual*visual_speed 0.001 -0.151   -0.236
      31 ageyr + visual + textual ageyr_visual*visual_textual 0.000 -0.153   -0.237
      32   grade | visual | speed   grade_visual*visual_speed 0.000  0.248    0.150
      33 grade ~ visual ~ textual grade_visual*visual_textual 0.000  0.252    0.160
         CI_upper
      30   -0.066
      31   -0.070
      32    0.345
      33    0.344

