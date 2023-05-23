suppressWarnings(library(lavaan))

latent <- list(visual = paste0("x", 1:3),
               textual = paste0("x", 4:6),
               speed = paste0("x", 7:9))

regression <- list(ageyr = c("visual", "textual", "speed"),
                   grade = c("visual", "textual", "speed"))

HS.model <- write_lavaan(latent = latent, regression = regression)

fit <- sem(HS.model, data = HolzingerSwineford1939)


#   ____________________________________________________________________________
#   Tests                                                                   ####


test_that("nice_fit regular", {
  expect_s3_class(
    lavaan_cov(fit),
    c("lavaan.data.frame", "data.frame")
  )
})

test_that("nice_fit as nice_table", {
  skip_if_not_installed("rempsyc")
  expect_s3_class(
    lavaan_cov(fit, nice_table = TRUE),
    c("nice_table", "flextable")
  )
})

test_that("nice_fit estimates", {
  expect_s3_class(
    lavaan_cov(fit, estimate = "b"),
    c("lavaan.data.frame", "data.frame")
  )
  expect_s3_class(
    lavaan_cov(fit, estimate = "B"),
    c("lavaan.data.frame", "data.frame")
  )
  expect_error(
    lavaan_cov(fit, estimate = "C"),
  )
})
