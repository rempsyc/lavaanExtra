#' @title Extract relevant indices from lavaan model based on specified operator
#'
#' @description Extract relevant indices from lavaan model through
#'  [lavaan::parameterEstimates] and [lavaan::standardizedsolution].
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
#' @param nice_table Logical, whether to print the table as a
#'                   [rempsyc::nice_table] as well as print the
#'                   reference values at the bottom of the table.
#' @param ... Arguments to be passed to [rempsyc::nice_table]
#' @return A dataframe, including the indirect effect ("lhs"),
#'         corresponding paths ("rhs"), standardized regression
#'         coefficient ("std.all"), corresponding p-value, as well
#'         as the unstandardized regression coefficient ("est") and
#'         its confidence interval ("ci.lower", "ci.upper").
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
                           nice_table = FALSE,
                           ...) {
  if (missing(operator)) {
    stop("Please specify the desired operator.")
  }
  og.names <- c("lhs", "rhs", "se", "z", "pvalue", "est", "ci.lower", "ci.upper")
  new.names <- c(lhs_name, rhs_name, "SE", "Z", "p", "b",
                 "CI_lower", "CI_upper", "B", "CI_lower_B", "CI_upper_B")

  x <- lavaan::parameterEstimates(fit)
  x <- x[which(x["op"] == operator), ]

  es <- lavaan::standardizedsolution(fit, level = 0.95)
  es <- es[which(es["op"] == operator), ]

  if (!is.null(diag) && diag == "exclude") {
    diag <- which(x$lhs == x$rhs)
    x <- x[-diag, ] # keep only off-diagonal elements
    es <- es[-diag, ] # keep only off-diagonal elements
    new.names[c(6, 9:11)] <- c("sigma", "r", "CI_lower_r", "CI_upper_r")
  }

  x <- x[og.names]
  es <- es[c("est.std", og.names[7:8])]
  names(es)[2:3] <- paste0(names(es)[2:3], ".std")

  x <- cbind(x, es)

  names(x) <- new.names

  if (!is.null(underscores_to_symbol) && operator == ":=") {
    if (length(underscores_to_symbol) == 1){
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
