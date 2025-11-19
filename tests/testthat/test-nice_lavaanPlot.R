suppressWarnings(suppressPackageStartupMessages(library(lavaan)))

# Define our other variables
M <- "visual"
IV <- c("ageyr", "grade")
DV <- c("speed", "textual")

# Prepare model specification
latent <- list(
  visual = paste0("x", 1:3),
  textual = paste0("x", 4:6),
  speed = paste0("x", 7:9)
)
indirect <- list(IV = IV, M = M, DV = DV)
mediation <- list(speed = M, textual = M, visual = IV)
HS.model <- write_lavaan(latent = latent)

fit.cfa <- cfa(HS.model, HolzingerSwineford1939)
fit.sem <- sem(HS.model, HolzingerSwineford1939)
fit.lavaan <- lavaan(HS.model, HolzingerSwineford1939,
  auto.var = TRUE,
  auto.fix.first = TRUE, auto.cov.lv.x = TRUE
)

HS.model2 <- write_lavaan(
  mediation = mediation,
  indirect = indirect,
  label = TRUE
)

label <- list(
  ageyr = "Age", speed = "Speed", grade = "Grade",
  visual = "Visual", textual = "Textual"
)

data <- HolzingerSwineford1939
data$visual <- rowMeans(data[paste0("x", 1:3)])
data$textual <- rowMeans(data[paste0("x", 4:6)])
data$speed <- rowMeans(data[paste0("x", 7:9)])

fit.sem2 <- sem(HS.model2, data)

#   ____________________________________________________________________________
#   Tests                                                                   ####

test_that("nice_lavaanPlot on CFA", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  expect_s3_class(
    nice_lavaanPlot(fit.cfa),
    c("grViz", "htmlwidget")
  )
})

test_that("nice_lavaanPlot on SEM", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  expect_s3_class(
    nice_lavaanPlot(fit.sem),
    c("grViz", "htmlwidget")
  )
})

test_that("nice_lavaanPlot on lavaan", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  expect_s3_class(
    nice_lavaanPlot(fit.lavaan),
    c("grViz", "htmlwidget")
  )
})

test_that("nice_lavaanPlot different sem model", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  expect_s3_class(
    nice_lavaanPlot(fit.sem2),
    c("grViz", "htmlwidget")
  )
})

test_that("nice_lavaanPlot with title only", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, title = "My Model Title")
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that the HTML label is constructed correctly
  expect_true(grepl("<My Model Title>", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot with note only", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, note = "This is a caption")
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that the HTML label is constructed correctly and positioned at bottom
  expect_true(grepl("<This is a caption>", result$x$diagram, fixed = TRUE))
  expect_true(grepl("labelloc=\"b\"", result$x$diagram, fixed = FALSE))
})

test_that("nice_lavaanPlot with both title and note", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, title = "My Title", note = "My Caption")
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that title and note are both in HTML table format
  expect_true(grepl("My Title", result$x$diagram, fixed = TRUE))
  expect_true(grepl("labelloc=\"t\"", result$x$diagram, fixed = FALSE))
  expect_true(grepl("My Caption", result$x$diagram, fixed = TRUE))
  expect_true(grepl("<TABLE", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot backward compatibility without title/note", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  # Should work exactly as before when title and note are not provided
  result_old <- nice_lavaanPlot(fit.cfa)
  expect_s3_class(result_old, c("grViz", "htmlwidget"))
})
