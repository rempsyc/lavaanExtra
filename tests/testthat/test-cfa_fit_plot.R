setwd(tempdir())

(latent <- list(visual = paste0("x", 1:3),
                textual = paste0("x", 4:6),
                speed = paste0("x", 7:9)))

model <- write_lavaan(latent = latent)

library(lavaan)
data <- HolzingerSwineford1939
estimator <- "MLR"
fit1 <- cfa_fit_plot(model, data)
fit2 <- cfa(model, data, estimator = estimator)
fit3 <- cfa_fit_plot(model, data, save.as.pdf = TRUE, file.name = "cfaplot")

(latent2 <- list(visual = paste0("x", 2:3),
                 textual = paste0("x", 4:6),
                 speed = paste0("x", 7:9)))

fit4 <- cfa_fit_plot(model, data, print = TRUE, remove.items = c("x1"))
model <- write_lavaan(latent = latent2)
fit5 <- cfa(model, data, estimator = estimator)

#   ____________________________________________________________________________
#   Tests                                                                   ####


test_that("cfa_fit_plot comparison to cfa", {
  expect_equal(
    fit1,
    fit2,
    tolerance = 0.3
  )
})

test_that("cfa_fit_plot save as PDF", {
  expect_equal(
    fit3,
    fit2,
    tolerance = 0.3
  )
})

test_that("cfa_fit_plot remove items", {
  expect_equal(
    summary(fit4),
    summary(fit5)
  )
})

