#' @title Extract relevant regression indices from lavaan model
#'
#' @description Extract relevant regression indices from lavaan model through
#'  [lavaan::parameterEstimates] and [lavaan::standardizedsolution].
#'
#' @param fit lavaan fit object to extract fit indices from
#' @param nice_table Logical, whether to print the table as a
#'                   [rempsyc::nice_table] as well as print the
#'                   reference values at the bottom of the table.
#' @param ... Arguments to be passed to [rempsyc::nice_table]
#' @return A dataframe, including the outcome ("lhs"), predictor ("rhs"),
#'         standardized regression coefficient ("std.all"), corresponding
#'         p-value, as well as the unstandardized regression coefficient
#'         ("est") and its confidence interval ("ci.lower", "ci.upper").
#' @export
#' @examplesIf requireNamespace("lavaan", quietly = TRUE)
#' x <- paste0("x", 1:9)
#' (latent <- list(
#'   visual = x[1:3],
#'   textual = x[4:6],
#'   speed = x[7:9]
#' ))
#'
#' (regression <- list(
#'   ageyr = c("visual", "textual", "speed"),
#'   grade = c("visual", "textual", "speed")
#' ))
#'
#' HS.model <- write_lavaan(latent = latent, regression = regression)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- sem(HS.model, data = HolzingerSwineford1939)
#' lavaan_reg(fit)
lavaan_reg <- function(fit, nice_table = FALSE, ...) {
  lavaan_extract(fit,
                 operator = "~",
                 lhs_name = "Outcome",
                 rhs_name = "Predictor",
                 nice_table = nice_table)
}
