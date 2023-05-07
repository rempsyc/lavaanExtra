#' @title Extract relevant fit indices from lavaan model
#'
#' @description Compares fit from one or several lavaan models. Also
#' optionally includes references values. The reference fit values are
#' based on Schreiber et al. (2006).
#'
#' @param model lavaan model object(s) to extract fit indices from
#' @param model.labels Model labels to use. If a named list is provided
#' for `model`, default to the names of the list. Otherwise, if the list
#' is unnamed, defaults to generic numbering.
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
#' @examplesIf requireNamespace("lavaan", quietly = TRUE)
#' (latent <- list(
#'   visual = paste0("x", 1:3),
#'   textual = paste0("x", 4:6),
#'   speed = paste0("x", 7:9)
#' ))
#'
#' (regression <- list(
#'   ageyr = c("visual", "textual", "speed"),
#'   grade = c("visual", "textual", "speed")
#' ))
#'
#' HS.model <- write_lavaan(latent = latent, regression = regression)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- sem(HS.model, data = HolzingerSwineford1939)
#' nice_fit(fit)
#'
nice_fit <- function(model, model.labels, nice_table = FALSE) {

  if (inherits(model, "list") && all(unlist(lapply(model, inherits, "lavaan")))) {
    models.list <- model
  } else if (inherits(model, "lavaan")) {
    models.list <- list(model)
  } else {
    stop(paste("Model must be of class 'lavaan' or be a 'list()' of lavaan models (using 'c()' won't work).\n",
               "Have you perhaps provided the model specification (of class character) instead of the sem or cfa object?"))
  }

  x <- lapply(models.list, nice_fit_internal)
  df <- do.call(rbind, x)
  if (!missing(model.labels)) {
    Model <- model.labels
    # verify labels match number of objects
    if (length(x) < length(model.labels)) {
      stop("Number of labels exceeds number of models.")
    } else if (!length(x) == length(model.labels)) {
      warning("Number of models and labels do not match.")
    }
    } else if (!is.null(names(models.list))) {
        Model <- names(models.list)
      } else {
      Model <- paste0("Model ", seq_len(length(models.list)))
  }
  df <- cbind(Model, df)
  row.names(df) <- NULL
  if (nice_table) {
    rlang::check_installed("rempsyc", reason = "for this feature.")
    table <- rempsyc::nice_table(df)
    table <- flextable::add_footer_row(table,
      values = c(
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
        BIC = "Smaller is better"
      ),
      colwidths = rep(1, length(table$col_keys))
    )
    table <- flextable::bold(table, part = "footer")
    table <- flextable::align(table, align = "center", part = "all")

    table <- flextable::footnote(table, i = 1, j = 1, value = flextable::as_paragraph(
      "As proposed by Schreiber et al. (2006)."), ref_symbols = "a", part = "footer")
    table <- flextable::bold(table, i = 2, bold = FALSE, part = "footer")
    table <- flextable::align(table, i = 2, part = "footer", align = "left")

    table <- flextable::font(table, part = "all", fontname = "Times New Roman")
    nice.borders <- list("width" = 0.5, color = "black", style = "solid")
    table <- flextable::hline_bottom(
      table,
      part = "body", border = nice.borders
    )
     table <- flextable::hline(table, i = 1, border = nice.borders, part = "footer")
    df <- table
  }
  df
}

nice_fit_internal <- function(fit) {
  x <- lavaan::fitMeasures(fit, c(
    "chisq", "df", "pvalue", "cfi", "tli",
    "rmsea", "srmr", "aic", "bic"
  ))
  x <- as.data.frame(t(as.data.frame(x)))
  chi2.df <- x$chisq / x$df
  x <- cbind(x[1:2], chi2.df, x[3:9])
  x <- round(x, 3)
  names(x)[(c(1, 4:10))] <- c("chi2", "p", toupper(names(x)[5:10]))
  x
}
