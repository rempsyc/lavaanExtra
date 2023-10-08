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
threshold <- list(y2w1 = "thr1*t1", y2w2 = "thr2*t1")

#   ____________________________________________________________________________
#   Tests                                                                   ####

test_that("write_lavaan using latent", {
  expect_snapshot(cat(write_lavaan(latent = latent)))
})

test_that("write_lavaan using regression", {
  expect_snapshot(cat(write_lavaan(regression = regression)))
})

test_that("write_lavaan using covariance", {
  expect_snapshot(cat(write_lavaan(covariance = covariance)))
})

test_that("write_lavaan using mediation", {
  expect_snapshot(cat(write_lavaan(mediation = mediation)))
})

test_that("write_lavaan using mediation with labels", {
  expect_snapshot(cat(write_lavaan(mediation = mediation, label = TRUE)))
})

test_that("write_lavaan using mediation with letters", {
  expect_snapshot(cat(write_lavaan(
    mediation = mediation,
    label = TRUE,
    use.letters = TRUE
  )))
})

test_that("write_lavaan using mediation with letters and indirect", {
  expect_snapshot(cat(write_lavaan(
    mediation = mediation,
    indirect = indirect,
    label = TRUE,
    use.letters = TRUE
  )))
})


test_that("write_lavaan using indirect", {
  expect_snapshot(cat(write_lavaan(indirect = indirect, label = TRUE)))
})

test_that("write_lavaan using manual indirect", {
  indirect <- list(
    ageyr_visual_speed = c("ageyr_visual", "visual_speed"),
    ageyr_visual_textual = c("ageyr_visual", "visual_textual"),
    grade_visual_speed = c("grade_visual", "visual_speed"),
    grade_visual_textual = c("grade_visual", "visual_textual")
  )
  expect_snapshot(cat(write_lavaan(indirect = indirect, label = TRUE)))
})

test_that("write_lavaan using intercept", {
  expect_snapshot(cat(write_lavaan(intercept = intercept)))
})

test_that("write_lavaan using constraint.equal", {
  expect_snapshot(cat(write_lavaan(constraint.equal = constraint.equal)))
})

test_that("write_lavaan using constraint.smaller", {
  expect_snapshot(cat(write_lavaan(constraint.smaller = constraint.smaller)))
})

test_that("write_lavaan using constraint.larger", {
  expect_snapshot(cat(write_lavaan(constraint.larger = constraint.larger)))
})

test_that("write_lavaan using custom", {
  expect_snapshot(cat(write_lavaan(custom = custom)))
})

test_that("write_lavaan using everything", {
  expect_snapshot(cat(write_lavaan(
    mediation = mediation,
    regression = regression,
    covariance = covariance,
    indirect = indirect,
    latent = latent,
    intercept = intercept,
    threshold = threshold,
    constraint.equal = constraint.equal,
    constraint.smaller = constraint.smaller,
    constraint.larger = constraint.larger,
    custom = custom,
    label = TRUE
  )))
})
