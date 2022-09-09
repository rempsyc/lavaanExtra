library(lavaan)

test_that("nice_tidySEM on CFA", {
  latent <- list(visual = paste0("x", 1:3),
                 textual = paste0("x", 4:6),
                 speed = paste0("x", 7:9))
  HS.model <- write_lavaan(latent = latent)
  fit <- cfa(HS.model, HolzingerSwineford1939)
  expect_equal(
    class(nice_tidySEM(fit)),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on CFA with manual structure", {
  latent <- list(visual = paste0("x", 1:3),
                 textual = paste0("x", 4:6),
                 speed = paste0("x", 7:9))
  HS.model <- write_lavaan(latent = latent)
  fit <- cfa(HS.model, HolzingerSwineford1939)
  s3 <- rep("", 3)
  structure <- data.frame(factors = c(s3, names(latent), s3),
                          items = unlist(latent))
  structure <- as.matrix(structure)
  expect_equal(
    class(nice_tidySEM(fit, layout = structure)),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on SEM", {
  latent <- list(visual = paste0("x", 1:3),
                 textual = paste0("x", 4:6),
                 speed = paste0("x", 7:9))
  HS.model <- write_lavaan(latent = latent)
  fit <- sem(HS.model, HolzingerSwineford1939)
  expect_equal(
    class(nice_tidySEM(fit)),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on SEM with manual structure", {
  latent <- list(visual = paste0("x", 1:3),
                 textual = paste0("x", 4:6),
                 speed = paste0("x", 7:9))
  HS.model <- write_lavaan(latent = latent)
  fit <- sem(HS.model, HolzingerSwineford1939)
  s3 <- rep("", 3)
  structure <- data.frame(factors = c(s3, names(latent), s3),
                          items = unlist(latent))
  structure <- as.matrix(structure)
  expect_equal(
    class(nice_tidySEM(fit, layout = structure)),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on lavaan", {
  latent <- list(visual = paste0("x", 1:3),
                 textual = paste0("x", 4:6),
                 speed = paste0("x", 7:9))
  HS.model <- write_lavaan(latent = latent)
  fit <- lavaan(HS.model, HolzingerSwineford1939, auto.var = TRUE,
                auto.fix.first = TRUE, auto.cov.lv.x = TRUE)
  expect_equal(
    class(nice_tidySEM(fit)),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on lavaan with manual structure", {
  latent <- list(visual = paste0("x", 1:3),
                 textual = paste0("x", 4:6),
                 speed = paste0("x", 7:9))
  HS.model <- write_lavaan(latent = latent)
  fit <- lavaan(HS.model, HolzingerSwineford1939, auto.var = TRUE,
                auto.fix.first = TRUE, auto.cov.lv.x = TRUE)
  s3 <- rep("", 3)
  structure <- data.frame(factors = c(s3, names(latent), s3),
                          items = unlist(latent))
  structure <- as.matrix(structure)
  expect_equal(
    class(nice_tidySEM(fit, layout = structure)),
    c("gg", "ggplot")
  )
})
