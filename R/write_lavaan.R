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
#'                 effect defined as"). If a named list is provided,
#'                 with names "IV" (independent variables), "M" (mediator),
#'                 and "DV" (dependent variables), `write_lavaan` attempts to
#'                 write indirect effects automatically. In this case, the
#'                 `mediation` argument must be specified too.
#' @param total Total effect indicators (`:=` symbol: "total
#'              effect defined as"). If a named list is provided,
#'              with names "IV" (independent variables) and "DV" (dependent 
#'              variables), `write_lavaan` attempts to write total effects 
#'              automatically by combining direct and indirect effects. In this 
#'              case, the `mediation` and `regression` arguments must be 
#'              specified too. This is particularly useful for time series and 
#'              panel data models where effects propagate across time points.
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
                         total = NULL,
                         latent = NULL,
                         intercept = NULL,
                         threshold = NULL,
                         constraint.equal = NULL,
                         constraint.smaller = NULL,
                         constraint.larger = NULL,
                         custom = NULL,
                         label = FALSE,
                         use.letters = FALSE) {
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
  #### AUTOMATIC INDIRECT EFFECTS!!! ####
  if (!is.null(indirect)) {
    if (all(names(indirect) %in% c("IV", "M", "DV"))) {
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
    indirect <- process_vars(
      indirect,
      symbol = ":=", collapse = " * ", title =
        "[--------Mediations (indirect effects)---------]"
    )
  }
  #### AUTOMATIC TOTAL EFFECTS!!! ####
  if (!is.null(total)) {
    if (all(names(total) %in% c("IV", "DV"))) {
      # Generate total effects by combining direct and indirect effects
      total_expressions <- list()
      
      for (iv in total$IV) {
        for (dv in total$DV) {
          effect_name <- paste0(iv, "_total_", dv)
          paths <- c()
          
          # Look for direct path
          if (!is.null(regression) && dv %in% names(regression) && iv %in% regression[[dv]]) {
            if (isTRUE(label)) {
              if (isTRUE(use.letters)) {
                # Find position of iv in regression for dv
                iv_pos <- which(regression[[dv]] == iv)
                direct_path <- paste0(letters[iv_pos], "_", dv)
              } else {
                direct_path <- paste0(iv, "_", dv)
              }
            } else {
              # No labels, just use coefficient reference
              direct_path <- paste0(iv, "_", dv)
            }
            paths <- c(paths, direct_path)
          }
          
          # Look for indirect paths via mediators
          if (!is.null(mediation)) {
            # Find mediators that iv predicts
            iv_to_mediators <- names(mediation)[sapply(mediation, function(x) iv %in% x)]
            # Find mediators that predict dv
            mediators_to_dv <- character(0)
            if (dv %in% names(mediation)) {
              mediators_to_dv <- mediation[[dv]]
            }
            
            # Find common mediators (mediators in both paths)
            common_mediators <- intersect(iv_to_mediators, mediators_to_dv)
            
            if (length(common_mediators) > 0) {
              for (mediator in common_mediators) {
                if (isTRUE(label)) {
                  if (isTRUE(use.letters)) {
                    # Find position of iv in mediator's predictors
                    iv_pos <- which(mediation[[mediator]] == iv)
                    iv_to_m_path <- paste0(letters[iv_pos], "_", mediator)
                    
                    # Find position of mediator in dv's predictors
                    m_pos <- which(mediation[[dv]] == mediator)
                    m_to_dv_path <- paste0(letters[m_pos], "_", dv)
                  } else {
                    iv_to_m_path <- paste0(iv, "_", mediator)
                    m_to_dv_path <- paste0(mediator, "_", dv)
                  }
                } else {
                  iv_to_m_path <- paste0(iv, "_", mediator)
                  m_to_dv_path <- paste0(mediator, "_", dv)
                }
                
                indirect_path <- paste0(iv_to_m_path, " * ", m_to_dv_path)
                paths <- c(paths, indirect_path)
              }
            }
          }
          
          # Only create total effect if there are paths
          if (length(paths) > 0) {
            total_expressions[[effect_name]] <- paste(paths, collapse = " + ")
          }
        }
      }
      
      total <- total_expressions
    }
    total <- process_vars(
      total,
      symbol = ":=", collapse = " + ", title =
        "[-----------Total effects (direct + indirect)----------]"
    )
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
  paste0(latent, mediation, regression, covariance, indirect, total, intercept,
    threshold, constraint, custom,
    collapse = ""
  )
}
