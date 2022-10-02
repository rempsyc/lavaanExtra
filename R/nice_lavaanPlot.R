#' @title Make a quick `lavaanPlot`
#'
#' @description Make a quick and decent-looking `lavaanPlot`.
#'
#' @param model SEM or CFA model to plot.
#' @param node_options Shape and font name.
#' @param edge_options Colour of edges.
#' @param coefs Logical, whether to plot coefficients.
#' @param stand Logical, whether to standardized coefficients.
#' @param covs Logical, whether to plot covariances
#' @param stars Logical, whether to plot significance stars.
#' @param sig Significance threshold.
#' @param graph_options Read from left to right, rather than from top to bottom.
#' @param ... Arguments to be passed to function `lavaanPlot::lavaanPlot`.
#' @keywords CFA lavaan plot fit
#' @return A lavaanPlot, of classes `c("grViz", "htmlwidget")`, representing the
#'         specified `lavaan` model.
#' @export
#' @examples
#' (latent <- list(visual = paste0("x", 1:3),
#'                 textual = paste0("x", 4:6),
#'                 speed = paste0("x", 7:9)))
#'
#' HS.model <- write_lavaan(latent = latent)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- cfa(HS.model, HolzingerSwineford1939)
#' nice_lavaanPlot(fit)
#' @section Illustrations:
#'
#' \if{html}{\figure{lavaanPlot.png}{options: width="400"}}

nice_lavaanPlot <- function(
    model, node_options = list(shape = "box", fontname = "Helvetica"),
    edge_options = list(color = "grey"), coefs = TRUE, stand = TRUE,
    covs = FALSE, stars = list("regress"), sig = .05,
    graph_options = list(rankdir = "LR"), ...) {
  rlang::check_installed(c(
    "lavaanPlot", "DiagrammeRsvg", "rsvg", "png", "webshot"),
    reason = "for this function.")
  lavaanPlot::lavaanPlot(model = model,
                         node_options = node_options,
                         edge_options = edge_options,
                         coefs = coefs,
                         stand = stand,
                         covs = covs,
                         stars = stars,
                         graph_options = graph_options,
                         sig = sig,
                         ...)
  }
