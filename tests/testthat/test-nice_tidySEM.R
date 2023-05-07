skip_if_not_installed(c("lavaan", "tidySEM"))

suppressWarnings(library(lavaan))

# Define our other variables
M <- "visual"
IV <- c("ageyr", "grade")
DV <- c("speed", "textual")

# Prepare model specification
latent <- list(visual = paste0("x", 1:3),
               textual = paste0("x", 4:6),
               speed = paste0("x", 7:9))
indirect <- list(IV = IV, M = M, DV = DV)
mediation <- list(speed = M, textual = M, visual = IV)
HS.model <- write_lavaan(latent = latent)

fit.cfa <- cfa(HS.model, HolzingerSwineford1939)
fit.sem <- sem(HS.model, HolzingerSwineford1939)
fit.lavaan <- lavaan(HS.model, HolzingerSwineford1939, auto.var = TRUE,
                     auto.fix.first = TRUE, auto.cov.lv.x = TRUE)

HS.model2 <- write_lavaan(mediation = mediation,
                          indirect = indirect,
                          label = TRUE)

label <- list(ageyr = "Age", speed = "Speed", grade = "Grade",
              visual = "Visual", textual = "Textual")

s3 <- rep("", 3)
manual.structure <- data.frame(factors = c(s3, names(latent), s3),
                               items = unlist(latent))

data <- HolzingerSwineford1939
data$visual <- rowMeans(data[paste0("x", 1:3)])
data$textual <- rowMeans(data[paste0("x", 4:6)])
data$speed <- rowMeans(data[paste0("x", 7:9)])

fit.sem2 <- sem(HS.model2, data)

#   ____________________________________________________________________________
#   Tests                                                                   ####


test_that("nice_tidySEM on CFA", {
  expect_s3_class(
    nice_tidySEM(fit.cfa),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM wrong labels", {
  expect_error(
    nice_tidySEM(fit.cfa, label = "wrong.labels")
  )
})

test_that("nice_tidySEM on CFA with manual structure", {
  expect_s3_class(
    nice_tidySEM(fit.cfa, layout = manual.structure),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on SEM", {
  expect_s3_class(
    nice_tidySEM(fit.sem),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on SEM with manual structure", {
  expect_s3_class(
    nice_tidySEM(fit.sem, layout = manual.structure),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on SEM with automatic structure", {
  expect_s3_class(
    nice_tidySEM(fit.sem2, layout = indirect),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on SEM with automatic structure and labels", {
  expect_s3_class(
    nice_tidySEM(fit.sem2, layout = indirect,
                 label = label),
    c("gg", "ggplot")
  )
})


test_that("nice_tidySEM on lavaan", {
  expect_s3_class(
    nice_tidySEM(fit.lavaan),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on lavaan with manual structure", {
  expect_s3_class(
    nice_tidySEM(fit.lavaan, layout = manual.structure),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on sem with hide_nonsig_edges", {
  expect_s3_class(
    nice_tidySEM(fit.sem, hide_nonsig_edges = TRUE),
    c("gg", "ggplot")
  )
})

test_that("nice_tidySEM on sem with plot = FALSE", {
  expect_s3_class(
    nice_tidySEM(fit.sem, plot = FALSE),
    "sem_graph"
  )
})

