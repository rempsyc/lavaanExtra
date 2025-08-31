# Test file for comprehensive indirect effects discovery (x.boot-inspired)

test_that("discover_all_indirect_effects works with simple mediation", {
  skip_if_not_installed("lavaan")
  
  # Simple mediation model: X -> M -> Y
  model <- "
    M ~ a*X
    Y ~ b*M + c*X
  "
  
  indirect_effects <- discover_all_indirect_effects(model, max_chain_length = 3)
  
  # Should discover the indirect effect X -> M -> Y
  expect_true(length(indirect_effects) >= 1)
  expect_true(any(grepl("X.*M.*Y", names(indirect_effects))))
})

test_that("discover_all_indirect_effects handles complex models", {
  skip_if_not_installed("lavaan")
  
  # Complex model with multiple mediators
  model <- "
    M1 ~ a1*X
    M2 ~ a2*X + b1*M1
    Y ~ c1*X + b2*M1 + b3*M2
  "
  
  indirect_effects <- discover_all_indirect_effects(model, max_chain_length = 4)
  
  # Should find multiple indirect pathways
  expect_true(length(indirect_effects) >= 2)
  
  # Should find X -> M1 -> Y pathway
  expect_true(any(grepl("X.*M1.*Y", names(indirect_effects))))
  
  # Should find X -> M2 -> Y pathway  
  expect_true(any(grepl("X.*M2.*Y", names(indirect_effects))))
})

test_that("write_lavaan with indirect = TRUE uses comprehensive discovery", {
  skip_if_not_installed("lavaan")
  
  # Define model components
  mediation <- list(M = "X", Y = "M")
  regression <- list(Y = "X")
  
  # Test comprehensive indirect effects discovery
  model_with_auto <- write_lavaan(
    mediation = mediation,
    regression = regression, 
    indirect = TRUE,
    label = TRUE,
    auto_indirect_max_length = 3,
    auto_indirect_limit = 50
  )
  
  expect_true(grepl("indirect effects", model_with_auto))
  expect_true(grepl(":=", model_with_auto))
})

test_that("write_lavaan backward compatibility maintained", {
  skip_if_not_installed("lavaan")
  
  # Test that existing IV/M/DV functionality still works
  mediation <- list(M = "X", Y = "M") 
  indirect <- list(IV = "X", M = "M", DV = "Y")
  
  model_structured <- write_lavaan(
    mediation = mediation,
    indirect = indirect,
    label = TRUE
  )
  
  expect_true(grepl("X_M.*M_Y", model_structured))
})

test_that("write_lavaan manual indirect effects still work", {
  skip_if_not_installed("lavaan")
  
  # Test manual specification
  manual_indirect <- list(
    indirect1 = c("path1", "path2"),
    indirect2 = c("path3", "path4")
  )
  
  model_manual <- write_lavaan(indirect = manual_indirect)
  
  expect_true(grepl("indirect1 := path1 \\* path2", model_manual))
  expect_true(grepl("indirect2 := path3 \\* path4", model_manual))
})

test_that("discover_all_indirect_effects respects computational limits", {
  skip_if_not_installed("lavaan")
  
  # Create a model that could generate many paths
  model <- "
    M1 ~ X1 + X2
    M2 ~ X1 + X2 + M1
    M3 ~ X1 + X2 + M1 + M2
    Y ~ X1 + X2 + M1 + M2 + M3
  "
  
  # Test with low limit
  indirect_effects <- discover_all_indirect_effects(
    model, 
    max_chain_length = 4,
    computational_limit = 10
  )
  
  # Should respect the limit
  expect_true(length(indirect_effects) <= 10)
})

test_that("discover_all_indirect_effects handles edge cases", {
  skip_if_not_installed("lavaan")
  
  # Test with empty model
  expect_equal(discover_all_indirect_effects(""), list())
  
  # Test with only latent variables (no structural paths)
  latent_only <- "F1 =~ x1 + x2 + x3"
  expect_equal(discover_all_indirect_effects(latent_only), list())
  
  # Test with only covariances
  cov_only <- "x1 ~~ x2"
  expect_equal(discover_all_indirect_effects(cov_only), list())
})

test_that("x.boot integration preserves existing functionality", {
  skip_if_not_installed("lavaan")
  
  # Ensure all existing write_lavaan tests still pass with new parameters
  mediation <- list(speed = "visual", textual = "visual", visual = c("ageyr", "grade"))
  regression <- list(speed = c("ageyr", "grade"), textual = c("ageyr", "grade"))
  
  # Test that existing functionality is unchanged
  model_old <- write_lavaan(mediation = mediation, regression = regression)
  model_new <- write_lavaan(
    mediation = mediation, 
    regression = regression,
    auto_indirect_max_length = 5,
    auto_indirect_limit = 1000
  )
  
  expect_equal(model_old, model_new)
})