# Tests for utils.R functions

test_that("get_dep_version returns correct version for existing package with version requirement", {
  # Test with rempsyc which should have version requirement "0.1.6" from DESCRIPTION
  result <- lavaanExtra:::get_dep_version("rempsyc")
  expect_type(result, "character")
  expect_length(result, 1)
  expect_equal(result, "0.1.6")
})

test_that("get_dep_version returns correct version for testthat with >= requirement", {
  # Test with testthat which should have version requirement "3.0.0" from DESCRIPTION  
  result <- lavaanExtra:::get_dep_version("testthat")
  expect_type(result, "character")
  expect_length(result, 1)
  expect_equal(result, "3.0.0")
})

test_that("get_dep_version handles multiple dependencies", {
  # Test with multiple packages
  result <- lavaanExtra:::get_dep_version(c("rempsyc", "testthat"))
  expect_type(result, "character")
  expect_length(result, 2)
  expect_equal(result[1], "0.1.6")
  expect_equal(result[2], "3.0.0")
})

test_that("get_dep_version returns NA for packages without version requirements", {
  # Test with packages that don't have version requirements
  result <- lavaanExtra:::get_dep_version("flextable")
  expect_type(result, "character")
  expect_length(result, 1)
  expect_true(is.na(result))
})

test_that("get_dep_version handles packages not in Suggests field", {
  # Test with a package that doesn't exist in Suggests
  result <- lavaanExtra:::get_dep_version("nonexistent_package")
  expect_type(result, "character") 
  expect_length(result, 0)
})

test_that("get_dep_version handles mixed cases", {
  # Test with mix of packages with and without version requirements
  result <- lavaanExtra:::get_dep_version(c("rempsyc", "flextable", "testthat"))
  expect_type(result, "character")
  expect_length(result, 3)
  expect_equal(result[1], "0.1.6")  # has version requirement
  expect_true(is.na(result[2]))     # no version requirement  
  expect_equal(result[3], "3.0.0")  # has version requirement
})

test_that("get_dep_version returns NA for packages without version requirement", {
  # This tests the which.min(nchar()) logic - if there were packages like 
  # "rempsyc" and "rempsyc_extra", it should pick the shorter one
  # We'll test with "knitr" as it's unlikely to have conflicts
  result <- lavaanExtra:::get_dep_version("knitr")
  expect_type(result, "character")
  expect_length(result, 1)
  expect_true(is.na(result))  # knitr has no version requirement in DESCRIPTION
})

test_that("get_dep_version handles empty input", {
  # Test with empty character vector
  result <- lavaanExtra:::get_dep_version(character(0))
  expect_null(result)
})

test_that("get_dep_version works with default pkg parameter", {
  # Test that it uses the current package by default
  # This is the normal use case within the package
  result <- lavaanExtra:::get_dep_version("rempsyc")
  expect_type(result, "character")
  expect_length(result, 1)
  expect_equal(result, "0.1.6")
})