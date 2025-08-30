suppressWarnings(library(lavaan))

latent <- list(
  visual = paste0("x", 1:3),
  textual = paste0("x", 4:6),
  speed = paste0("x", 7:9)
)

mediation <- list(
  speed = "visual",
  textual = "visual",
  visual = c("ageyr", "grade")
)

indirect <- list(
  IV = c("ageyr", "grade"),
  M = "visual",
  DV = c("speed", "textual")
)

HS.model <- write_lavaan(mediation,
  indirect = indirect,
  latent = latent, label = TRUE
)

fit <- sem(HS.model, data = HolzingerSwineford1939)

#   ____________________________________________________________________________
#   Tests                                                                   ####


test_that("nice_fit regular", {
  expect_snapshot(
    lavaan_defined(fit)
  )
})

test_that("nice_fit as nice_table", {
  skip_on_os("linux")
  skip_if_not_installed("rempsyc")
  expect_snapshot(
    lavaan_defined(fit, nice_table = TRUE)
  )
})

test_that("nice_fit total effects", {
  set.seed(1234)
  X <- rnorm(100)
  M <- 0.5*X + rnorm(100)
  Y <- 0.7*M + rnorm(100)
  Data <- data.frame(X = X, Y = Y, M = M)
  mediation <- list(
    Y = "c*X",
    M = "a*X",
    Y = "b*M"
  )
  indirect <- list(
    ab = "a*b",
    total = "c + (a*b)"
  )
  model <- write_lavaan(mediation = mediation, indirect = indirect)
  fit <- sem(model, data = Data)
  expect_snapshot(
    lavaan_defined(fit)
  )
})

test_that("nice_fit multiple symbols, lhs, rhs", {
  latent <- list(visual = paste0("x", 1:3), textual = paste0("x", 4:6), speed = paste0("x", 7:9))
  mediation <- list(speed = "visual", textual = "visual", visual = c("ageyr", "grade"))
  indirect <- list(IV = c("ageyr", "grade"), M = "visual", DV = c("speed", "textual"))
  HS.model <- write_lavaan(mediation, indirect = indirect, latent = latent, label = TRUE)
  fit <- sem(HS.model, data = HolzingerSwineford1939)
  expect_snapshot(
    lavaan_defined(fit,
      underscores_to_symbol = c("*", "+", "|", "~"),
      lhs_name = "Special Parameters",
      rhs_name = "Some paths"
    )
  )
})

test_that("lavaan_defined with bootstrap standardized_se", {
  # Test bootstrap SE for standardized estimates
  set.seed(123)
  fit_bootstrap <- sem(HS.model, data = HolzingerSwineford1939, se = "bootstrap", bootstrap = 50)
  
  # Test that bootstrap method gives different results than delta method
  result_delta <- lavaan_defined(fit_bootstrap, standardized_se = "delta")
  result_bootstrap <- lavaan_defined(fit_bootstrap, standardized_se = "bootstrap")
  
  # Check that results have same structure
  expect_equal(names(result_delta), names(result_bootstrap))
  expect_equal(nrow(result_delta), nrow(result_bootstrap))
  
  # Check that standardized coefficients are the same 
  expect_equal(result_delta$B, result_bootstrap$B)
  
  # Check that CI bounds are different (key feature being tested)
  expect_false(identical(result_delta$CI_lower_B, result_bootstrap$CI_lower_B))
  expect_false(identical(result_delta$CI_upper_B, result_bootstrap$CI_upper_B))
})

test_that("lavaan_defined standardized_se validation", {
  # Test that invalid standardized_se values throw error
  expect_error(
    lavaan_defined(fit, standardized_se = "invalid"),
    "standardized_se must be either 'delta' or 'bootstrap'"
  )
})
