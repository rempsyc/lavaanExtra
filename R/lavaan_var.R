#' @title Extract relevant variance indices from lavaan model
#'
#' @description Extract relevant variance indices from lavaan
#'  model through [lavaan::parameterEstimates] (when estimate = "sigma",
#'  `est` column)) or [lavaan::standardizedsolution] (when estimate = "r2",
#'  `est.std` column). R2 values are then calculated as `1 - est.std`, and
#'  the new _p_ values for the R2, with the following formula:
#'  `stats::pnorm((1 - est) / se)`.
#'
#' @param fit lavaan fit object to extract covariance indices from
#' @param estimate What estimate to use, either the standardized
#'                 estimate ("r2", default), or unstandardized
#'                 estimate ("sigma2").
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
#' lavaan_var(fit)
lavaan_var <- function(fit, estimate = "r2", nice_table = FALSE, ...) {
  og.names <- c("lhs", "pvalue", "est", "ci.lower", "ci.upper")
  new.names <- c("Variable", "p", "sigma2", "CI_lower", "CI_upper")
  if (estimate == "sigma2") {
    x <- lavaan::parameterEstimates(fit)
  } else if (estimate == "r2") {
    x <- lavaan::standardizedsolution(fit, level = 0.95)
    og.names[3] <- "est.std"
    new.names[3] <- "R2"
    x$est.std <- abs(1 - x$est.std)
    x$ci.lower_temp <- abs(1 - x$ci.lower)
    x$ci.upper_temp <- abs(1 - x$ci.upper)
    x$ci.upper <- x$ci.lower_temp
    x$ci.lower <- x$ci.upper_temp
    x$pvalue <- stats::pnorm(x$est.std / x$se, lower.tail = FALSE)
  } else {
    stop("The 'estimate' argument may only be one of c('sigma2', 'r2').")
  }
  x <- x[which(x["op"] == "~~"), ]
  diag <- which(x$lhs == x$rhs)
  x <- x[diag, ] # keep only diagonal elements
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
