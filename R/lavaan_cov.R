#' @title Extract relevant covariance indices from lavaan model
#'
#' @description Extract relevant covariance indices from lavaan model through
#'              `lavaan::parameterEstimates` with `standardized = TRUE`. In this
#'              case, the correlation coefficient (r) represents the resulting
#'              `std.all` column.
#'
#' @param fit lavaan fit object to extract covariance indices from
#' @param nice_table Logical, whether to print the table as a
#'                   `rempsyc::nice_table` as well as print the
#'                   reference values at the bottom of the table.
#' @param ... Arguments to be passed to `rempsyc::nice_table`
#' @keywords lavaan structural equation modeling path analysis CFA
#' @return A dataframe of covariances, including the covaried variables,
#'         the covariance, and corresponding p-value.
#' @export
#' @examples
#'
#' (latent <- list(visual = paste0("x", 1:3),
#'                 textual = paste0("x", 4:6),
#'                 speed = paste0("x", 7:9)))
#'
#' (regression <- list(ageyr = c("visual", "textual", "speed"),
#'                     grade = c("visual", "textual", "speed")))
#'
#' (covariance <- list(speed = "textual", ageyr = "grade"))
#'
#' HS.model <- write_lavaan(regression = regression, covariance = covariance,
#'                          latent = latent, label = TRUE)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- lavaan(HS.model, data=HolzingerSwineford1939,
#'               auto.var=TRUE, auto.fix.first=TRUE,
#'               auto.cov.lv.x=TRUE)
#' lavaan_cov(fit)

lavaan_cov <- function(fit, nice_table = FALSE, ...) {
  x <- lavaan::parameterEstimates(fit, standardized = TRUE)
  x <- x[which(x["op"] == "~~"),]
  x <- x[c("lhs", "rhs", "std.all", "pvalue")]
  names(x) <- c("Variable 1", "Variable 2", "r", "p")
  if (nice_table) {
    rlang::check_installed("rempsyc", reason = "for this feature.")
    x <- rempsyc::nice_table(x, ...)
  }
  x
}
