#' @title Extract relevant indices from lavaan model based on specified operator
#'
#' @description Extract relevant indices from lavaan model through
#'  [lavaan::parameterEstimates] and [lavaan::standardizedsolution].
#'  Note: When using `standardized_se = "delta"` (default), standardized
#'  standard errors and confidence intervals are computed using the delta
#'  method. When using `standardized_se = "bootstrap"`, they are computed
#'  using the bootstrap method (only available when the model was fitted
#'  with bootstrap standard errors).
#' @param fit lavaan fit object to extract fit indices from
#' @param operator Which operator to subselect with.
#' @param lhs_name Name of first column, referring to the left-hand side
#'  expression (lhs).
#' @param rhs_name Name of first column, referring to the right-hand side
#'  expression (rhs).
#' @param underscores_to_symbol Character to convert underscores
#'  to arrows in the first column, like for indirect effects. Default to
#'  the right arrow symbol, but can be set to NULL or "_", or to any
#'  other desired  symbol. It is also possible to provide a vector of
#'  replacements if they they are not all the same.
#' @param diag When extracting covariances (`~~`), whether to include or
#'  exclude diagonal values (one of "exclude" or "include").
#' @param standardized_se Character string indicating the method to use for
#'  computing standard errors and confidence intervals of standardized estimates.
#'  Options are "delta" (default, uses delta method via
#'  [lavaan::standardizedsolution]) or "bootstrap" (uses bootstrap method via
#'  [lavaan::parameterEstimates] with `standardized = TRUE`, only available
#'  when the model was fitted with bootstrap standard errors).
#' @param nice_table Logical, whether to print the table as a
#'                   [rempsyc::nice_table] as well as print the
#'                   reference values at the bottom of the table.
#' @param ... Arguments to be passed to [rempsyc::nice_table]
#' @return A dataframe, including the indirect effect ("lhs"),
#'         corresponding paths ("rhs"), standardized regression
#'         coefficient ("std.all"), corresponding p-value, as well
#'         as the unstandardized regression coefficient ("est") and
#'         its confidence interval ("ci.lower", "ci.upper"). When
#'         `standardized_se = "delta"` (default), standardized SE and CI
#'         are computed using the delta method. When `standardized_se =
#'         "bootstrap"`, they are computed using bootstrap (only available
#'         when model was fitted with bootstrap standard errors).
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
#' lavaan_extract(fit, lhs_name = "Indirect Effect", operator = ":=")
lavaan_extract <- function(fit,
                           operator = NULL,
                           lhs_name = "Left-Hand Side",
                           rhs_name = "Right-Hand Side",
                           underscores_to_symbol = "\u2192",
                           diag = NULL,
                           standardized_se = "delta",
                           nice_table = FALSE,
                           ...) {
  if (missing(operator)) {
    stop("Please specify the desired operator.")
  }

  # Validate standardized_se argument
  if (!standardized_se %in% c("delta", "bootstrap")) {
    stop("standardized_se must be either 'delta' or 'bootstrap'.")
  }
  og.names <- c("lhs", "rhs", "se", "z", "pvalue", "est", "ci.lower", "ci.upper")
  new.names <- c(
    lhs_name, rhs_name, "SE", "Z", "p", "b",
    "CI_lower", "CI_upper", "B", "CI_lower_B", "CI_upper_B"
  )

  x <- lavaan::parameterEstimates(fit)
  x <- x[which(x["op"] == operator), ]

  if (standardized_se == "bootstrap") {
    # Get standardized estimates with bootstrap SE/CI
    es <- lavaan::parameterEstimates(fit, standardized = TRUE)
    es <- es[which(es["op"] == operator), ]
    # Extract standardized coefficient and bootstrap SE/CI
    es <- es[c("std.all", "se", "z", "pvalue", "ci.lower", "ci.upper")]
    names(es) <- c("est.std", "se.std", "z.std", "pvalue.std", "ci.lower.std", "ci.upper.std")
  } else {
    # Use default delta method for standardized estimates
    es <- lavaan::standardizedsolution(fit, level = 0.95)
    es <- es[which(es["op"] == operator), ]
    es <- es[c("est.std", "se", "z", "pvalue", "ci.lower", "ci.upper")]
    names(es) <- c("est.std", "se.std", "z.std", "pvalue.std", "ci.lower.std", "ci.upper.std")
  }

  if (!is.null(diag) && diag == "exclude") {
    diag <- which(x$lhs == x$rhs)
    x <- x[-diag, ] # keep only off-diagonal elements
    es <- es[-diag, ] # keep only off-diagonal elements
    new.names[c(6, 9:11)] <- c("sigma", "r", "CI_lower_r", "CI_upper_r")
  }

  x <- x[og.names]
  # Extract standardized coefficient and CI with appropriate SE method
  es_for_output <- es[c("est.std", "ci.lower.std", "ci.upper.std")]
  names(es_for_output) <- c("est.std", "ci.lower.std", "ci.upper.std")

  x <- cbind(x, es_for_output)

  names(x) <- new.names

  if (!is.null(underscores_to_symbol) && operator == ":=") {
    if (length(underscores_to_symbol) == 1) {
      underscores_to_symbol <- rep(underscores_to_symbol, nrow(x))
    }
    if (length(underscores_to_symbol) == nrow(x)) {
      x[[1]] <- unlist(lapply(seq_along(underscores_to_symbol), function(i) {
        gsub("_", paste0(" ", underscores_to_symbol[[i]], " "), as.list(x[[1]])[[i]])
      }))
    } else {
      stop("'underscores_to_symbol' must match the number of rows.")
    }
  }
  if (nice_table) {
    insight::check_if_installed("rempsyc",
      version = get_dep_version("rempsyc"),
      reason = "for this feature."
    )
    x <- rempsyc::nice_table(x, ...)
  }
  x
}
