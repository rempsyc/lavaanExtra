#' @title Vector-based lavaan syntax interpreter
#'
#' @description Vector-based lavaan syntax interpreter.
#'
#' @param mediation Mediation	indicators (`~` symbol: "is regressed on").
#'                  Differs from argument `regression` because path names
#'                  can be optionally specified automatically with argument
#'                  `label`.
#' @param regression Regression indicators (`~` symbol: "is regressed on").
#' @param covariance (Residual) (co)variance indicators (`~~` symbol:
#'                   "is correlated with").
#' @param indirect Indirect effect indicators (`:=` symbol: "indirect
#'                 effect defined as"). Can be:
#'                 1) A named list with manual indirect effect definitions
#'                 2) A named list with "IV", "M", "DV" for structured auto-generation
#'                 3) `TRUE` to discover ALL indirect effects automatically (x.boot-inspired)
#'                 4) `NULL` (default) for no indirect effects
#'                 When using option 2, the `mediation` argument must be specified too.
#'                 Option 3 uses comprehensive graph-based discovery.
#' @param latent Latent variable indicators (`=~` symbol: "is measured by").
#' @param intercept Intercept indicators (`~ 1` symbol: "intercept").
#' @param threshold Threshold indicators (`|` symbol: "threshold").
#' @param constraint.equal Equality indicators (`==` symbol).
#' @param constraint.smaller Smaller than indicators (`<` symbol).
#' @param constraint.larger Greater than indicators (`>` symbol).
#' @param custom Custom specifications. Takes a *single* string just
#'               like regular `lavaan` syntax would. Always added at
#'               the end of the model.
#' @param label Logical, whether to display path names for the
#'              mediation argument.
#' @param use.letters Logical, for the labels, whether to use letters
#'                    instead of the variable names.
#' @param auto_indirect_max_length When using `indirect = TRUE`, the maximum 
#'                    length of indirect effect chains to discover. Default is 5.
#' @param auto_indirect_limit When using `indirect = TRUE`, the maximum number
#'                    of indirect effects to discover (performance safeguard). 
#'                    Default is 1000.
#' @return A character string, representing the specified `lavaan` model.
#' @seealso The corresponding vignette: <https://lavaanextra.remi-theriault.com/articles/write_lavaan.html>
#' @export
#' @examplesIf requireNamespace("lavaan", quietly = TRUE)
#' x <- paste0("x", 1:9)
#' (latent <- list(
#'   visual = x[1:3],
#'   textual = x[4:6],
#'   speed = x[7:9]
#' ))
#'
#' HS.model <- write_lavaan(latent = latent)
#' cat(HS.model)
#' 
#' # Example with comprehensive indirect effects (x.boot-inspired)
#' mediation <- list(textual = "visual", speed = "visual") 
#' regression <- list(textual = "ageyr", speed = "ageyr")
#' 
#' # Automatically discover ALL indirect effects
#' model_auto <- write_lavaan(
#'   mediation = mediation,
#'   regression = regression, 
#'   indirect = TRUE,  # Enable comprehensive discovery
#'   label = TRUE
#' )
#' cat(model_auto)
#'
#' library(lavaan)
#' fit <- lavaan(HS.model,
#'   data = HolzingerSwineford1939,
#'   auto.var = TRUE, auto.fix.first = TRUE,
#'   auto.cov.lv.x = TRUE
#' )
#' summary(fit, fit.measures = TRUE)
write_lavaan <- function(mediation = NULL,
                         regression = NULL,
                         covariance = NULL,
                         indirect = NULL,
                         latent = NULL,
                         intercept = NULL,
                         threshold = NULL,
                         constraint.equal = NULL,
                         constraint.smaller = NULL,
                         constraint.larger = NULL,
                         custom = NULL,
                         label = FALSE,
                         use.letters = FALSE,
                         auto_indirect_max_length = 5,
                         auto_indirect_limit = 1000) {
  constraint <- NULL
  hashtag <- sprintf("%s\n", paste0(rep("#", 50), collapse = ""))
  process_vars <- function(x,
                           symbol,
                           label = FALSE,
                           collapse = " + ",
                           header = paste0(hashtag, paste0("# ", title, "\n\n")),
                           title = NULL,
                           spacer = "\n\n") {
    if (isTRUE(label)) {
      labels <- paste0(names(x))
      if (isTRUE(use.letters)) {
        x <- lapply(seq(x), function(i) {
          paste0(letters[seq_along(x[[i]])], "_", labels[i], "*", x[[i]])
        })
      } else {
        x <- lapply(seq(x), function(i) {
          paste0(x[[i]], "_", labels[i], "*", x[[i]])
        })
      }
      x <- stats::setNames(x, labels)
    }
    x <- lapply(x, paste0, collapse = collapse)
    x <- paste0(names(x), paste0(" ", symbol, " "), x, collapse = "\n")
    header <- header
    paste0(header, x, spacer, collapse = "")
  }
  if (!is.null(latent)) {
    latent <- process_vars(latent,
      symbol = "=~", title =
        "[-----Latent variables (measurement model)-----]"
    )
  }
  #### AUTOMATIC INDIRECT EFFECTS (Enhanced x.boot-inspired) ####
  if (!is.null(indirect)) {
    # Option 1: Comprehensive automatic discovery (x.boot-inspired)
    if (isTRUE(indirect)) {
      # Build preliminary model to discover indirect effects
      preliminary_model <- paste0(
        if (!is.null(latent)) process_vars(latent, symbol = "=~", title = ""),
        if (!is.null(mediation)) process_vars(mediation, symbol = "~", label = label, title = ""),
        if (!is.null(regression)) process_vars(regression, symbol = "~", title = "")
      )
      
      if (nchar(preliminary_model) > 0) {
        indirect <- discover_all_indirect_effects(
          model = preliminary_model,
          max_chain_length = auto_indirect_max_length,
          computational_limit = auto_indirect_limit
        )
      } else {
        warning("No model structure provided for automatic indirect effect discovery")
        indirect <- NULL
      }
    }
    
    # Option 2: Structured IV/M/DV automatic generation (existing functionality)
    if (is.list(indirect) && all(names(indirect) %in% c("IV", "M", "DV"))) {
      x <- mediation
      labels <- names(x)
      if (isTRUE(use.letters)) {
        x <- lapply(seq(x), function(i) {
          paste0(letters[seq_along(x[[i]])], "_", labels[i])
        })
      } else {
        x <- lapply(seq(x), function(i) {
          paste0(x[[i]], "_", labels[i])
        })
      }
      x <- stats::setNames(x, labels)
      indirect.names <- lapply(indirect$M, function(x) {
        paste0(
          rep(indirect$IV, each = length(indirect$DV)), "_", x, "_",
          rep(indirect$DV, length(indirect$IV))
        )
      })
      indirect.names <- unlist(indirect.names)
      indirect2 <- lapply(indirect$M, function(x) {
        paste0(
          rep(indirect$IV, each = length(indirect$DV)), "_", x, " * ", x,
          "_", rep(indirect$DV, length(indirect$IV))
        )
      })
      indirect.list <- as.list(unlist(indirect2))
      stats::setNames(indirect.list, indirect.names)
      indirect <- stats::setNames(indirect.list, indirect.names)
    }
    
    # Option 3: Manual specification (existing functionality)
    # No additional processing needed - indirect is already a named list
    
    # Generate lavaan syntax for all options
    if (!is.null(indirect) && length(indirect) > 0) {
      indirect <- process_vars(
        indirect,
        symbol = ":=", collapse = " * ", title =
          "[--------Mediations (indirect effects)---------]"
      )
    }
  }
  if (!is.null(mediation)) {
    mediation <- process_vars(
      mediation,
      symbol = "~", label = label, title =
        "[-----------Mediations (named paths)-----------]"
    )
  }
  if (!is.null(regression)) {
    regression <- process_vars(
      regression,
      symbol = "~", title =
        "[---------Regressions (Direct effects)---------]"
    )
  }
  if (!is.null(covariance)) {
    covariance <- process_vars(
      covariance,
      symbol = "~~", title =
        "[------------------Covariances-----------------]"
    )
  }
  if (!is.null(intercept)) {
    title <- "[------------------Intercepts------------------]"
    header <- paste0(hashtag, paste0("# ", title, "\n\n"))
    intercept <- paste0(
      header, paste0(intercept, " ~ 1", collapse = "\n"),
      "\n\n"
    )
  }
  if (!is.null(threshold)) {
    threshold <- process_vars(
      threshold,
      symbol = "|", title =
        "[------------------Thresholds------------------]"
    )
  }
  if (!is.null(constraint.equal) || !is.null(constraint.smaller) ||
    !is.null(constraint.larger)) {
    title <- "[-----------------Constraints------------------]"
    header <- paste0(hashtag, paste0("# ", title, "\n\n"))
    if (!is.null(constraint.equal)) {
      constraint.equal <- process_vars(constraint.equal,
        symbol = "==",
        header = NULL, spacer = "\n"
      )
    }
    if (!is.null(constraint.smaller)) {
      constraint.smaller <- process_vars(constraint.smaller,
        symbol = "<",
        header = NULL, spacer = "\n"
      )
    }
    if (!is.null(constraint.larger)) {
      constraint.larger <- process_vars(constraint.larger,
        symbol = ">",
        header = NULL, spacer = "\n"
      )
    }
    constraint <- paste0(
      header, constraint.equal, constraint.smaller,
      constraint.larger, "\n"
    )
  }
  if (!is.null(custom)) {
    title <- "[------------Custom Specifications-------------]"
    header <- paste0(hashtag, paste0("# ", title, "\n\n"))
    custom <- paste0(header, custom)
  }
  paste0(latent, mediation, regression, covariance, indirect, intercept,
    threshold, constraint, custom,
    collapse = ""
  )
}
