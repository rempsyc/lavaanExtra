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

test_that("nice_fit error on wronb object class", {
  expect_error(
    nice_fit(HS.model, model.labels = seq(1, 10))
  )
})

test_that("nice_fit test categorical variable", {
  dat <- data.frame(z = sample(c(0, 1), 100, replace = TRUE),
                    x = sample(1:7, 100, replace = TRUE),
                    y = sample(1:5, 100, replace = TRUE))
  mod <- '
  y ~ a*x
  z ~ b*y + c*x
  ind := a*b
  '
  fit <- sem(mod, dat, ordered = "z")
  expect_s3_class(nice_fit(fit, verbose = FALSE), "data.frame")
  expect_s3_class(
    nice_fit(fit, nice_table = TRUE, verbose = FALSE), "flextable"
  )
})
