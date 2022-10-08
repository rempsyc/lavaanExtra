#' @title Extract relevant indirect effects indices from lavaan model
#'
#' @description Extract relevant indirect effects indices from lavaan model
#'              through `lavaan::parameterEstimates)` with
#'              `standardized = TRUE`. In this case, the beta (B) represents
#'              the resulting `std.all` column.
#' @param fit lavaan fit object to extract fit indices from
#' @param nice_table Logical, whether to print the table as a
#'                   `rempsyc::nice_table` as well as print the
#'                   reference values at the bottom of the table.
#' @param underscores_to_arrows Logical, whether to convert underscorse
#' to arrows in the "Indirect Effect column".
#' @param ... Arguments to be passed to `rempsyc::nice_table`
#' @keywords lavaan structural equation modeling path analysis CFA
#' @return A dataframe, including the indirect effect, corresponding paths,
#'         standardized regression coefficient, and corresponding p-value.
#' @export
#' @examples
#'
#' (latent <- list(visual = paste0("x", 1:3),
#'                 textual = paste0("x", 4:6),
#'                 speed = paste0("x", 7:9)))
#'
#' (mediation <- list(speed = "visual",
#'                    textual = "visual",
#'                    visual = c("ageyr", "grade")))
#'
#' (indirect <- list(IV = c("ageyr", "grade"),
#'                   M = "visual",
#'                   DV = c("speed", "textual")))
#'
#' HS.model <- write_lavaan(mediation, indirect = indirect,
#'                          latent = latent, label = TRUE)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- lavaan(HS.model, data=HolzingerSwineford1939,
#'               auto.var=TRUE, auto.fix.first=TRUE,
#'               auto.cov.lv.x=TRUE)
#' lavaan_ind(fit)

lavaan_ind <- function(fit, nice_table = FALSE, underscores_to_arrows = TRUE,
                       ...) {
  x <- lavaan::parameterEstimates(fit, standardized = TRUE)
  x <- x[which(x["op"] == ":="),]
  x <- x[c("lhs", "rhs", "std.all", "pvalue")]
  if (isTRUE(underscores_to_arrows)) {
    x$lhs <- gsub("_", " \u2192 ", x$lhs)
  }
  names(x) <- c("Indirect Effect", "Paths", "B", "p")
  if (nice_table) {
    rlang::check_installed("rempsyc", reason = "for this feature.")
    x <- rempsyc::nice_table(x, ...)
  }
  x
}
