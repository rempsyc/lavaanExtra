#' @title Extract relevant regression indices from lavaan model
#'
#' @description Extract relevant regression indices from lavaan model.
#'
#' @param fit lavaan fit object to extract fit indices from
#' @param nice_table Logical, whether to print the table as a `rempsyc::nice_table`
#'                   as well as print the reference values at the bottom of the table.
#' @param ... Arguments to be passed to `rempsyc::nice_table`
#' @keywords lavaan, structural equation modeling, path analysis, CFA
#' @export
#' @examples
#' (latent <- list(visual = paste0("x", 1:3),
#'                 textual = paste0("x", 4:6),
#'                 speed = paste0("x", 7:9)))
#'
#' (regression <- list(ageyr = c("visual", "textual", "speed"),
#'                     grade = c("visual", "textual", "speed")))
#'
#' HS.model <- write_lavaan(latent = latent, regression = regression)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- lavaan(HS.model, data=HolzingerSwineford1939,
#'               auto.var=TRUE, auto.fix.first=TRUE,
#'               auto.cov.lv.x=TRUE)
#' lavaan_reg(fit)

lavaan_reg <- function(fit, nice_table = FALSE, ...) {
  x <- lavaan::parameterEstimates(fit, standardized = TRUE)
  x <- x[which(x["op"] == "~"),]
  x <- x[c("lhs", "rhs", "std.all", "pvalue")]
  names(x) <- c("Outcome", "Predictor", "B", "p")
  if (nice_table) {
    if (isFALSE(requireNamespace("rempsyc", quietly = TRUE))) {
      cat("The package `rempsyc` is required for this feature\n",
          "Would you like to install it?")
      if (utils::menu(c("Yes", "No")) == 1) {
        utils::install.packages('rempsyc', repos = c(
          rempsyc = 'https://rempsyc.r-universe.dev',
          CRAN = 'https://cloud.r-project.org'))
      } else (stop(
        'The `nice_table` feature relies on the `rempsyc` package.
    You can install it manually with:
    install.packages("rempsyc", repos = c(
          rempsyc = "https://rempsyc.r-universe.dev",
          CRAN = "https://cloud.r-project.org")'))
    }
    x <- rempsyc::nice_table(x, ...)
  }
  x
}