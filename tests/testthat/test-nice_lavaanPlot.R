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
  # Check that the title is present in the HTML table
  expect_true(grepl("My Model Title", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot with note only", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, note = "This is a caption")
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that the HTML label is constructed correctly
  expect_true(grepl("This is a caption", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot with both title and note", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, title = "My Title", note = "My Caption")
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that title and note are both present in HTML table format
  expect_true(grepl("My Title", result$x$diagram, fixed = TRUE))
  expect_true(grepl("My Caption", result$x$diagram, fixed = TRUE))
  expect_true(grepl("TABLE", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot backward compatibility without title/note", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  # Should work exactly as before when title and note are not provided
  result_old <- nice_lavaanPlot(fit.cfa)
  expect_s3_class(result_old, c("grViz", "htmlwidget"))
})

test_that("nice_lavaanPlot with fit_stats = TRUE", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, fit_stats = TRUE)
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that fit statistics are present in the diagram
  expect_true(grepl("CFI", result$x$diagram, fixed = TRUE))
  expect_true(grepl("TLI", result$x$diagram, fixed = TRUE))
  expect_true(grepl("RMSEA", result$x$diagram, fixed = TRUE))
  expect_true(grepl("SRMR", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot with specific fit_stats", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, fit_stats = c("cfi", "rmsea"))
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that specified fit statistics are present
  expect_true(grepl("CFI", result$x$diagram, fixed = TRUE))
  expect_true(grepl("RMSEA", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot with title and fit_stats", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, 
    title = "CFA Model", 
    fit_stats = TRUE
  )
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that both title and fit stats are present
  expect_true(grepl("CFA Model", result$x$diagram, fixed = TRUE))
  expect_true(grepl("CFI", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot with title, note, and fit_stats", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, 
    title = "CFA Model", 
    note = "Test Data",
    fit_stats = TRUE
  )
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that all elements are present
  expect_true(grepl("CFA Model", result$x$diagram, fixed = TRUE))
  expect_true(grepl("Test Data", result$x$diagram, fixed = TRUE))
  expect_true(grepl("CFI", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot with fit_stats only (no title)", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  result <- nice_lavaanPlot(fit.cfa, fit_stats = c("chisq", "df", "pvalue"))
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that fit statistics are present
  expect_true(grepl("CHISQ", result$x$diagram, fixed = TRUE))
  expect_true(grepl("DF", result$x$diagram, fixed = TRUE))
  expect_true(grepl("PVALUE", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot with multiple fit_stats_type", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  # Fit model with robust estimator to get scaled/robust indices
  fit_robust <- sem(HS.model, HolzingerSwineford1939, estimator = "MLR")
  result <- nice_lavaanPlot(fit_robust, 
    fit_stats = TRUE,
    fit_stats_type = c("regular", "scaled", "robust")
  )
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Check that type labels are present
  expect_true(grepl("Regular:", result$x$diagram, fixed = TRUE))
  expect_true(grepl("Scaled:", result$x$diagram, fixed = TRUE))
  expect_true(grepl("Robust:", result$x$diagram, fixed = TRUE))
})

test_that("nice_lavaanPlot with single fit_stats_type", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  # With single type, no type label should be added
  result <- nice_lavaanPlot(fit.cfa, 
    fit_stats = TRUE,
    fit_stats_type = "regular"
  )
  expect_s3_class(result, c("grViz", "htmlwidget"))
  # Should not have type label when only one type
  expect_false(grepl("Regular:", result$x$diagram, fixed = TRUE))
  # But should have fit indices
  expect_true(grepl("CFI", result$x$diagram, fixed = TRUE))
})
