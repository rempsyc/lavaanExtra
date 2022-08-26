#' @title Test function to print lavaan fit summary
#'
#' @description NA
#'
#' @param fit model to fit.
#' @keywords CFA, lavaan, plot, fit
#' @export
#' @examples
#' HS.model <- 'visual =~ x1 + x2 + x3'
#' library(lavaan)
#' fit <- lavaan::cfa(model = HS.model, data = HolzingerSwineford1939)
#' foo(fit)

foo <- function(fit){
  print(summary(fit))
}
