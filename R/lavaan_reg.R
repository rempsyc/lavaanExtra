#' @title Extract relevant regression indices from lavaan model
#'
#' @description Extract relevant regression indices from lavaan model through
#'              [lavaan::parameterEstimates] with `standardized = TRUE`. In this
#'              case, the beta (B) represents the resulting `std.all` column.
#'              See "Value" section for more details.
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
  og.names <- c("lhs", "rhs", "se", "z", "pvalue", "est", "ci.lower", "ci.upper")
  new.names <- c("Outcome", "Predictor", "SE", "Z", "p", "b", "CI_lower", "CI_upper", "B", "CI_lower_B", "CI_upper_B")

  x <- lavaan::parameterEstimates(fit)
  x <- x[which(x["op"] == "~"), ]
  x <- x[og.names]

  es <- lavaan::standardizedsolution(fit, level = 0.95)
  es <- es[which(es["op"] == "~"), ]
  es <- es[c("est.std", og.names[7:8])]

  names(es)[2:3] <- paste0(names(es)[2:3], ".std")

  x <- cbind(x, es)

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
