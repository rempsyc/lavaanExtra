# write_lavaan using latent

    Code
      cat(write_lavaan(latent = latent))
    Output
      ##################################################
      # [-----Latent variables (measurement model)-----]
      
      visual =~ x1 + x2 + x3
      textual =~ x4 + x5 + x6
      speed =~ x7 + x8 + x9
      

# write_lavaan using regression

    Code
      cat(write_lavaan(regression = regression))
    Output
      ##################################################
      # [---------Regressions (Direct effects)---------]
      
      speed ~ ageyr + grade
      textual ~ ageyr + grade
      

# write_lavaan using covariance

    Code
      cat(write_lavaan(covariance = covariance))
    Output
      ##################################################
      # [------------------Covariances-----------------]
      
      speed ~~ textual
      ageyr ~~ grade
      

# write_lavaan using mediation

    Code
      cat(write_lavaan(mediation = mediation))
    Output
      ##################################################
      # [-----------Mediations (named paths)-----------]
      
      speed ~ visual
      textual ~ visual
      visual ~ ageyr + grade
      

# write_lavaan using mediation with labels

    Code
      cat(write_lavaan(mediation = mediation, label = TRUE))
    Output
      ##################################################
      # [-----------Mediations (named paths)-----------]
      
      speed ~ visual_speed*visual
      textual ~ visual_textual*visual
      visual ~ ageyr_visual*ageyr + grade_visual*grade
      

# write_lavaan using mediation with letters

    Code
      cat(write_lavaan(mediation = mediation, label = TRUE, use.letters = TRUE))
    Output
      ##################################################
      # [-----------Mediations (named paths)-----------]
      
      speed ~ a_speed*visual
      textual ~ a_textual*visual
      visual ~ a_visual*ageyr + b_visual*grade
      

# write_lavaan using mediation with letters and indirect

    Code
      cat(write_lavaan(mediation = mediation, indirect = indirect, label = TRUE,
        use.letters = TRUE))
    Output
      ##################################################
      # [-----------Mediations (named paths)-----------]
      
      speed ~ a_speed*visual
      textual ~ a_textual*visual
      visual ~ a_visual*ageyr + b_visual*grade
      
      ##################################################
      # [--------Mediations (indirect effects)---------]
      
      ageyr_visual_speed := ageyr_visual * visual_speed
      ageyr_visual_textual := ageyr_visual * visual_textual
      grade_visual_speed := grade_visual * visual_speed
      grade_visual_textual := grade_visual * visual_textual
      

# write_lavaan using indirect

    Code
      cat(write_lavaan(indirect = indirect, label = TRUE))
    Output
      ##################################################
      # [--------Mediations (indirect effects)---------]
      
      ageyr_visual_speed := ageyr_visual * visual_speed
      ageyr_visual_textual := ageyr_visual * visual_textual
      grade_visual_speed := grade_visual * visual_speed
      grade_visual_textual := grade_visual * visual_textual
      

# write_lavaan using manual indirect

    Code
      cat(write_lavaan(indirect = indirect, label = TRUE))
    Output
      ##################################################
      # [--------Mediations (indirect effects)---------]
      
      ageyr_visual_speed := ageyr_visual * visual_speed
      ageyr_visual_textual := ageyr_visual * visual_textual
      grade_visual_speed := grade_visual * visual_speed
      grade_visual_textual := grade_visual * visual_textual
      

# write_lavaan using intercept

    Code
      cat(write_lavaan(intercept = intercept))
    Output
      ##################################################
      # [------------------Intercepts------------------]
      
      mpg ~ 1
      cyl ~ 1
      disp ~ 1
      

# write_lavaan using constraint.equal

    Code
      cat(write_lavaan(constraint.equal = constraint.equal))
    Output
      ##################################################
      # [-----------------Constraints------------------]
      
      b1 == (b2 + b3)^2
      

# write_lavaan using constraint.smaller

    Code
      cat(write_lavaan(constraint.smaller = constraint.smaller))
    Output
      ##################################################
      # [-----------------Constraints------------------]
      
      b1 < exp(b2 + b3)
      

# write_lavaan using constraint.larger

    Code
      cat(write_lavaan(constraint.larger = constraint.larger))
    Output
      ##################################################
      # [-----------------Constraints------------------]
      
      b1 > exp(b2 + b3)
      

# write_lavaan using custom

    Code
      cat(write_lavaan(custom = custom))
    Output
      ##################################################
      # [------------Custom Specifications-------------]
      
      y1 + y2 ~ f1 + f2 + x1 + x2

# write_lavaan using everything

    Code
      cat(write_lavaan(mediation = mediation, regression = regression, covariance = covariance,
        indirect = indirect, latent = latent, intercept = intercept, threshold = threshold,
        constraint.equal = constraint.equal, constraint.smaller = constraint.smaller,
        constraint.larger = constraint.larger, custom = custom, label = TRUE))
    Output
      ##################################################
      # [-----Latent variables (measurement model)-----]
      
      visual =~ x1 + x2 + x3
      textual =~ x4 + x5 + x6
      speed =~ x7 + x8 + x9
      
      ##################################################
      # [-----------Mediations (named paths)-----------]
      
      speed ~ visual_speed*visual
      textual ~ visual_textual*visual
      visual ~ ageyr_visual*ageyr + grade_visual*grade
      
      ##################################################
      # [---------Regressions (Direct effects)---------]
      
      speed ~ ageyr + grade
      textual ~ ageyr + grade
      
      ##################################################
      # [------------------Covariances-----------------]
      
      speed ~~ textual
      ageyr ~~ grade
      
      ##################################################
      # [--------Mediations (indirect effects)---------]
      
      ageyr_visual_speed := ageyr_visual * visual_speed
      ageyr_visual_textual := ageyr_visual * visual_textual
      grade_visual_speed := grade_visual * visual_speed
      grade_visual_textual := grade_visual * visual_textual
      
      ##################################################
      # [------------------Intercepts------------------]
      
      mpg ~ 1
      cyl ~ 1
      disp ~ 1
      
      ##################################################
      # [------------------Thresholds------------------]
      
      y2w1 | thr1*t1
      y2w2 | thr2*t1
      
      ##################################################
      # [-----------------Constraints------------------]
      
      b1 == (b2 + b3)^2
      b1 < exp(b2 + b3)
      b1 > exp(b2 + b3)
      
      ##################################################
      # [------------Custom Specifications-------------]
      
      y1 + y2 ~ f1 + f2 + x1 + x2

