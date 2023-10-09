#' @title Extract relevant covariance/correlation indices from lavaan model
#'
#' @description Extract relevant covariance/correlation indices from lavaan
#'  [lavaan::parameterEstimates] and [lavaan::standardizedsolution].
#'
#' @param fit lavaan fit object to extract covariance indices from
#' @param nice_table Logical, whether to print the table as a
#'                   [rempsyc::nice_table] as well as print the
#'                   reference values at the bottom of the table.
#' @param ... Arguments to be passed to [rempsyc::nice_table]
#' @return A dataframe of covariances/correlation, including the covaried
#'  variables, the covariance/correlation, and corresponding p-value.
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
#' lavaan_cov(fit)
lavaan_cov <- function(fit, nice_table = FALSE, ...) {
  lavaan_extract(fit,
                 operator = "~~",
                 lhs_name = "Variable 1",
                 rhs_name = "Variable 2",
                 diag = "exclude",
                 nice_table = nice_table)
}

#' @export
#' @describeIn lavaan_cov Shortcut for `lavaan_cov(fit, estimate = "r")`
lavaan_cor <- function(fit, nice_table = FALSE, ...) {
  lavaan_cov(fit, nice_table = nice_table, ...)
}
