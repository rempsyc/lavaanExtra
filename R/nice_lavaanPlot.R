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
#' @param fit_stats_type Character vector specifying which types of fit statistics to display
#'              when using robust estimators. Options are `"regular"` (standard fit indices),
#'              `"scaled"` (scaled fit indices), and `"robust"` (robust fit indices).
#'              Defaults to `c("regular", "scaled", "robust")` to show all available types.
#'              Each type is displayed on a separate line. Only applicable when the model
#'              uses a robust estimator (e.g., MLR, MLM) that provides scaled/robust versions.
#' @param title_size Numeric value specifying the font size in points for the title text.
#'              Defaults to 14.
#' @param note_size Numeric value specifying the font size in points for the note/caption text.
#'              Defaults to 10.
#' @param fit_stats_size Numeric value specifying the font size in points for the fit statistics text.
#'              Defaults to 9. Increase this value for larger diagrams where the default size
#'              is too small to read.
#' @param wrap_width Numeric value or `NULL`. Specifies the maximum character width
#'              before text is automatically wrapped to the next line. The wrapping is intelligent,
#'              breaking at word boundaries. Defaults to `60` which works well for most plots.
#'              Set to `NULL` to disable automatic text wrapping. The actual wrapping is adjusted
#'              based on font size - larger fonts will wrap at proportionally fewer characters.
#'              A 20% safety margin is applied to prevent text cutoff.
#' @param ... Arguments to be passed to function [lavaanPlot::lavaanPlot].
#' @return A lavaanPlot, of classes `c("grViz", "htmlwidget")`, representing the
#'         specified `lavaan` model. Use [save_plot()] to export the plot to PNG,
#'         PDF, SVG, or JPG formats.
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
#'
#' # With robust estimator showing multiple fit statistic types
#' fit_robust <- cfa(HS.model, HolzingerSwineford1939, estimator = "MLR")
#' nice_lavaanPlot(fit_robust,
#'   title = "CFA Model", fit_stats = TRUE,
#'   fit_stats_type = c("regular", "scaled", "robust")
#' )
#'
#' # With custom font sizes (useful for large diagrams)
#' nice_lavaanPlot(fit,
#'   title = "Three-Factor CFA Model",
#'   fit_stats = TRUE,
#'   title_size = 18, fit_stats_size = 12
#' )
#'
#' # With automatic text wrapping for long titles
#' long_title <- "A Very Long Title That Would Otherwise Be Cut Off When Displayed"
#' nice_lavaanPlot(fit, title = long_title, fit_stats = TRUE, wrap_width = 60)
#'
#' # Wrapping adapts to font size - larger fonts wrap at fewer characters
#' nice_lavaanPlot(fit, title = long_title, title_size = 18, wrap_width = 60)
#'
#' # Save plot to file
#' \dontrun{
#' plot <- nice_lavaanPlot(fit)
#' save_plot(plot, "my_plot.png") # PNG format
#' save_plot(plot, "my_plot.pdf") # PDF format (lossless)
#' save_plot(plot, "my_plot.svg") # SVG format (lossless)
#' save_plot(plot, "my_plot.jpg") # JPG format
#' }
#' @section Illustrations:
#'
#' \if{html}{\figure{lavaanPlot.png}{options: width="400"}}

nice_lavaanPlot <- function(
  model,
  node_options = list(shape = "box", fontname = "Helvetica"),
  edge_options = c(color = "black"),
  coefs = TRUE,
  stand = TRUE,
  covs = FALSE,
  stars = c("regress", "latent", "covs"),
  sig = .05,
  graph_options = c(rankdir = "LR"),
  title = NULL,
  note = NULL,
  fit_stats = NULL,
  fit_stats_type = c("regular", "scaled", "robust"),
  title_size = 14,
  note_size = 10,
  fit_stats_size = 9,
  wrap_width = 60,
  ...
) {
  insight::check_if_installed(
    c(
      "lavaanPlot",
      "DiagrammeRsvg",
      "rsvg",
      "png",
      "webshot"
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

  # Text wrapping function that accounts for font size
  wrap_text <- function(text, max_width, font_size, base_font_size = 10) {
    if (is.null(max_width) || is.null(text) || nchar(text) == 0) {
      return(text)
    }

    # Adjust wrap width based on font size ratio
    # Larger fonts need proportionally fewer characters per line
    adjusted_width <- max_width * (base_font_size / font_size)

    # Add padding/safety margin (reduce by 20%) to prevent text cutoff
    # This accounts for variable character widths and rendering differences
    adjusted_width <- adjusted_width * 0.8
    adjusted_width <- max(20, round(adjusted_width)) # Minimum of 20 chars

    # Use insight::format_message for intelligent wrapping
    wrapped <- insight::format_message(text, line_length = adjusted_width)

    # Convert newlines to HTML breaks, trimming leading spaces from wrapped lines
    lines <- strsplit(wrapped, "\n", fixed = TRUE)[[1]]
    lines <- trimws(lines, which = "left")

    # Join with HTML break tags
    paste(lines, collapse = "<BR/>")
  }

  # Extract and format fit statistics if requested
  fit_stats_text <- NULL
  if (!is.null(fit_stats)) {
    # Get all fit measures directly from lavaan
    all_fit_measures <- lavaan::fitMeasures(model)

    # Determine which indices to display
    if (isTRUE(fit_stats)) {
      # Default set of fit indices
      indices_to_show <- c("cfi", "tli", "rmsea", "srmr")
    } else if (is.character(fit_stats)) {
      # User-specified indices
      indices_to_show <- tolower(fit_stats)
    } else {
      stop(
        "fit_stats must be TRUE, FALSE, NULL, or a character vector of fit index names"
      )
    }

    # Check for unrecognized fit indices
    # Remove suffixes to get base fit measure names
    base_fit_names <- unique(sub(
      "\\.(scaled|robust)$",
      "",
      names(all_fit_measures)
    ))
    unknown_indices <- setdiff(indices_to_show, base_fit_names)
    if (length(unknown_indices) > 0) {
      warning(
        "Unrecognized fit indices: ",
        paste(unknown_indices, collapse = ", ")
      )
    }

    # Helper function to format a single fit value
    format_fit_value <- function(idx, val) {
      if (is.numeric(val) && !is.na(val)) {
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
    }

    # Determine which types to show (regular, scaled, robust)
    fit_stats_type <- match.arg(
      fit_stats_type,
      choices = c("regular", "scaled", "robust"),
      several.ok = TRUE
    )

    # Build lines of fit statistics for each type
    fit_lines <- character(0)

    for (type in fit_stats_type) {
      # Determine suffix for this type
      suffix <- if (type == "regular") "" else paste0(".", type)

      # Get values for this type
      type_values <- character(0)
      type_has_values <- FALSE

      for (idx in indices_to_show) {
        # Try to get the fit measure with the appropriate suffix
        fit_name <- paste0(idx, suffix)

        if (fit_name %in% names(all_fit_measures)) {
          val <- all_fit_measures[[fit_name]]
          if (!is.na(val)) {
            formatted_val <- format_fit_value(idx, val)
            type_values <- c(
              type_values,
              paste0(toupper(idx), " = ", formatted_val)
            )
            type_has_values <- TRUE
          }
        }
      }

      # Only add this line if we found values for this type
      if (type_has_values && length(type_values) > 0) {
        # Add type label if we're showing multiple types
        if (length(fit_stats_type) > 1) {
          type_label <- paste0(
            toupper(substring(type, 1, 1)),
            substring(type, 2),
            ": "
          )
        } else {
          type_label <- ""
        }
        fit_lines <- c(
          fit_lines,
          paste0(type_label, paste(type_values, collapse = ", "))
        )
      }
    }

    # Combine all lines with line breaks
    if (length(fit_lines) > 0) {
      fit_stats_text <- paste(fit_lines, collapse = "\n")
    }
  }

  # Construct HTML label if title or note is provided
  # Convert graph_options to list if it's a vector
  if (!is.list(graph_options)) {
    graph_options <- as.list(graph_options)
  }

  # Warn if title/note/fit_stats will override existing label or labelloc
  if (!is.null(title) || !is.null(note) || !is.null(fit_stats)) {
    if (!is.null(graph_options$label) || !is.null(graph_options$labelloc)) {
      warning(
        "title/note/fit_stats parameters override graph_options$label and graph_options$labelloc"
      )
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
      # Escape first, then apply wrapping (so <BR/> tags aren't escaped)
      title_escaped <- html_escape(title)
      title_text <- wrap_text(title_escaped, wrap_width, title_size)
      html_rows <- c(
        html_rows,
        paste0(
          "<TR><TD ALIGN=\"CENTER\"><FONT POINT-SIZE=\"",
          title_size,
          "\"><B>",
          title_text,
          "</B></FONT></TD></TR>"
        )
      )
      if (has_note || has_fit_stats) {
        html_rows <- c(html_rows, "<TR><TD HEIGHT=\"10\"></TD></TR>") # Spacer
      }
    }

    if (has_note) {
      # Escape first, then apply wrapping (so <BR/> tags aren't escaped)
      note_escaped <- html_escape(note)
      note_text <- wrap_text(note_escaped, wrap_width, note_size)
      html_rows <- c(
        html_rows,
        paste0(
          "<TR><TD ALIGN=\"CENTER\"><FONT POINT-SIZE=\"",
          note_size,
          "\">",
          note_text,
          "</FONT></TD></TR>"
        )
      )
      if (has_fit_stats) {
        html_rows <- c(html_rows, "<TR><TD HEIGHT=\"10\"></TD></TR>") # Spacer
      }
    }

    if (has_fit_stats) {
      # Split fit_stats_text by newline to handle multiple types
      fit_stats_lines <- strsplit(fit_stats_text, "\n", fixed = TRUE)[[1]]

      # Add each line as a separate row, with wrapping if requested
      for (i in seq_along(fit_stats_lines)) {
        # Escape first, then apply wrapping (so <BR/> tags aren't escaped)
        escaped_line <- html_escape(fit_stats_lines[i])
        wrapped_line <- wrap_text(
          escaped_line,
          wrap_width,
          fit_stats_size
        )
        html_rows <- c(
          html_rows,
          paste0(
            "<TR><TD ALIGN=\"CENTER\"><FONT POINT-SIZE=\"",
            fit_stats_size,
            "\">",
            wrapped_line,
            "</FONT></TD></TR>"
          )
        )
      }
    }

    # Combine into full HTML table
    graph_options$label <- paste0(
      "<<TABLE BORDER=\"0\" CELLBORDER=\"0\" CELLSPACING=\"0\">",
      paste(html_rows, collapse = ""),
      "</TABLE>>"
    )

    # Position label at top if title is present, otherwise at bottom
    graph_options$labelloc <- if (has_title) "t" else "b"
    # Center the label horizontally
    graph_options$labeljust <- "c"
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
