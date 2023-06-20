skip_if_not_installed("lavaan")

suppressWarnings(library(lavaan))

# Define our other variables
M <- "visual"
IV <- c("ageyr", "grade")
DV <- c("speed", "textual")

# Define our lavaan lists
mediation <- list(speed = M, textual = M, visual = IV)
regression <- list(speed = IV, textual = IV)
covariance <- list(speed = "textual", ageyr = "grade")
latent <- list(
  visual = paste0("x", 1:3),
  textual = paste0("x", 4:6),
  speed = paste0("x", 7:9)
)

# Define indirect effects object
indirect <- list(IV = IV, M = M, DV = DV)

# Special cases
intercept <- c("mpg", "cyl", "disp")
constraint.equal <- list(b1 = "(b2 + b3)^2")
constraint.smaller <- list(b1 = "exp(b2 + b3)")
constraint.larger <- list(b1 = "exp(b2 + b3)")
custom <- "y1 + y2 ~ f1 + f2 + x1 + x2"


#   ____________________________________________________________________________
#   Tests                                                                   ####

test_that("write_lavaan using latent", {
  HS.model <- write_lavaan(latent = latent)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [-----Latent variables (measurement model)-----]

visual =~ x1 + x2 + x3
textual =~ x4 + x5 + x6
speed =~ x7 + x8 + x9\n\n"
    )
  )
})

test_that("write_lavaan using regression", {
  HS.model <- write_lavaan(regression = regression)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [---------Regressions (Direct effects)---------]

speed ~ ageyr + grade
textual ~ ageyr + grade\n\n"
    )
  )
})

test_that("write_lavaan using covariance", {
  HS.model <- write_lavaan(covariance = covariance)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [------------------Covariances-----------------]

speed ~~ textual
ageyr ~~ grade\n\n"
    )
  )
})

test_that("write_lavaan using mediation", {
  HS.model <- write_lavaan(mediation = mediation)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [-----------Mediations (named paths)-----------]

speed ~ visual
textual ~ visual
visual ~ ageyr + grade\n\n"
    )
  )
})

test_that("write_lavaan using mediation with labels", {
  HS.model <- write_lavaan(mediation = mediation, label = TRUE)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [-----------Mediations (named paths)-----------]

speed ~ visual_speed*visual
textual ~ visual_textual*visual
visual ~ ageyr_visual*ageyr + grade_visual*grade\n\n"
    )
  )
})

test_that("write_lavaan using mediation with letters", {
  HS.model <- write_lavaan(
    mediation = mediation,
    label = TRUE, use.letters = TRUE
  )
  expect_equal(
    HS.model,
    c(
      "##################################################
# [-----------Mediations (named paths)-----------]

speed ~ a_speed*visual
textual ~ a_textual*visual
visual ~ a_visual*ageyr + b_visual*grade\n\n"
    )
  )
})

test_that("write_lavaan using mediation with letters and indirect", {
  HS.model <- write_lavaan(
    mediation = mediation, indirect = indirect,
    label = TRUE, use.letters = TRUE
  )
  expect_equal(
    HS.model,
    c(
      "##################################################
# [-----------Mediations (named paths)-----------]

speed ~ a_speed*visual
textual ~ a_textual*visual
visual ~ a_visual*ageyr + b_visual*grade

##################################################
# [--------Mediations (indirect effects)---------]

ageyr_visual_speed := ageyr_visual * visual_speed
ageyr_visual_textual := ageyr_visual * visual_textual
grade_visual_speed := grade_visual * visual_speed
grade_visual_textual := grade_visual * visual_textual\n\n"
    )
  )
})


test_that("write_lavaan using indirect", {
  HS.model <- write_lavaan(indirect = indirect)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [--------Mediations (indirect effects)---------]

ageyr_visual_speed := ageyr_visual * visual_speed
ageyr_visual_textual := ageyr_visual * visual_textual
grade_visual_speed := grade_visual * visual_speed
grade_visual_textual := grade_visual * visual_textual\n\n"
    )
  )
})

test_that("write_lavaan using manual indirect", {
  indirect <- list(
    ageyr_visual_speed = c("ageyr_visual", "visual_speed"),
    ageyr_visual_textual = c("ageyr_visual", "visual_textual"),
    grade_visual_speed = c("grade_visual", "visual_speed"),
    grade_visual_textual = c("grade_visual", "visual_textual")
  )
  HS.model <- write_lavaan(indirect = indirect)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [--------Mediations (indirect effects)---------]

ageyr_visual_speed := ageyr_visual * visual_speed
ageyr_visual_textual := ageyr_visual * visual_textual
grade_visual_speed := grade_visual * visual_speed
grade_visual_textual := grade_visual * visual_textual\n\n"
    )
  )
})

test_that("write_lavaan using intercept", {
  HS.model <- write_lavaan(intercept = intercept)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [------------------Intercepts------------------]

mpg ~ 1
cyl ~ 1
disp ~ 1\n\n"
    )
  )
})

test_that("write_lavaan using constraint.equal", {
  HS.model <- write_lavaan(constraint.equal = constraint.equal)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [-----------------Constraints------------------]

b1 == (b2 + b3)^2\n\n"
    )
  )
})

test_that("write_lavaan using constraint.smaller", {
  HS.model <- write_lavaan(constraint.smaller = constraint.smaller)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [-----------------Constraints------------------]

b1 < exp(b2 + b3)\n\n"
    )
  )
})

test_that("write_lavaan using constraint.larger", {
  HS.model <- write_lavaan(constraint.larger = constraint.larger)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [-----------------Constraints------------------]

b1 > exp(b2 + b3)\n\n"
    )
  )
})

test_that("write_lavaan using custom", {
  HS.model <- write_lavaan(custom = custom)
  expect_equal(
    HS.model,
    c(
      "##################################################
# [------------Custom Specifications-------------]

y1 + y2 ~ f1 + f2 + x1 + x2"
    )
  )
})

test_that("write_lavaan using everything", {
  HS.model <- write_lavaan(
    mediation, regression, covariance,
    indirect, latent, intercept, constraint.equal,
    constraint.smaller, constraint.larger, custom,
    label = TRUE
  )
  expect_equal(
    HS.model,
    c(
      "##################################################
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
# [-----------------Constraints------------------]

b1 == (b2 + b3)^2
b1 < exp(b2 + b3)
b1 > exp(b2 + b3)

##################################################
# [------------Custom Specifications-------------]

y1 + y2 ~ f1 + f2 + x1 + x2"
    )
  )
})
