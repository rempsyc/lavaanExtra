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
#' @param fit_stats Logical or character vector. If `TRUE`, displays a default set of fit
#'              statistics (CFI, TLI, RMSEA, SRMR) at the bottom of the plot. If a character
#'              vector, displays only the specified fit indices (e.g., `c("cfi", "rmsea")`).
#'              Available indices include: "chisq", "df", "pvalue", "cfi", "tli", "rmsea",
#'              "srmr", "aic", "bic". Defaults to `NULL` (no fit statistics displayed).
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
#'
#' # With fit statistics
#' nice_lavaanPlot(fit, title = "Three-Factor CFA Model", fit_stats = TRUE)
#'
#' # With specific fit statistics
#' nice_lavaanPlot(fit, fit_stats = c("cfi", "tli", "rmsea", "srmr", "chisq", "pvalue"))
#' @section Illustrations:
#'
#' \if{html}{\figure{lavaanPlot.png}{options: width="400"}}

nice_lavaanPlot <- function(
  model, node_options = list(shape = "box", fontname = "Helvetica"),
  edge_options = c(color = "black"), coefs = TRUE, stand = TRUE,
  covs = FALSE, stars = c("regress", "latent", "covs"), sig = .05,
  graph_options = c(rankdir = "LR"), title = NULL, note = NULL,
  fit_stats = NULL, ...
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

  # Extract and format fit statistics if requested
  fit_stats_text <- NULL
  if (!is.null(fit_stats)) {
    # Get fit indices from model
    fit_data <- nice_fit(model, verbose = FALSE)

    # Determine which indices to display
    if (isTRUE(fit_stats)) {
      # Default set of fit indices
      indices_to_show <- c("cfi", "tli", "rmsea", "srmr")
    } else if (is.character(fit_stats)) {
      # User-specified indices
      indices_to_show <- tolower(fit_stats)
    } else {
      stop("fit_stats must be TRUE, FALSE, NULL, or a character vector of fit index names")
    }

    # Filter available indices
    available_indices <- tolower(names(fit_data))
    indices_to_show <- intersect(indices_to_show, available_indices)

    if (length(indices_to_show) > 0) {
      # Format fit statistics as text
      fit_values <- sapply(indices_to_show, function(idx) {
        val <- fit_data[[idx]]
        if (is.numeric(val)) {
          # Format based on typical ranges for each index
          if (idx %in% c("chisq", "aic", "bic")) {
            formatted <- sprintf("%.2f", val)
          } else if (idx %in% c("df")) {
            formatted <- sprintf("%.0f", val)
          } else if (idx %in% c("pvalue")) {
            formatted <- if (val < 0.001) "&lt; .001" else sprintf("%.3f", val)
          } else {
            # CFI, TLI, RMSEA, SRMR - typically 3 decimal places
            formatted <- sprintf("%.3f", val)
          }
        } else {
          formatted <- as.character(val)
        }
        formatted
      })

      # Create fit stats display text
      # Format as "CFI = 0.931, TLI = 0.896, RMSEA = 0.092, SRMR = 0.058"
      fit_parts <- paste0(toupper(indices_to_show), " = ", fit_values)
      fit_stats_text <- paste(fit_parts, collapse = ", ")
    }
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

  # Determine what to include in label
  has_title <- !is.null(title)
  has_note <- !is.null(note)
  has_fit_stats <- !is.null(fit_stats_text)

  # Build the label based on what's provided
  if (has_title || has_note || has_fit_stats) {
    # Start building HTML table
    html_rows <- character(0)

    if (has_title) {
      title_escaped <- html_escape(title)
      html_rows <- c(
        html_rows,
        "<TR><TD><FONT POINT-SIZE=\"14\"><B>", title_escaped, "</B></FONT></TD></TR>"
      )
      if (has_note || has_fit_stats) {
        html_rows <- c(html_rows, "<TR><TD HEIGHT=\"10\"></TD></TR>") # Spacer
      }
    }

    if (has_note) {
      note_escaped <- html_escape(note)
      html_rows <- c(
        html_rows,
        "<TR><TD><FONT POINT-SIZE=\"10\">", note_escaped, "</FONT></TD></TR>"
      )
      if (has_fit_stats) {
        html_rows <- c(html_rows, "<TR><TD HEIGHT=\"10\"></TD></TR>") # Spacer
      }
    }

    if (has_fit_stats) {
      html_rows <- c(
        html_rows,
        "<TR><TD><FONT POINT-SIZE=\"9\">", fit_stats_text, "</FONT></TD></TR>"
      )
    }

    # Combine into full HTML table
    graph_options$label <- paste0(
      "<<TABLE BORDER=\"0\" CELLBORDER=\"0\" CELLSPACING=\"0\">",
      paste(html_rows, collapse = ""),
      "</TABLE>>"
    )

    # Position label at top if title is present, otherwise at bottom
    graph_options$labelloc <- if (has_title) "t" else "b"
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
