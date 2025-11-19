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
#' @param title Optional title for the plot, positioned at the top. Plain text only; 
#'              special characters like <, >, & are automatically escaped for Graphviz 
#'              compatibility. Note: This will override any `label` or `labelloc` settings 
#'              in `graph_options`.
#' @param note Optional note or caption for the plot, positioned at the bottom when 
#'              used alone, or displayed below the title with smaller font when both are 
#'              provided. Plain text only; special characters are automatically escaped. 
#'              Note: This will override any `label` or `labelloc` settings in `graph_options`.
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

  # HTML escape function to handle special characters
  html_escape <- function(text) {
    text <- gsub("&", "&amp;", text, fixed = TRUE)
    text <- gsub("<", "&lt;", text, fixed = TRUE)
    text <- gsub(">", "&gt;", text, fixed = TRUE)
    text <- gsub("\"", "&quot;", text, fixed = TRUE)
    text
  }
  
  # Construct HTML label if title or note is provided
  # Convert graph_options to list if it's a vector
  if (!is.list(graph_options)) {
    graph_options <- as.list(graph_options)
  }
  
  # Warn if title/note will override existing label or labelloc
  if (!is.null(title) || !is.null(note)) {
    if (!is.null(graph_options$label) || !is.null(graph_options$labelloc)) {
      warning("title/note parameters override graph_options$label and graph_options$labelloc")
    }
  }
  
  if (!is.null(title) && !is.null(note)) {
    # Both title and note: create HTML table for visual separation
    # Title at top of label block, note at bottom with smaller font
    title_escaped <- html_escape(title)
    note_escaped <- html_escape(note)
    graph_options$label <- paste0(
      "<<TABLE BORDER=\"0\" CELLBORDER=\"0\" CELLSPACING=\"0\">",
      "<TR><TD><FONT POINT-SIZE=\"14\"><B>", title_escaped, "</B></FONT></TD></TR>",
      "<TR><TD HEIGHT=\"10\"></TD></TR>",  # Small spacer
      "<TR><TD><FONT POINT-SIZE=\"10\">", note_escaped, "</FONT></TD></TR>",
      "</TABLE>>"
    )
    graph_options$labelloc <- "t"
  } else if (!is.null(title)) {
    # Only title: position at top
    title_escaped <- html_escape(title)
    graph_options$label <- paste0("<", title_escaped, ">")
    graph_options$labelloc <- "t"
  } else if (!is.null(note)) {
    # Only note: position at bottom
    note_escaped <- html_escape(note)
    graph_options$label <- paste0("<", note_escaped, ">")
    graph_options$labelloc <- "b"
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
