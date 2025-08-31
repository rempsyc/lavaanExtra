#' @title Extract relevant user-defined parameter (e.g., indirect or total
#'  effects) indices from lavaan model
#'
#' @description Extract relevant user-defined parameters (e.g., indirect or
#'  total effects) indices from lavaan model through
#'  [lavaan::parameterEstimates] and [lavaan::standardizedsolution].
#'  
#'  **Uncertainty for standardized coefficients**: When `standardized_se = "delta"`, 
#'  standard errors (SE) and confidence intervals (CI) for standardized coefficients 
#'  are computed via the delta method (as in [lavaan::standardizedsolution]). 
#'  When `standardized_se = "bootstrap"`, CIs for standardized coefficients are 
#'  obtained from the bootstrap distribution of the standardized statistic 
#'  (std.all) returned by [lavaan::parameterEstimates] with `standardized = TRUE`. 
#'  In this case, lavaan reports SE for the corresponding unstandardized parameter; 
#'  a bootstrap SE for standardized coefficients is not provided by lavaan. 
#'  lavaanExtra preserves this behavior and labels the SE source in the output.
#'  
#'  The default `standardized_se = "model"` chooses "bootstrap" if the fitted 
#'  model used `se = "bootstrap"` (and `bootstrap > 0`), and "delta" otherwise.
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
#' @param standardized_se Character string indicating the method to use for
#'  computing standard errors and confidence intervals of standardized estimates.
#'  Options are "model" (default, auto-detects based on model fitting method), 
#'  "delta" (uses delta method via [lavaan::standardizedsolution]), or 
#'  "bootstrap" (uses bootstrap method via [lavaan::parameterEstimates] with 
#'  `standardized = TRUE`, only available when the model was fitted with 
#'  bootstrap standard errors). When `standardized_se = "model"`, the function
#'  chooses "bootstrap" if the fitted model used `se = "bootstrap"` (and 
#'  `bootstrap > 0`), and "delta" otherwise.
#' @param nice_table Logical, whether to print the table as a
#'                   [rempsyc::nice_table] as well as print the
#'                   reference values at the bottom of the table.
#' @param ... Arguments to be passed to [rempsyc::nice_table]
#' @return A dataframe, including the indirect effect ("lhs"),
#'         corresponding paths ("rhs"), standardized regression
#'         coefficient ("std.all"), corresponding p-value, as well
#'         as the unstandardized regression coefficient ("est") and
#'         its confidence interval ("ci.lower", "ci.upper"). When
#'         `standardized_se = "delta"`, standardized SE and CI
#'         are computed using the delta method. When `standardized_se =
#'         "bootstrap"`, standardized CI are computed using bootstrap 
#'         and SE represents the unstandardized bootstrap SE (lavaan 
#'         limitation). The SE computation method is stored as an 
#'         attribute (`standardized_se_method`) for verification.
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
                           standardized_se = "model",
                           nice_table = FALSE,
                           ...) {
  lavaan_extract(fit,
    operator = ":=",
    lhs_name = lhs_name,
    rhs_name = rhs_name,
    underscores_to_symbol = underscores_to_symbol,
    standardized_se = standardized_se,
    nice_table = nice_table
  )
}

lavaan_ind <- lavaan_defined
