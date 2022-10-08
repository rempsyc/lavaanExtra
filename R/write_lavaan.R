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
#' @param latent Latent variable indicators (`=~` symbol: "is measured by").
#' @param intercept Intercept indicators (`~ 1` symbol: "intercept").
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
#' @keywords lavaan structural equation modeling path analysis CFA
#' @return A character string, representing the specified `lavaan` model.
#' @export
#' @examples
#' (latent <- list(visual = paste0("x", 1:3),
#'                 textual = paste0("x", 4:6),
#'                 speed = paste0("x", 7:9)))
#'
#' HS.model <- write_lavaan(latent = latent)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- lavaan(HS.model, data = HolzingerSwineford1939,
#'               auto.var = TRUE, auto.fix.first = TRUE,
#'               auto.cov.lv.x = TRUE)
#' summary(fit, fit.measures=TRUE)

write_lavaan <- function(mediation = NULL, regression = NULL, covariance = NULL,
                         indirect = NULL, latent = NULL, intercept = NULL,
                         constraint.equal = NULL, constraint.smaller = NULL,
                         constraint.larger = NULL, custom = NULL, label = FALSE,
                         use.letters = FALSE) {
  constraint <- NULL
  hashtag <- sprintf("%s\n", paste0(rep("#", 50), collapse = ""))
  process_vars <- function(
    x, symbol, label = FALSE, collapse = " + ", header = paste0(
      hashtag, paste0("# ", title, "\n\n")), title = NULL, spacer = "\n\n") {
    if(isTRUE(label)) {
      labels <- paste0(names(x))
      if (isTRUE(use.letters)) {
        x <- lapply(seq(x), function(i) {
          paste0(letters[seq(length(x[[i]]))], "_", labels[i], "*", x[[i]])
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
    latent <- process_vars(latent, symbol = "=~", title =
                             "[-----Latent variables (measurement model)-----]")
  }
  #### AUTOMATIC INDIRECT EFFECTS!!! ####
  if (!is.null(indirect)) {
    if (all(names(indirect) %in% c("IV", "M", "DV"))) {
      x <- mediation
      labels <- names(x)
      if (isTRUE(use.letters)) {
        x <- lapply(seq(x), function(i) {
          paste0(letters[seq(length(x[[i]]))], "_", labels[i])
        })
      } else {
        x <- lapply(seq(x), function(i) {
          paste0(x[[i]], "_", labels[i])
        })
      }
      x <- stats::setNames(x, labels)
      indirect.names <- lapply(indirect$M, function(x) {
        paste0(rep(indirect$IV, each = length(indirect$DV)), "_", x, "_",
               rep(indirect$DV, length(indirect$IV)))
      })
      indirect.names <- unlist(indirect.names)
      indirect2 <- lapply(indirect$M, function(x) {
        paste0(rep(indirect$IV, each = length(indirect$DV)), "_", x, " * ", x,
               "_", rep(indirect$DV, length(indirect$IV)))
      })
      indirect.list <- as.list(unlist(indirect2))
      stats::setNames(indirect.list, indirect.names)
      indirect <- stats::setNames(indirect.list, indirect.names)
    }
    indirect <- process_vars(
      indirect, symbol = ":=", collapse = " * ", title =
        "[--------Mediations (indirect effects)---------]")
  }
  if (!is.null(mediation)) {
    mediation <- process_vars(
      mediation, symbol = "~", label = label, title =
        "[-----------Mediations (named paths)-----------]")
  }
  if (!is.null(regression)) {
    regression <- process_vars(
      regression, symbol = "~", title =
        "[---------Regressions (Direct effects)---------]")
  }
  if (!is.null(covariance)) {
    covariance <- process_vars(
      covariance, symbol = "~~", title =
        "[------------------Covariances-----------------]")
  }
  if (!is.null(intercept)) {
    title <- "[------------------Intercepts------------------]"
    header <- paste0(hashtag, paste0("# ", title, "\n\n"))
    intercept <- paste0(header, paste0(intercept, " ~ 1", collapse = "\n"),
                        "\n\n")
  }
  if (!is.null(constraint.equal) || !is.null(constraint.smaller) ||
      !is.null(constraint.larger)) {
    title <- "[-----------------Constraints------------------]"
    header <- paste0(hashtag, paste0("# ", title, "\n\n"))
    if (!is.null(constraint.equal)) {
      constraint.equal <- process_vars(constraint.equal, symbol = "==",
                                       header = NULL, spacer = "\n")
    }
    if (!is.null(constraint.smaller)) {
      constraint.smaller <- process_vars(constraint.smaller, symbol = "<",
                                         header = NULL, spacer = "\n")
    }
    if (!is.null(constraint.larger)) {
      constraint.larger <- process_vars(constraint.larger, symbol = ">",
                                        header = NULL, spacer = "\n")
    }
    constraint <- paste0(header, constraint.equal, constraint.smaller,
                         constraint.larger, "\n")
  }
  if (!is.null(custom)) {
    title <- "[------------Custom Specifications-------------]"
    header <- paste0(hashtag, paste0("# ", title, "\n\n"))
    custom <- paste0(header, custom)
  }
  paste0(latent, mediation, regression, covariance, indirect, intercept,
         constraint, custom, collapse = "")
}
