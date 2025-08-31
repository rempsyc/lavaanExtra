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
    lavaan_reg(fit),
    c("lavaan.data.frame", "data.frame")
  )
})

test_that("nice_fit as nice_table", {
  skip_if_not_installed("rempsyc")
  expect_s3_class(
    lavaan_reg(fit, nice_table = TRUE),
    c("nice_table", "flextable")
  )
})

test_that("lavaan_reg with bootstrap standardized_se", {
  # Test bootstrap SE for standardized estimates
  set.seed(123)
  fit_bootstrap <- sem(HS.model, data = HolzingerSwineford1939, se = "bootstrap", bootstrap = 50)
  
  # Test that bootstrap method gives different results than delta method
  result_delta <- lavaan_reg(fit_bootstrap, standardized_se = "delta")
  result_bootstrap <- lavaan_reg(fit_bootstrap, standardized_se = "bootstrap")
  
  # Check that results have same structure
  expect_equal(names(result_delta), names(result_bootstrap))
  expect_equal(nrow(result_delta), nrow(result_bootstrap))
  
  # Check that standardized coefficients are the same 
  expect_equal(result_delta$B, result_bootstrap$B)
  
  # Check that CI bounds are different (key feature being tested)
  expect_false(identical(result_delta$CI_lower_B, result_bootstrap$CI_lower_B))
  expect_false(identical(result_delta$CI_upper_B, result_bootstrap$CI_upper_B))
})

test_that("lavaan_reg standardized_se validation", {
  # Test that invalid standardized_se values throw error
  expect_error(
    lavaan_reg(fit, standardized_se = "invalid"),
    "standardized_se must be one of 'delta', 'bootstrap', or 'model'"
  )
})

test_that("lavaan_reg model auto-detection", {
  # Test that "model" option correctly detects delta method for regular fit
  result_model <- lavaan_reg(fit, standardized_se = "model")
  result_delta <- lavaan_reg(fit, standardized_se = "delta")
  
  expect_equal(result_model, result_delta)
  expect_equal(attr(result_model, "standardized_se_method"), "delta")
  
  # Test that "model" option correctly detects bootstrap method for bootstrap fit
  set.seed(123)
  fit_bootstrap <- sem(HS.model, data = HolzingerSwineford1939, se = "bootstrap", bootstrap = 50)
  
  result_model_boot <- lavaan_reg(fit_bootstrap, standardized_se = "model")
  result_bootstrap_explicit <- lavaan_reg(fit_bootstrap, standardized_se = "bootstrap")
  
  expect_equal(result_model_boot, result_bootstrap_explicit)
  expect_equal(attr(result_model_boot, "standardized_se_method"), "bootstrap")
})
