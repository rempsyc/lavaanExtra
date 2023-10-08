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

test_that("nice_fit estimates", {
  expect_snapshot(
    lavaan_defined(fit, estimate = "b")
  )
  expect_snapshot(
    lavaan_defined(fit, estimate = "B")
  )
  expect_error(
    lavaan_defined(fit, estimate = "C"),
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
