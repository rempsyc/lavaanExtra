#' @title Extract relevant user-defined parameter (e.g., indirect or total
#'  effects) indices from lavaan model
#'
#' @description Extract relevant user-defined parameters (e.g., indirect or
#'  total effects) indices from lavaan model through
#'  [lavaan::parameterEstimates] and [lavaan::standardizedsolution].
#' @param fit lavaan fit object to extract fit indices from
#' @param underscores_to_symbol Character to convert underscores
#'  to arrows in the first column, like for indirect effects. Default to
#'  the right arrow symbol, but can be set to NULL or "_", or to any
#'  other desired  symbol. It is also possible to provide a vector of
#'  replacements if they they are not all the same.
#' @param lhs_name Name of first column, referring to the left-hand side
#'  expression (lhs).
#' @param rhs_name Name of first column, referring to the right-hand side
#'  expression (rhs).
#' @param nice_table Logical, whether to print the table as a
#'                   [rempsyc::nice_table] as well as print the
#'                   reference values at the bottom of the table.
#' @param ... Arguments to be passed to [rempsyc::nice_table]
#' @return A dataframe, including the indirect effect ("lhs"),
#'         corresponding paths ("rhs"), standardized regression
#'         coefficient ("std.all"), corresponding p-value, as well
#'         as the unstandardized regression coefficient ("est") and
#'         its confidence interval ("ci.lower", "ci.upper").
#' @aliases lavaan_ind
#' @export
#' @examplesIf requireNamespace("lavaan", quietly = TRUE)
#' x <- paste0("x", 1:9)
#' (latent <- list(
#'   visual = x[1:3],
#'   textual = x[4:6],
#'   speed = x[7:9]
#' ))
#'
#' (mediation <- list(
#'   speed = "visual",
#'   textual = "visual",
#'   visual = c("ageyr", "grade")
#' ))
#'
#' (indirect <- list(
#'   IV = c("ageyr", "grade"),
#'   M = "visual",
#'   DV = c("speed", "textual")
#' ))
#'
#' HS.model <- write_lavaan(mediation,
#'   indirect = indirect,
#'   latent = latent, label = TRUE
#' )
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- sem(HS.model, data = HolzingerSwineford1939)
#' lavaan_defined(fit, lhs_name = "Indirect Effect")
lavaan_defined <- function(fit,
                           underscores_to_symbol = "\u2192",
                           lhs_name = "User-Defined Parameter",
                           rhs_name = "Paths",
                           nice_table = FALSE,
                           ...) {
  lavaan_extract(fit,
                 operator = ":=",
                 lhs_name = lhs_name,
                 rhs_name = rhs_name,
                 underscores_to_symbol = underscores_to_symbol,
                 nice_table = nice_table)
}

lavaan_ind <- lavaan_defined
