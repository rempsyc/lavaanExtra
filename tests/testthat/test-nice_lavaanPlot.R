suppressWarnings(suppressPackageStartupMessages(library(lavaan)))

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

data <- HolzingerSwineford1939
data$visual <- rowMeans(data[paste0("x", 1:3)])
data$textual <- rowMeans(data[paste0("x", 4:6)])
data$speed <- rowMeans(data[paste0("x", 7:9)])

fit.sem2 <- sem(HS.model2, data)

#   ____________________________________________________________________________
#   Tests                                                                   ####

test_that("nice_lavaanPlot on CFA", {
  skip_if_not_installed(c("lavaan", "lavaanPlot"))
  expect_s3_class(
    nice_lavaanPlot(fit.cfa),
    c("grViz", "htmlwidget")
  )
})

test_that("nice_lavaanPlot on SEM", {
  skip_if_not_installed(c("lavaan", "lavaanPlot"))
  expect_s3_class(
    nice_lavaanPlot(fit.sem),
    c("grViz", "htmlwidget")
  )
})

test_that("nice_lavaanPlot on lavaan", {
  skip_if_not_installed(c("lavaan", "lavaanPlot"))
  expect_s3_class(
    nice_lavaanPlot(fit.lavaan),
    c("grViz", "htmlwidget")
  )
})

test_that("nice_lavaanPlot different sem model", {
  skip_if_not_installed(c("lavaan", "lavaanPlot"))
  expect_s3_class(
    nice_lavaanPlot(fit.sem2),
    c("grViz", "htmlwidget")
  )
})

