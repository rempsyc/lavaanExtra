#' @title Vector-based lavaan syntax interpreter
#'
#' @description Vector-based lavaan syntax interpreter.
#'
#' @param mediation Mediation	indicators (`~` symbol: "is regressed on"). Differs from
#'                  argument `regression` because path names can be optionally
#'                  specified automatically with argument `label`.
#' @param regression Regression indicators (`~` symbol: "is regressed on").
#' @param covariance (Residual) (co)variance indicators (`~~` symbol: "is correlated with").
#' @param indirect Indirect effect indicators (`:=` symbol: "indirect effect defined as").
#' @param latent Latent variable indicators (`=~` symbol: "is measured by").
#' @param intercept Intercept indicators (`~ 1` symbol: "intercept").
#' @param label Logical, whether to display path names for the mediation argument.
#' @keywords lavaan, structural equation modeling, path analysis, CFA
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
#' fit <- lavaan(HS.model, data=HolzingerSwineford1939,
#'               auto.var=TRUE, auto.fix.first=TRUE,
#'               auto.cov.lv.x=TRUE)
#' summary(fit, fit.measures=TRUE)

write_lavaan <- function(mediation = NULL, regression = NULL, covariance = NULL,
                         indirect = NULL, latent = NULL, intercept = NULL,
                         label = FALSE) {
  hashtag <- sprintf("%s\n", paste0(rep("#", 50), collapse = ""))
  process_vars <- function(x, symbol, label = label, collapse = " + ", title) {
    if(label) {
      labels <- paste0(names(x))
      x <- lapply(seq(x), function(i) {
        paste0(labels[i], "_", letters[seq(length(x[[i]]))], "*", x[[i]])
      })
      x <- stats::setNames(x, labels)
    }
    x <- lapply(x, paste0, collapse = collapse)
    x <- paste0(names(x), paste0(" ", symbol, " "), x, collapse = "\n")
    header <- paste0(hashtag, paste0("# ", title, "\n\n"))
    paste0(header, x, "\n\n", collapse = "")
  }
  if (!is.null(latent)) {
    latent <- process_vars(latent, symbol = "=~", label = FALSE, title =
                             "[---------------Latent variables---------------]")
  }
  if (!is.null(mediation)) {
    mediation <- process_vars(mediation, symbol = "~", label = label, title =
                                "[-----------Mediations (named paths)-----------]")
  }
  if (!is.null(regression)) {
    regression <- process_vars(regression, symbol = "~", label = FALSE, title =
                                 "[---------Regressions (Direct effects)---------]")
  }
  if (!is.null(covariance)) {
    covariance <- process_vars(covariance, symbol = "~~", label = FALSE, title =
                                 "[------------------Covariances-----------------]")
  }
  if (!is.null(indirect)) {
    indirect <- process_vars(indirect, symbol = ":=", label = FALSE,
                             collapse = " * ", title =
                               "[--------Mediations (indirect effects)---------]")
  }
  if (!is.null(intercept)) {
    title = "[------------------Intercepts------------------]"
    header <- paste0(hashtag, paste0("# ", title, "\n\n"))
    intercept <- paste0(header, paste0(intercept, " ~ 1", collapse = "\n"))
  }
  paste0(latent, mediation, regression, covariance, indirect, intercept, collapse = "")
}
