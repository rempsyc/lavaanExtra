#' @title Make a quick `lavaanPlot`
#'
#' @description Make a quick and decent-looking `lavaanPlot`.
#'
#' @param model SEM or CFA model to plot.
#' @param node_options Shape and font name.
#' @param edge_options Colour of edges.
#' @param coefs Logical, whether to plot coefficients. Defaults to TRUE.
#' @param stand Logical, whether to use standardized coefficients.
#'              Defaults to TRUE.
#' @param covs Logical, whether to plot covariances. Defaults to FALSE.
#' @param stars Which links to plot significance stars for. One of
#'              `c("regress", "latent", "covs")`.
#' @param sig Which significance threshold to use to plot coefficients (defaults
#'  to .05). To plot all coefficients, set `sig` to 1.
#' @param graph_options Read from left to right, rather than from top to bottom.
#' @param title Optional title for the plot (HTML-safe Graphviz label).
#' @param note Optional note or caption for the plot (HTML-safe Graphviz label).
#' @param ... Arguments to be passed to function [lavaanPlot::lavaanPlot].
#' @return A lavaanPlot, of classes `c("grViz", "htmlwidget")`, representing the
#'         specified `lavaan` model.
#' @export
#' @examplesIf requireNamespace("lavaan", quietly = TRUE) && requireNamespace("lavaanPlot", quietly = TRUE) && requireNamespace("DiagrammeRsvg", quietly = TRUE)
#' x <- paste0("x", 1:9)
#' (latent <- list(
#'   visual = x[1:3],
#'   textual = x[4:6],
#'   speed = x[7:9]
#' ))
#'
#' HS.model <- write_lavaan(latent = latent)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- cfa(HS.model, HolzingerSwineford1939)
#' nice_lavaanPlot(fit)
#'
#' # With title and note
#' nice_lavaanPlot(fit, title = "Three-Factor CFA Model", note = "Holzinger-Swineford Dataset")
#' @section Illustrations:
#'
#' \if{html}{\figure{lavaanPlot.png}{options: width="400"}}

nice_lavaanPlot <- function(
  model, node_options = list(shape = "box", fontname = "Helvetica"),
  edge_options = c(color = "black"), coefs = TRUE, stand = TRUE,
  covs = FALSE, stars = c("regress", "latent", "covs"), sig = .05,
  graph_options = c(rankdir = "LR"), title = NULL, note = NULL, ...
) {
  insight::check_if_installed(
    c(
      "lavaanPlot", "DiagrammeRsvg",
      "rsvg", "png", "webshot"
    ),
    reason = "for this function."
  )

  # Construct HTML label if title or note is provided
  if (!is.null(title) || !is.null(note)) {
    label_parts <- character(0)
    if (!is.null(title)) {
      label_parts <- c(label_parts, title)
    }
    if (!is.null(note)) {
      label_parts <- c(label_parts, note)
    }
    label <- paste0("<", paste(label_parts, collapse = "<br/><br/>"), ">")

    # Merge label into graph_options
    # Convert graph_options to list if it's a vector
    if (!is.list(graph_options)) {
      graph_options <- as.list(graph_options)
    }
    graph_options$labelloc <- "t"
    graph_options$label <- label
  }

  lavaanPlot::lavaanPlot(
    model = model,
    node_options = node_options,
    edge_options = edge_options,
    coefs = coefs,
    stand = stand,
    covs = covs,
    stars = stars,
    graph_options = graph_options,
    sig = sig,
    ...
  )
}
