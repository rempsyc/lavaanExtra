suppressWarnings(suppressPackageStartupMessages(library(lavaan)))

# Prepare test data
latent <- list(
  visual = paste0("x", 1:3),
  textual = paste0("x", 4:6),
  speed = paste0("x", 7:9)
)
HS.model <- write_lavaan(latent = latent)
fit.cfa <- cfa(HS.model, HolzingerSwineford1939)

#   ____________________________________________________________________________
#   Tests                                                                   ####

test_that("save_plot rejects unsupported formats", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")

  plot <- nice_lavaanPlot(fit.cfa)

  expect_error(
    save_plot(plot, "test.txt", verbose = FALSE),
    "Unsupported file format"
  )

  expect_error(
    save_plot(plot, "test.docx", verbose = FALSE),
    "Unsupported file format"
  )
})

test_that("save_plot rejects invalid plot objects", {
  expect_error(
    save_plot(list(), "test.png", verbose = FALSE),
    "plot must be either a ggplot object"
  )

  expect_error(
    save_plot(data.frame(), "test.png", verbose = FALSE),
    "plot must be either a ggplot object"
  )
})

test_that("save_plot works with nice_lavaanPlot - PNG", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  skip_if_not_installed("rsvg")
  skip_if_not_installed("png")

  plot <- nice_lavaanPlot(fit.cfa)

  tmp_file <- tempfile(fileext = ".png")
  result <- save_plot(plot, tmp_file, verbose = FALSE)

  expect_true(file.exists(tmp_file))
  expect_equal(result, tmp_file)
  expect_gt(file.info(tmp_file)$size, 0)

  # Clean up
  unlink(tmp_file)
})

test_that("save_plot works with nice_lavaanPlot - PDF", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  skip_if_not_installed("rsvg")

  plot <- nice_lavaanPlot(fit.cfa)

  tmp_file <- tempfile(fileext = ".pdf")
  result <- save_plot(plot, tmp_file, verbose = FALSE)

  expect_true(file.exists(tmp_file))
  expect_equal(result, tmp_file)
  expect_gt(file.info(tmp_file)$size, 0)

  # Clean up
  unlink(tmp_file)
})

test_that("save_plot works with nice_lavaanPlot - SVG", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")

  plot <- nice_lavaanPlot(fit.cfa)

  tmp_file <- tempfile(fileext = ".svg")
  result <- save_plot(plot, tmp_file, verbose = FALSE)

  expect_true(file.exists(tmp_file))
  expect_equal(result, tmp_file)
  expect_gt(file.info(tmp_file)$size, 0)

  # Check that it's actually SVG
  svg_content <- readLines(tmp_file, n = 5)
  expect_true(any(grepl("svg", svg_content, ignore.case = TRUE)))

  # Clean up
  unlink(tmp_file)
})

test_that("save_plot works with nice_lavaanPlot - JPG", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  skip_if_not_installed("rsvg")
  skip_if_not_installed("png")

  plot <- nice_lavaanPlot(fit.cfa)

  tmp_file <- tempfile(fileext = ".jpg")
  result <- save_plot(plot, tmp_file, verbose = FALSE)

  expect_true(file.exists(tmp_file))
  expect_equal(result, tmp_file)
  expect_gt(file.info(tmp_file)$size, 0)

  # Clean up
  unlink(tmp_file)
})

test_that("save_plot respects custom dimensions for nice_lavaanPlot", {
  skip_if_not_installed("lavaanPlot")
  skip_if_not_installed("DiagrammeRsvg")
  skip_if_not_installed("rsvg")
  skip_if_not_installed("png")

  plot <- nice_lavaanPlot(fit.cfa)

  tmp_file1 <- tempfile(fileext = ".png")
  tmp_file2 <- tempfile(fileext = ".png")

  # Use use_webshot = FALSE to test rsvg path which respects custom dimensions
  save_plot(
    plot,
    tmp_file1,
    width = 800,
    height = 600,
    units = "px",
    verbose = FALSE,
    use_webshot = FALSE
  )
  save_plot(
    plot,
    tmp_file2,
    width = 1600,
    height = 1200,
    units = "px",
    verbose = FALSE,
    use_webshot = FALSE
  )

  # Larger dimensions should generally result in larger files
  size1 <- file.info(tmp_file1)$size
  size2 <- file.info(tmp_file2)$size

  expect_true(file.exists(tmp_file1))
  expect_true(file.exists(tmp_file2))
  expect_gt(size2, size1)

  # Clean up
  unlink(c(tmp_file1, tmp_file2))
})

# Helper function to create tidySEM test plot
create_tidysem_plot <- function() {
  # Create tidySEM plot
  data <- HolzingerSwineford1939
  data$visual <- rowMeans(data[paste0("x", 1:3)])
  data$textual <- rowMeans(data[paste0("x", 4:6)])
  data$speed <- rowMeans(data[paste0("x", 7:9)])

  IV <- c("ageyr", "grade")
  M <- "visual"
  DV <- c("speed", "textual")

  mediation <- list(speed = M, textual = M, visual = IV)
  structure <- list(IV = IV, M = M, DV = DV)

  model <- write_lavaan(mediation, indirect = structure, label = TRUE)
  fit <- sem(model, data)

  nice_tidySEM(fit, layout = structure)
}

test_that("save_plot works with nice_tidySEM - PNG", {
  skip_if_not_installed("tidySEM")
  skip_if_not_installed("tmvnsim")

  plot <- create_tidysem_plot()

  tmp_file <- tempfile(fileext = ".png")
  result <- save_plot(plot, tmp_file, verbose = FALSE)

  expect_true(file.exists(tmp_file))
  expect_equal(result, tmp_file)
  expect_gt(file.info(tmp_file)$size, 0)

  # Clean up
  unlink(tmp_file)
})

test_that("save_plot works with nice_tidySEM - PDF", {
  skip_if_not_installed("tidySEM")
  skip_if_not_installed("tmvnsim")

  plot <- create_tidysem_plot()

  tmp_file <- tempfile(fileext = ".pdf")
  result <- save_plot(plot, tmp_file, verbose = FALSE)

  expect_true(file.exists(tmp_file))
  expect_equal(result, tmp_file)
  expect_gt(file.info(tmp_file)$size, 0)

  # Clean up
  unlink(tmp_file)
})
