#' @title Extract relevant modification indices along item labels
#'
#' @description Extract relevant modification indices along item labels,
#'  with a similarity score provided to help guide decision-making
#'  for removing redundant items with high covariance.
#'
#' @param fit lavaan fit object to extract modification indices from
#' @param labels Dataframe of labels. If the original data
#'    frame is provided, and that it contains labelled
#'    variables, will automatically attempt to extract
#'    the correct labels from the dataframe.
#' @param method Method for distance calculation from
#'    [stringdist::stringsim]. Defaults to `"lcs"`.
#' @param sort Logical. If TRUE, sort the output using the values of
#'  the modification index values. Higher values appear first.
#'  Defaults to `TRUE`.
#' @param ... Arguments to be passed to [lavaan::modindices]
#' @return A dataframe, including the outcome ("lhs"), predictor ("rhs"),
#'         standardized regression coefficient ("std.all"), corresponding
#'         p-value, as well as the unstandardized regression coefficient
#'         ("est") and its confidence interval ("ci.lower", "ci.upper").
#' @export
#' @examplesIf requireNamespace("lavaan", quietly = TRUE) && requireNamespace("sjlabelled", quietly = TRUE) && requireNamespace("stringdist", quietly = TRUE)
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
#' nice_modindices(fit, maximum.number = 5)
#' data_labels <- data.frame(
#'   x1 = "I have good visual perception",
#'   x2 = "I have good cube perception",
#'   x3 = "I have good at lozenge perception",
#'   x4 = "I have paragraph comprehension",
#'   x5 = "I am good at sentence completion",
#'   x6 = "I excel at finding the meaning of words",
#'   x7 = "I am quick at doing mental additions",
#'   x8 = "I am quick at counting dots",
#'   x9 = "I am quick at discriminating straight and curved capitals"
#' )
#' nice_modindices(fit, maximum.number = 10, labels = data_labels, op = "~~")
#'
#' x <- HolzingerSwineford1939
#' x <- sjlabelled::set_label(x, label = c(rep("", 6), data_labels))
#' fit <- sem(HS.model, data = x)
#' nice_modindices(fit, maximum.number = 10, op = "~~")
nice_modindices <- function(fit,
                            labels = NULL,
                            method = "lcs",
                            sort = TRUE,
                            ...) {
  x <- lavaan::modindices(fit, sort = sort, ...)
  x <- x[1:4]
  rownames(x) <- NULL

  if (is.null(labels)) {
    if (requireNamespace("sjlabelled", quietly = TRUE)) {
      dat <- insight::get_data(fit)
      labels <- sjlabelled::get_label(dat)
      if (all(labels == "")) {
        labels <- NULL
      }
    }
  }
  if (!is.null(labels)) {
    insight::check_if_installed("stringdist")
    if (!inherits(labels, "data.frame")) {
      labels <- as.data.frame(as.list(labels))
    }
    for (i in seq_len(nrow(x))) {
      x[i, "lhs.labels"] <- ifelse(
        x$lhs[i] %in% names(labels),
        labels[which(x$lhs[i] == names(labels))],
        NA
      )
      x[i, "rhs.labels"] <- ifelse(
        x$rhs[i] %in% names(labels),
        labels[which(x$rhs[i] == names(labels))],
        NA
      )
    }
    if (all(is.na(x$lhs.labels))) {
      x$similarity <- NA
    } else {
      x$similarity <- stringdist::stringsim(x$lhs.labels,
        x$rhs.labels,
        method = method
      )
    }
    x$similar <- x$similarity > .50
    x$similar <- ifelse(is.na(x$similar), FALSE, x$similar <- x$similar)
  }
  x
}
