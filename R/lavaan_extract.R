#' @title Extract relevant indices from lavaan model based on specified operator
#'
#' @description Extract relevant indices from lavaan model through
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
                           standardized_se = "model",
                           nice_table = FALSE,
                           ...) {
  if (missing(operator)) {
    stop("Please specify the desired operator.")
  }

  # Validate standardized_se argument
  if (!standardized_se %in% c("delta", "bootstrap", "model")) {
    stop("standardized_se must be one of 'delta', 'bootstrap', or 'model'.")
  }

  # Auto-detect method if "model" is specified
  if (standardized_se == "model") {
    # Check if model was fitted with bootstrap
    model_info <- lavaan::lavInspect(fit, "options")
    if (!is.null(model_info$se) && model_info$se == "bootstrap" &&
      !is.null(model_info$bootstrap) && model_info$bootstrap > 0) {
      standardized_se <- "bootstrap"
    } else {
      standardized_se <- "delta"
    }
  }
  # Get unstandardized estimates for basic info
  x_unstd <- lavaan::parameterEstimates(fit)
  x_unstd <- x_unstd[which(x_unstd["op"] == operator), ]

  if (standardized_se == "bootstrap") {
    # Get standardized estimates with bootstrap SE/CI
    x_std <- lavaan::parameterEstimates(fit, standardized = TRUE)
    x_std <- x_std[which(x_std["op"] == operator), ]

    # Get standardized coefficients from standardizedsolution for consistency
    x_std_coef <- lavaan::standardizedsolution(fit, level = 0.95)
    x_std_coef <- x_std_coef[which(x_std_coef["op"] == operator), ]

    # Combine: basic info from unstandardized in original order: se, z, pvalue, est, ci.lower, ci.upper
    og.names <- c("lhs", "rhs", "se", "z", "pvalue", "est", "ci.lower", "ci.upper")
    x <- x_unstd[og.names]

    # Create es dataframe for standardized info: est.std, ci.lower.std, ci.upper.std
    es <- data.frame(
      est.std = x_std_coef$est.std,
      ci.lower.std = x_std$ci.lower,
      ci.upper.std = x_std$ci.upper
    )
  } else {
    # Use delta method for standardized estimates (consistent SE and CI)
    x_std <- lavaan::standardizedsolution(fit, level = 0.95)
    x_std <- x_std[which(x_std["op"] == operator), ]

    # Combine: basic info from unstandardized in original order: se, z, pvalue, est, ci.lower, ci.upper
    og.names <- c("lhs", "rhs", "se", "z", "pvalue", "est", "ci.lower", "ci.upper")
    x <- x_unstd[og.names]

    # Create es dataframe for standardized info: est.std, ci.lower.std, ci.upper.std
    es <- x_std[c("est.std", "ci.lower", "ci.upper")]
    names(es)[2:3] <- paste0(names(es)[2:3], ".std")
  }

  new.names <- c(
    lhs_name, rhs_name, "SE", "Z", "p", "b", "CI_lower", "CI_upper",
    "B", "CI_lower_B", "CI_upper_B"
  )

  if (!is.null(diag) && diag == "exclude") {
    diag_rows <- which(x_unstd$lhs == x_unstd$rhs)
    x <- x[-diag_rows, ] # keep only off-diagonal elements
    es <- es[-diag_rows, ] # keep only off-diagonal elements
    new.names[6] <- "sigma"
    new.names[9] <- "r"
    new.names[10:11] <- c("CI_lower_r", "CI_upper_r")
  }

  # Combine unstandardized and standardized results consistently
  x <- cbind(x, es)
  names(x) <- new.names

  # Add attribute to track SE computation method
  attr(x, "standardized_se_method") <- standardized_se

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
