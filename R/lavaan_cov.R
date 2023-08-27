#' @title Extract relevant covariance indices from lavaan model
#'
#' @description Extract relevant covariance indices from lavaan model through
#'              [lavaan::parameterEstimates] with `standardized = TRUE`. In this
#'              case, the covariances represent the resulting
#'              `std.all` column.
#'
#' @param fit lavaan fit object to extract covariance indices from
#' @param estimate What estimate to use, either the standardized
#'                 estimate ("B", default), or unstandardized
#'                 estimate ("b").
#' @param nice_table Logical, whether to print the table as a
#'                   [rempsyc::nice_table] as well as print the
#'                   reference values at the bottom of the table.
#' @param ... Arguments to be passed to [rempsyc::nice_table]
#' @keywords lavaan structural equation modeling path analysis CFA
#' @return A dataframe of covariances, including the covaried variables,
#'         the covariance, and corresponding p-value.
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
#' lavaan_cov(fit)
lavaan_cov <- function(fit, estimate = "B", nice_table = FALSE, ...) {
  og.names <- c("lhs", "rhs", "pvalue", "est", "ci.lower", "ci.upper")
  new.names <- c("Variable 1", "Variable 2", "p", "b", "CI_lower", "CI_upper")
  if (estimate == "b") {
    x <- lavaan::parameterEstimates(fit)
  } else if (estimate == "B") {
    x <- standardizedsolution(fit, level = 0.95)
    og.names[4] <- "est.std"
    new.names[4] <- "B"
  } else {
    stop("The 'estimate' argument may only be one of c('B', 'b').")
  }
  x <- x[which(x["op"] == "~~"), ]
  x <- x[og.names]
  names(x) <- new.names
  if (nice_table) {
    insight::check_if_installed("rempsyc",
      version = get_dep_version("rempsyc"),
      reason = "for this feature."
    )
    x <- rempsyc::nice_table(x, ...)
  }
  x
}
