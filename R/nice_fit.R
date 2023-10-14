#' @title Extract relevant fit indices from lavaan model
#'
#' @description Compares fit from one or several lavaan models. Also
#' optionally includes references values. The reference fit values are
#' based on Schreiber (2017), Table 3.
#'
#' @details Note that `nice_fit` reports the unbiased SRMR through
#'  [lavaan::lavResiduals()] because the standard SRMR is upwardly
#'  biased (\doi{10.1007/s11336-016-9552-7}) in a noticeable
#'  way for smaller samples (thanks to James Uanhoro for this change).
#'
#'  If using `guidelines = TRUE`, please carefully consider the following 2023
#'  quote from Terrence D. Jorgensen:
#'
#'  _I do not recommend including cutoffs in the table, as doing so would
#'  perpetuate their misuse. Fit indices are not test statistics, and their
#'  suggested cutoffs are not critical values associated with known Type I
#'  error rates. Numerous simulation studies have shown how poorly cutoffs
#'  perform in model selection (e.g., , Jorgensen et al. (2018). Instead of
#'  test statistics, fit indices were designed to be measures of effect size
#'  (practical significance), which complement the chi-squared test of
#'  statistical significance. The range of RMSEA interpretations above is more
#'  reminiscent of the range of small/medium/large effect sizes proposed by
#'  Cohen for use in power analyses, which are as arbitrary as alpha levels,
#'  but at least they better respect the idea that (mis)fit is a matter of
#'  magnitude, not nearly so simple as "perfect or imperfect."_
#'
#' @param model lavaan model object(s) to extract fit indices from
#' @param model.labels Model labels to use. If a named list is provided
#' for `model`, default to the names of the list. Otherwise, if the list
#' is unnamed, defaults to generic numbering.
#' @param nice_table Logical, whether to print the table as a
#'                   [rempsyc::nice_table].
#' @param guidelines Logical, if `nice_table = TRUE`, whether to display
#'  include reference values based on Schreiber (2017), Table 3, at the
#'  bottom of the table.
#' @param stars Logical, if `nice_table = TRUE`, whether to display
#'              significance stars (defaults to `FALSE`).
#' @return A dataframe, representing select fit indices (chi2, df, chi2/df,
#'         p-value of the chi2 test, CFI, TLI, RMSEA and its 90% CI,
#'         unbiased SRMR, AIC, and BIC).
#' @export
#' @references Schreiber, J. B. (2017). Update to core reporting practices in
#' structural equation modeling. *Research in social and administrative pharmacy*,
#' *13*(3), 634-643. \doi{10.1016/j.sapharm.2016.06.006}
#' @examplesIf requireNamespace("lavaan", quietly = TRUE)
#' x <- paste0("x", 1:9)
#' (latent <- list(
#'   visual = x[1:3],
#'   textual = x[4:6],
#'   speed = x[7:9]
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
nice_fit <- function(model, model.labels, nice_table = FALSE, guidelines = TRUE, stars = FALSE) {
  if (inherits(model, "list") && all(unlist(lapply(model, inherits, "lavaan")))) {
    models.list <- model
  } else if (inherits(model, "lavaan")) {
    models.list <- list(model)
  } else {
    stop(paste(
      "Model must be of class 'lavaan' or be a 'list()' of lavaan models (using 'c()' won't work).\n",
      "Have you perhaps provided the model specification (of class character) instead of the sem or cfa object?"
    ))
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
    insight::check_if_installed("rempsyc",
      version = get_dep_version("rempsyc"),
      reason = "for this feature."
    )
    x <- df

    x[c("rmsea", "rmsea.ci.lower", "rmsea.ci.upper")] <- rempsyc::format_r(as.numeric(
      unlist(x[, c("rmsea", "rmsea.ci.lower", "rmsea.ci.upper")])
    ))
    x$`RMSEA [90% CI]` <- paste0(x$rmsea, " [", x$rmsea.ci.lower, ", ", x$rmsea.ci.upper, "]")
    x <- x[!names(x) %in% c("rmsea", "rmsea.ci.lower", "rmsea.ci.upper")]
    x <- x[c(1:7, 11, 8:10)]

    table <- rempsyc::nice_table(x, stars = stars)

    table <- flextable::align(table, align = "center", part = "all")
    if (isTRUE(guidelines)) {
      table <- flextable::add_footer_row(table,
        values = c(
          Model = "Common guidelines",
          chi2 = "\u2014",
          df = "\u2014",
          chi2.df = "< 2 or 3",
          p = "> .05",
          CFI = "\u2265 .95",
          TLI = "\u2265 .95",
          `RMSEA (90% CI)` = "< .05 [.00, .08]",
          SRMR = "\u2264 .08",
          AIC = "Smaller",
          BIC = "Smaller"
        ),
        colwidths = rep(1, length(table$col_keys))
      )
      table <- flextable::bold(table, part = "footer")
      table <- flextable::align(table, align = "center", part = "all")
      table <- flextable::footnote(table, i = 1, j = 1, value = flextable::as_paragraph(
        "Based on Schreiber (2017), Table 3."
      ), ref_symbols = "a", part = "footer")
      table <- flextable::bold(table, i = 2, bold = FALSE, part = "footer")
      table <- flextable::align(table, i = 2, part = "footer", align = "left")
    }

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
  x <- lavaan::fitMeasures(fit)
  x <- as.data.frame(t(as.data.frame(x)))
  # cfi.list <- c(x["cfi.robust"], x["cfi.scaled"], x["cfi"])
  # x$cfi <- cfi.list[[which(!is.na(cfi.list))[1]]]
  keep <- c(
    "chisq", "df", "pvalue", "cfi", "tli",
    "rmsea", "rmsea.ci.lower", "rmsea.ci.upper",
    "srmr", "aic", "bic"
  )
  x <- x[keep]
  x_srmr <- lavaan::lavResiduals(fit)$summary["usrmr", 1]
  x[names(x) == "srmr"] <- x_srmr
  chi2.df <- x$chisq / x$df
  x <- cbind(x[1:2], chi2.df, x[3:length(x)])
  x <- round(x, 3)
  x
}
