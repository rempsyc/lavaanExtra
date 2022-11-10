#' @title Extract relevant fit indices from lavaan model
#'
#' @description Compares fit from one or several lavaan models. Also
#' optionally includes references values. The reference fit values are
#' based on Schreiber et al. (2006).
#'
#' @param ... lavaan model objects to extract fit indices from
#' @param model.labels Model labels to use. Default to the
#' model names.
#' @param nice_table Logical, whether to print the table as a
#'                   `rempsyc::nice_table` as well as print the
#'                   reference values at the bottom of the table.
#' @keywords lavaan structural equation modeling path analysis CFA
#' @return A dataframe, representing select fit indices (chi2, df, chi2/df,
#'         p-value of the chi2 test, CFI, TLI, RMSEA, SRMR, AIC, and BIC).
#' @export
#' @references Schreiber, J. B., Nora, A., Stage, F. K., Barlow, E. A., & King,
#' J. (2006). Reporting structural equation modeling and confirmatory factor
#' analysis results: A review. *The Journal of educational research*, *99*(6),
#' 323-338. https://doi.org/10.3200/JOER.99.6.323-338
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
#' fit <- sem(HS.model, data=HolzingerSwineford1939)
#' nice_fit(fit)

nice_fit <- function(..., model.labels, nice_table = FALSE) {
  x <- lapply(list(...), nice_fit_internal)
  df <- do.call(rbind, x)
  if (!missing(model.labels)) {
    Model <- model.labels
    # verify labels match number of objects
    if(!length(x) == length(model.labels)){
      warning("Number of model.labels and models do not match. Broadcasting...")
    }


  } else {
    Model <- vapply(match.call(expand.dots = FALSE)$`...`, as.character,
                    FUN.VALUE = "character")
  }
  df <- cbind(Model, df)
  row.names(df) <- NULL
  if (nice_table) {
    rlang::check_installed("rempsyc", reason = "for this feature.")
    table <- rempsyc::nice_table(df)
    table <- flextable::add_footer_row(table, values = c(
      Model = "Ideal Value",
      chi2 = "\u2014",
      df = "\u2014",
      chi2.df = "< 2 or 3",
      p = "> .05",
      CFI = "\u2265 .95",
      TLI = "\u2265 .95",
      RMSEA = "< .06-.08",
      SRMR = "\u2264 .08",
      AIC = "Smaller is better",
      BIC = "Smaller is better"),
      colwidths = rep(1, length(table$col_keys)))
    table <- flextable::bold(table, part = "footer")
    table <- flextable::align(table, align = "center", part = "all")
    table <- flextable::font(table, part = "all", fontname = "Times New Roman")
    nice.borders <- list("width" = 0.5, color = "black", style = "solid")
    #table <- flextable::hline(table, i = nrow(df), border = nice.borders)
    table <- flextable::hline_bottom(
      table, part = "body", border = nice.borders)
    table <- flextable::hline_bottom(
      table, part = "footer", border = nice.borders)
    df <- table
  }
  df
}

nice_fit_internal <- function(fit) {
  x <- lavaan::fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli",
                                  "rmsea", "srmr", "aic", "bic"))
  #names(x)[1] <- "Model"
  x <- as.data.frame(t(as.data.frame(x)))
  chi2.df <- x$chisq / x$df
  x <- cbind(x[1:2], chi2.df, x[3:9])
  x <- round(x, 3)
  names(x)[(c(1, 4:10))] <- c("chi2", "p", toupper(names(x)[5:10]))
  x
}

