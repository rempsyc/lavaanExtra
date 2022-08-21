#' @title Vector-based lavaan syntax interpreter
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
#' lavaan_reg(fit)

lavaan_reg <- function(fit) {
  x <- lavaan::parameterEstimates(fit, standardized = TRUE)
  x <- x[which(x["op"] == "~"),]
  x <- x[c("lhs", "rhs", "std.all", "pvalue")]
  names(x) <- c("Outcome", "Predictor", "B", "p")
  x
}
