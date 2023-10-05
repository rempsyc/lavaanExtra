#' @title Extract relevant correlation indices from lavaan model
#'
#' @description Extract relevant correlation indices from lavaan model through
#'              [lavaan::parameterEstimates] with `standardized = TRUE`. In this
#'              case, the correlation coefficient (r) represents the resulting
#'              `std.all` column.
#'
#' @param fit lavaan fit object to extract correlations from
#' @param nice_table Logical, whether to print the table as a
#'                   [rempsyc::nice_table] as well as print the
#'                   reference values at the bottom of the table.
#' @param ... Arguments to be passed to [rempsyc::nice_table]
#' @keywords lavaan structural equation modeling path analysis CFA
#' @return A dataframe of correlations, including the correlated
#'         variables, the correlation, and the corresponding p-value.
#' @export
#' @examplesIf requireNamespace("lavaan", quietly = TRUE)
#' (latent <- list(
#'   visual = paste0("x", 1:3),
#'   textual = paste0("x", 4:6),
#'   speed = paste0("x", 7:9)
#' ))
#'
#' (regression <- list(
#'   ageyr = c("visual", "textual", "speed"),
#'   grade = c("visual", "textual", "speed")
#' ))
#'
#' (covariance <- list(speed = "textual", ageyr = "grade"))
#'
#' HS.model <- write_lavaan(
#'   regression = regression, covariance = covariance,
#'   latent = latent, label = TRUE
#' )
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- sem(HS.model, data = HolzingerSwineford1939)
#' lavaan_cor(fit)
lavaan_cor <- function(fit, nice_table = FALSE, ...) {
  x <- lavaan::parameterEstimates(fit, standardized = TRUE)
  x <- x[which(x["op"] == "~~"), ]
  x <- x[c("lhs", "rhs", "std.all", "pvalue")]
  not.cor <- which(x$lhs == x$rhs)
  x <- x[-not.cor, ]
  names(x) <- c("Variable_1", "Variable_2", "r", "p")
  if (nice_table) {
    insight::check_if_installed(
      "rempsyc",
      reason = "for this feature.",
      version = get_dep_version("rempsyc"),
    )
    x <- rempsyc::nice_table(x, ...)
  }
  x
}
