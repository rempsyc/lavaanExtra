suppressWarnings(library(lavaan))

latent <- list(
  visual = paste0("x", 1:3),
  textual = paste0("x", 4:6),
  speed = paste0("x", 7:9)
)

regression <- list(
  ageyr = c("visual", "textual", "speed"),
  grade = c("visual", "textual", "speed")
)

HS.model <- write_lavaan(latent = latent, regression = regression)

fit <- sem(HS.model, data = HolzingerSwineford1939)


#   ____________________________________________________________________________
#   Tests                                                                   ####


test_that("nice_fit regular", {
  expect_s3_class(
    nice_fit(fit),
    "data.frame"
  )
})

test_that("nice_fit as nice_table", {
  skip_if_not_installed("rempsyc")
  expect_s3_class(
    nice_fit(fit, nice_table = TRUE), "flextable"
  )
})

test_that("nice_fit list", {
  expect_s3_class(
    nice_fit(list(fit, fit)),
    "data.frame"
  )
})

test_that("nice_fit named list", {
  expect_s3_class(
    nice_fit(list(zz1 = fit, zz2 = fit)),
    "data.frame"
  )
})

test_that("nice_fit labels", {
  expect_s3_class(
    nice_fit(list(fit, fit), model.labels = c("First Model", "Second Model")),
    "data.frame"
  )
})


test_that("nice_fit warns on labels", {
  expect_warning(
    nice_fit(list(fit, fit), model.labels = "Second Model")
  )
  # Testing more labels
  expect_error(
    nice_fit(fit, fit, model.labels = seq(1, 10))
  )
})

test_that("nice_fit error on wrong object class", {
  expect_error(
    nice_fit(HS.model, model.labels = seq(1, 10))
  )
})

dat <- data.frame(
  z = sample(c(0, 1), 100, replace = TRUE),
  x = sample(1:7, 100, replace = TRUE),
  y = sample(1:5, 100, replace = TRUE)
)
mod <- "
  y ~ a*x
  z ~ b*y + c*x
  ind := a*b
  "
fit <- sem(mod, dat, ordered = "z")

test_that("nice_fit test categorical variable", {
  expect_s3_class(nice_fit(fit, verbose = FALSE), "data.frame")
})

test_that("nice_fit test categorical variable with nice_table", {
  skip_if_not_installed("rempsyc")
  expect_s3_class(
    nice_fit(fit, nice_table = TRUE, verbose = FALSE), "flextable"
  )
})

# Additional tests to improve coverage

test_that("nice_fit with guidelines = FALSE", {
  skip_if_not_installed("rempsyc")
  result <- nice_fit(fit, nice_table = TRUE, guidelines = FALSE, verbose = FALSE)
  expect_s3_class(result, "flextable")
})

test_that("nice_fit with stars = TRUE", {
  skip_if_not_installed("rempsyc")
  result <- nice_fit(fit, nice_table = TRUE, stars = TRUE, verbose = FALSE)
  expect_s3_class(result, "flextable")
})

test_that("nice_fit with verbose = FALSE", {
  result <- nice_fit(fit, verbose = FALSE)
  expect_s3_class(result, "data.frame")
})

test_that("nice_fit error condition - too many labels", {
  expect_error(
    nice_fit(fit, model.labels = c("Model1", "Model2", "Model3")),
    "Number of labels exceeds number of models."
  )
})

test_that("nice_fit error condition - wrong object type", {
  expect_error(
    nice_fit("not a lavaan model"),
    "Model must be of class 'lavaan'"
  )
})

test_that("nice_fit single model with custom label", {
  result <- nice_fit(fit, model.labels = "My Custom Model")
  expect_s3_class(result, "data.frame")
  expect_equal(result$Model[1], "My Custom Model")
})

test_that("nice_fit handles models without some fit indices", {
  # Test with a very simple model that might not have all fit indices
  simple_model <- "x1 ~ 1"
  simple_fit <- sem(simple_model, data = HolzingerSwineford1939[1:50, ])
  result <- nice_fit(simple_fit, verbose = FALSE)
  expect_s3_class(result, "data.frame")
})

test_that("nice_fit internal function handles different scenarios", {
  # Test the internal function directly to cover edge cases
  internal_result <- lavaanExtra:::nice_fit_internal(fit, verbose = TRUE)
  expect_s3_class(internal_result, "data.frame")
  expect_true("chi2.df" %in% names(internal_result))
})

test_that("nice_fit handles missing SRMR scenarios", {
  # This tests the SRMR fallback logic
  result <- nice_fit(fit, verbose = TRUE)
  expect_s3_class(result, "data.frame")
  expect_true("srmr" %in% names(result))
})
