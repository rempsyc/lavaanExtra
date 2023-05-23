suppressWarnings(library(lavaan))

.old_wd <- setwd(tempdir())

(latent <- list(visual = paste0("x", 1:3),
                textual = paste0("x", 4:6),
                speed = paste0("x", 7:9)))

model <- write_lavaan(latent = latent)

data <- HolzingerSwineford1939
estimator <- "MLR"
fit2 <- cfa(model, data, estimator = estimator)

(latent2 <- list(visual = paste0("x", 2:3),
                 textual = paste0("x", 4:6),
                 speed = paste0("x", 7:9)))


#   ____________________________________________________________________________
#   Tests                                                                   ####


test_that("cfa_fit_plot comparison to cfa", {
  skip_if_not_installed("lavaanPlot")
  fit1 <- cfa_fit_plot(model, data)
  expect_equal(
    summary(fit1),
    summary(fit2)
  )
})

test_that("cfa_fit_plot save as PDF", {
  skip_on_cran()
  skip_if_not_installed("lavaanPlot")
  fit3 <- cfa_fit_plot(model, data, save.as.pdf = TRUE, file.name = "cfaplot")
  expect_equal(
    summary(fit3),
    summary(fit2)
  )
})

model <- write_lavaan(latent = latent2)
fit5 <- cfa(model, data, estimator = estimator)

test_that("cfa_fit_plot remove items", {
  skip_if_not_installed("lavaanPlot")
  fit4 <- cfa_fit_plot(model, data, print = FALSE, remove.items = c("x1"))
  expect_equal(
    summary(fit4),
    summary(fit5)
  )
})

test_that("cfa_fit_plot save as PDF error", {
  expect_error(
    cfa_fit_plot(model, data, save.as.pdf = TRUE)
  )
})


setwd(.old_wd)
