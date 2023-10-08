#' @title Fit and plot CFA simultaneously
#'
#' @description Prints and saves CFA fit, as well as plots CFA factor loadings,
#'              simultaneously.
#'
#' @param model CFA model to fit.
#' @param data Data set on which to fit the CFA model.
#' @param covs Logical, whether to include covariances on the lavaan plot.
#' @param estimator What estimator to use for the CFA.
#' @param ... Arguments to be passed to function [lavaan::cfa].
#' @param remove.items Optional, if one wants to remove items from the CFA model
#'                     without having to redefine it completely again.
#' @param print Logical, whether to print model summary to console.
#' @param save.as.pdf Logical, whether to save as PDF for a high-resolution,
#'                    scalable vector graphic quality plot. Defaults to
#'                    saving to the "/model" subfolder of the working
#'                    directory. If it doesn't exist, it creates it. Then
#'                    automatically open the created PDF in the default
#'                    browser. Defaults to false.
#' @param file.name Optional (when `save.as.pdf` is set to `TRUE`), if one
#'                  wants something different than the default file name.
#'                  It saves to pdf per default, so the .pdf extension
#'                  should not be specified as it will add it automatically.
#' @keywords CFA lavaan plot fit
#' @return The function returns a `lavaan` fit object. However, it also: prints
#'         a summary of the `lavaan` fit object to the console, and; prints a
#'         `lavaanPlot` of the `lavaan` fit object.
#' @export
#' @examplesIf requireNamespace("lavaan", quietly = TRUE) && requireNamespace("lavaanPlot", quietly = TRUE)
#' x <- paste0("x", 1:9)
#' (latent <- list(
#'   visual = x[1:3],
#'   textual = x[4:6],
#'   speed = x[7:9]
#' ))
#'
#' HS.model <- write_lavaan(latent = latent)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- cfa_fit_plot(HS.model, HolzingerSwineford1939)
#' @import lavaan
#' @section Illustrations:
#'
#' \if{html}{
#' \figure{cfaplot.png}{options: width="400"}
#' }

cfa_fit_plot <- function(
    model, data, covs = FALSE, estimator = "MLR", remove.items = "",
    print = TRUE, save.as.pdf = FALSE, file.name, ...) {
  insight::check_if_installed("lavaanPlot")

  if (missing(file.name) && isTRUE(save.as.pdf)) {
    stop("To save as PDF, the file name must also be specified.")
  }

  # Remove requested items
  if (!missing(remove.items)) {
    remove.items0 <- paste0("\\s", remove.items, "\\s")
    remove.items1 <- paste0(remove.items, collapse = " \\+ |")
    remove.items1 <- paste0(remove.items1, " \\+")
    remove.items2 <- paste0("\\+ ", remove.items0)
    remove.items2 <- paste0(remove.items2, collapse = "|")
    remove.items3 <- paste0(remove.items, " ", collapse = "|\\+ ")
    model <- gsub("\n", " \n", model)
    model <- gsub(remove.items1, "", model)
    model <- gsub(remove.items2, "", model)
    model <- gsub(remove.items3, "", model)
  }
  # Fit model
  fit <- lavaan::cfa(model, data = data, estimator = estimator, ...)
  if (isTRUE(print)) {
    print(summary(fit,
      standardized = TRUE,
      fit.measures = TRUE, rsquare = TRUE
    ))
  }
  # Plot the model
  my.plot <- nice_lavaanPlot(fit, covs = covs)
  # # Save file
  if (!missing(file.name) && isTRUE(save.as.pdf)) {
    lavaanPlot::embed_plot_pdf(my.plot, paste0(file.name, ".pdf"))
    utils::browseURL(paste0(file.name, ".pdf"))
  } else {
    print(my.plot)
  }
  fit
}
