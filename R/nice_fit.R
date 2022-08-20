#' @title Extract relevant fit indices from lavaan model
#'
#' @description Vector-based lavaan syntax interpreter.
#'
#' @param fit lavaan fit object to extract fit indices from
#' @keywords lavaan, structural equation modeling, path analysis, CFA
#' @export
#' @examples
#' (latent <- list(visual = paste0("x", 1:3),
#'                 textual = paste0("x", 4:6),
#'                 speed = paste0("x", 7:9)))
#'
#' (regression <- list(ageyr = c("visual", "textual", "speed"),
#'                     grade = c("visual", "textual", "speed")))
#'
#' HS.model <- write_lavaan(latent = latent, regression = regression)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- lavaan(HS.model, data=HolzingerSwineford1939,
#'               auto.var=TRUE, auto.fix.first=TRUE,
#'               auto.cov.lv.x=TRUE)
#' nice_fit(fit)

nice_fit <- function(fit) {
  x <- lavaan::fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli",
                                  "rmsea", "srmr", "aic", "bic"))
  x <- round(x, 3)
  x <- as.data.frame(t(as.data.frame(x)))
  names(x)[(c(1, 3, 4:9))] <- c("chi2", "p", toupper(names(x)[4:9]))
  x
}

