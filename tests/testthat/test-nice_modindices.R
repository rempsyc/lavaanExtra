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

data_labels <- data.frame(
  x1 = "I have good visual perception",
  x2 = "I have good cube perception",
  x3 = "I have good at lozenge perception",
  x4 = "I have paragraph comprehension",
  x5 = "I am good at sentence completion",
  x6 = "I excel at finding the meaning of words",
  x7 = "I am quick at doing mental additions",
  x8 = "I am quick at counting dots",
  x9 = "I am quick at discriminating straight and curved capitals"
)

#   ____________________________________________________________________________
#   Tests                                                                   ####

test_that("nice_modindices regular", {
  skip_if_not_installed("sjlabelled")
  expect_snapshot(
    nice_modindices(fit, maximum.number = 5)
  )
})

test_that("nice_modindices labels", {
  skip_if_not_installed("stringdist")
  expect_snapshot(
    nice_modindices(
      fit,
      maximum.number = 10,
      labels = data_labels, op = "~~"
    )
  )
})

test_that("nice_modindices auto-labels", {
  skip_if_not_installed("sjlabelled")
  skip_if_not_installed("stringdist")
  x <- HolzingerSwineford1939
  x <- sjlabelled::set_label(x, label = paste0("I am ", seq_len(ncol(x)), " years old."))
  fit <- sem(HS.model, data = x)

  expect_snapshot(
    nice_modindices(
      fit,
      maximum.number = 10,
      op = "~~"
    )
  )
})

# Additional tests to improve coverage

test_that("nice_modindices without labels", {
  skip_if_not_installed("sjlabelled")
  # Test the path when no labels are available 
  result <- nice_modindices(fit, maximum.number = 5)
  expect_s3_class(result, "data.frame")
  expect_equal(ncol(result), 4) # Should have 4 columns without labels
  expect_true(all(c("lhs", "op", "rhs", "mi") %in% names(result)))
})

test_that("nice_modindices with sort = FALSE", {
  skip_if_not_installed("sjlabelled")
  # Test the sort parameter
  result <- nice_modindices(fit, sort = FALSE, maximum.number = 5)
  expect_s3_class(result, "data.frame")
})

test_that("nice_modindices with different method", {
  skip_if_not_installed("stringdist")
  # Test different similarity method
  result <- nice_modindices(fit, labels = data_labels, method = "jw", maximum.number = 5)
  expect_s3_class(result, "data.frame")
  expect_true("similarity" %in% names(result))
})

test_that("nice_modindices with partial label matching", {
  skip_if_not_installed("stringdist")
  # Test with labels that only partially match the variables
  partial_labels <- data.frame(
    x1 = "Label for x1",
    x5 = "Label for x5",
    x9 = "Label for x9"
  )
  result <- nice_modindices(fit, labels = partial_labels, maximum.number = 10)
  expect_s3_class(result, "data.frame")
  expect_true("lhs.labels" %in% names(result))
  expect_true("rhs.labels" %in% names(result))
  expect_true("similarity" %in% names(result))
})

test_that("nice_modindices with labels as named vector", {
  skip_if_not_installed("stringdist")
  # Test with labels as named vector instead of data.frame
  vector_labels <- c(
    x1 = "Label for x1",
    x2 = "Label for x2", 
    x3 = "Label for x3"
  )
  result <- nice_modindices(fit, labels = vector_labels, maximum.number = 5)
  expect_s3_class(result, "data.frame")
  expect_true("similarity" %in% names(result))
})

test_that("nice_modindices handles empty labels", {
  skip_if_not_installed("sjlabelled")
  # Test the case where labels exist but are all empty
  x <- HolzingerSwineford1939
  x <- sjlabelled::set_label(x, label = rep("", ncol(x)))
  fit_empty <- sem(HS.model, data = x)
  
  result <- nice_modindices(fit_empty, maximum.number = 5)
  expect_s3_class(result, "data.frame")
  expect_equal(ncol(result), 4) # Should not have label columns
})

test_that("nice_modindices with no matching labels", {
  skip_if_not_installed("stringdist")
  # Test with labels that don't match any variables
  no_match_labels <- data.frame(
    y1 = "Label for y1",
    y2 = "Label for y2"
  )
  result <- nice_modindices(fit, labels = no_match_labels, maximum.number = 5)
  expect_s3_class(result, "data.frame")
  expect_true("similarity" %in% names(result))
  expect_true(all(is.na(result$similarity)))
})

test_that("nice_modindices with additional lavaan parameters", {
  skip_if_not_installed("sjlabelled")
  # Test passing additional parameters to lavaan::modindices
  result <- nice_modindices(fit, minimum.value = 1, maximum.number = 3)
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) <= 3)
})
