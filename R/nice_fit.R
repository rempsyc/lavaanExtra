#' @title Extract relevant fit indices from lavaan model
#'
#' @description Compares fit from one or several lavaan models. Also
#' optionally includes references values. The reference fit values are
#' based on Schreiber et al. (2006).
#'
#' Schreiber, J. B., Nora, A., Stage, F. K., Barlow, E. A., & King, J. (2006). Reporting structural equation modeling and confirmatory factor analysis results: A review. *The Journal of educational research*, *99*(6), 323-338. https://doi.org/10.3200/JOER.99.6.323-338
#'
#' @param ... lavaan model objects to extract fit indices from
#' @param nice_table Logical, whether to print the table as a `rempsyc::nice_table`
#'                   as well as print the reference values at the bottom of the table.
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

nice_fit <- function(..., nice_table = FALSE) {
  x <- lapply(list(...), nice_fit_internal)
  df <- do.call(rbind, x)
  Model <- sapply(match.call(expand.dots = FALSE)$`...`, as.character)
  df <- cbind(Model, df)
  row.names(df) <- NULL
  if (nice_table) {
    if (isFALSE(requireNamespace("rempsyc", quietly = TRUE))) {
      cat("The package `rempsyc` is required for this feature\n",
          "Would you like to install it?")
      if (utils::menu(c("Yes", "No")) == 1) {
        utils::install.packages('rempsyc', repos = c(
          rempsyc = 'https://rempsyc.r-universe.dev',
          CRAN = 'https://cloud.r-project.org'))
      } else (stop(
        'The `nice_table` feature relies on the `rempsyc` package.
    You can install it manually with:
    install.packages("rempsyc", repos = c(
          rempsyc = "https://rempsyc.r-universe.dev",
          CRAN = "https://cloud.r-project.org")'))
    }
    table <- rempsyc::nice_table(df)
    table <- flextable::add_footer_row(table, values = c(Model = "Ideal Value",
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
    table <- flextable::hline(table, i = nrow(df))
    df <- table
  }
  df
}

nice_fit_internal <- function(fit) {
  x <- lavaan::fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli",
                                  "rmsea", "srmr", "aic", "bic"))
  x <- as.data.frame(t(as.data.frame(x)))
  chi2.df <- x$chisq / x$df
  x <- cbind(x[1:2], chi2.df, x[3:9])
  x <- round(x, 3)
  names(x)[(c(1, 4:10))] <- c("chi2", "p", toupper(names(x)[5:10]))
  x
}
