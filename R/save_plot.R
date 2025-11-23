#' @title Save a lavaanExtra plot to file
#'
#' @description Save plots from `nice_lavaanPlot()` or `nice_tidySEM()` to various
#'              file formats including PNG, PDF, SVG, and JPG. Automatically detects
#'              the plot type and applies the appropriate saving method.
#'
#' @param plot A plot object from `nice_lavaanPlot()` (class `c("grViz", "htmlwidget")`)
#'             or `nice_tidySEM()` (class `ggplot`).
#' @param filename The path where the file should be saved, including the file extension
#'                 (e.g., "myplot.png", "myplot.pdf", "myplot.svg", "myplot.jpg").
#'                 The file format is determined by the extension.
#' @param width The width of the output image. Units are specified by the `units` parameter.
#'              If `NULL` (default for grViz objects), uses the SVG's natural dimensions
#'              which automatically crops to content. For ggplot objects, defaults to 7 (inches).
#' @param height The height of the output image. Units are specified by the `units` parameter.
#'               If `NULL` (default for grViz objects), uses the SVG's natural dimensions.
#'               For ggplot objects, defaults to 5 (inches).
#' @param units Units for width and height. One of "in" (inches, default), "cm" (centimeters),
#'              "mm" (millimeters), or "px" (pixels). For ggplot objects, this is passed
#'              directly to `ggplot2::ggsave()`. For grViz objects, units are converted to
#'              pixels using the `dpi` parameter.
#' @param dpi Dots per inch for converting units to pixels and for raster formats (PNG/JPG).
#'            Defaults to 300. Used for unit conversion for grViz objects and passed to
#'            `ggplot2::ggsave()` for ggplot objects.
#' @param verbose Logical. If `TRUE` (default), prints a message indicating where the file
#'                was saved. Set to `FALSE` to suppress messages.
#' @param ... Additional arguments passed to the underlying save functions
#'            (`ggplot2::ggsave()` for ggplot objects or `rsvg::rsvg_*()` functions
#'            for grViz objects).
#'
#' @details For plots from `nice_lavaanPlot()` (grViz/htmlwidget objects):
#' - The plot is first converted to SVG using `DiagrammeRsvg::export_svg()`
#' - Automatically adds 5% padding and a white background to prevent text cutoff and ensure
#'   proper display across all formats (especially for titles and fit statistics)
#' - By default (no width/height specified), all formats use the SVG's natural dimensions,
#'   which automatically crops to the actual content including title, note, and fit statistics
#' - Dimension units are specified by the `units` parameter and converted to pixels internally
#' - For PNG: SVG is rendered directly to PNG using `rsvg::rsvg_png()`
#' - For JPG: SVG is rendered to raster array using `rsvg::rsvg()` and saved with `grDevices::jpeg()`
#' - For PDF: SVG is rendered to PDF using `rsvg::rsvg_pdf()`
#' - For SVG: The SVG string is saved directly to file
#'
#' For plots from `nice_tidySEM()` (ggplot objects):
#' - The plot is saved using `ggplot2::ggsave()` with the specified format and units
#'
#' @return Invisibly returns the path to the saved file.
#' @export
#' @examplesIf requireNamespace("lavaan", quietly = TRUE) && requireNamespace("lavaanPlot", quietly = TRUE) && requireNamespace("DiagrammeRsvg", quietly = TRUE)
#' \donttest{
#' # Create a simple CFA model
#' library(lavaan)
#' x <- paste0("x", 1:9)
#' latent <- list(
#'   visual = x[1:3],
#'   textual = x[4:6],
#'   speed = x[7:9]
#' )
#'
#' HS.model <- write_lavaan(latent = latent)
#' fit <- cfa(HS.model, HolzingerSwineford1939)
#'
#' # Create and save plot in different formats
#' plot <- nice_lavaanPlot(fit)
#'
#' # Save as PNG (default)
#' save_plot(plot, "myplot.png")
#'
#' # Save as PDF (lossless)
#' save_plot(plot, "myplot.pdf")
#'
#' # Save as SVG (lossless)
#' save_plot(plot, "myplot.svg")
#'
#' # Save as JPG
#' save_plot(plot, "myplot.jpg")
#'
#' # Custom dimensions with different units
#' save_plot(plot, "myplot_large.png", width = 10, height = 7.5, units = "in")
#' save_plot(plot, "myplot_cm.pdf", width = 20, height = 15, units = "cm")
#' save_plot(plot, "myplot_px.jpg", width = 2400, height = 1800, units = "px")
#' }
save_plot <- function(
  plot,
  filename,
  width = NULL,
  height = NULL,
  units = c("in", "cm", "mm", "px"),
  dpi = 300,
  verbose = TRUE,
  ...
) {
  # Match units argument
  units <- match.arg(units)
  # Determine file format from extension
  ext <- tolower(tools::file_ext(filename))

  if (!ext %in% c("png", "pdf", "svg", "jpg", "jpeg")) {
    stop("Unsupported file format. Use .png, .pdf, .svg, .jpg, or .jpeg")
  }

  # Detect plot type
  is_ggplot <- inherits(plot, "ggplot")
  is_grViz <- inherits(plot, c("grViz", "htmlwidget"))

  if (!is_ggplot && !is_grViz) {
    stop(
      "plot must be either a ggplot object (from nice_tidySEM) or a grViz object (from nice_lavaanPlot)"
    )
  }

  # Handle ggplot objects (from nice_tidySEM)
  if (is_ggplot) {
    insight::check_if_installed("ggplot2", reason = "to save ggplot objects.")

    # Use ggsave for all formats - pass units directly to ggsave
    ggplot2::ggsave(
      filename = filename,
      plot = plot,
      width = width,
      height = height,
      units = units,
      dpi = dpi,
      ...
    )

    if (verbose) {
      message("Plot saved to: ", filename)
    }
    return(invisible(filename))
  }

  # Handle grViz objects (from nice_lavaanPlot)
  if (is_grViz) {
    insight::check_if_installed(
      c("DiagrammeRsvg", "rsvg"),
      reason = "to save grViz/lavaanPlot objects."
    )

    # Convert dimensions to pixels for grViz objects
    width_px <- convert_to_pixels(width, units, dpi)
    height_px <- convert_to_pixels(height, units, dpi)

    # Convert to SVG first
    svg_string <- DiagrammeRsvg::export_svg(plot)

    # Add horizontal padding to prevent text cutoff
    # This is especially important when title, note, or fit_stats are present
    svg_string <- add_svg_padding(svg_string, padding_pct = 0.05)

    if (ext == "svg") {
      # Save SVG directly
      writeLines(svg_string, filename)
      if (verbose) {
        message("Plot saved to: ", filename)
      }
      return(invisible(filename))
    }

    # For other formats, we need to render the SVG
    # If dimensions are not specified, rsvg will use the SVG's natural dimensions
    # which automatically crops to content (including title, note, fit stats, etc.)

    if (ext == "pdf") {
      # Render to PDF (dimensions in pixels)
      # If no dimensions specified, uses SVG's natural size for perfect cropping
      if (is.null(width_px) && is.null(height_px)) {
        rsvg::rsvg_pdf(
          charToRaw(svg_string),
          file = filename,
          ...
        )
      } else {
        # Use specified dimensions (converted to pixels)
        rsvg::rsvg_pdf(
          charToRaw(svg_string),
          file = filename,
          width = width_px,
          height = height_px,
          ...
        )
      }
    } else if (ext == "png") {
      # Render to PNG (dimensions in pixels)
      # If no dimensions specified, uses SVG's natural size for perfect cropping
      if (is.null(width_px) && is.null(height_px)) {
        rsvg::rsvg_png(
          charToRaw(svg_string),
          file = filename,
          ...
        )
      } else {
        # Use specified dimensions (converted to pixels)
        rsvg::rsvg_png(
          charToRaw(svg_string),
          file = filename,
          width = width_px,
          height = height_px,
          ...
        )
      }
    } else if (ext %in% c("jpg", "jpeg")) {
      # Render to JPEG (dimensions in pixels)
      # rsvg doesn't have direct JPEG support, so we render to array and save as JPEG
      insight::check_if_installed("png", reason = "to save JPEG images.")

      # Render SVG to bitmap array
      # If no dimensions specified, uses SVG's natural size for perfect cropping
      if (is.null(width_px) && is.null(height_px)) {
        img_data <- rsvg::rsvg(
          charToRaw(svg_string),
          ...
        )
      } else {
        img_data <- rsvg::rsvg(
          charToRaw(svg_string),
          width = width_px,
          height = height_px,
          ...
        )
      }

      # Get actual dimensions from the rendered image
      img_height <- dim(img_data)[1]
      img_width <- dim(img_data)[2]

      # Create JPEG device with exact dimensions
      grDevices::jpeg(
        filename = filename,
        width = img_width,
        height = img_height,
        units = "px",
        quality = 95
      )

      # Use grid graphics which doesn't add margins
      grid::grid.newpage()
      grid::grid.raster(
        img_data,
        x = 0.5,
        y = 0.5,
        width = 1,
        height = 1,
        interpolate = TRUE
      )

      grDevices::dev.off()
    }

    if (verbose) {
      message("Plot saved to: ", filename)
    }
    return(invisible(filename))
  }
}

# Helper function to convert dimensions to pixels
convert_to_pixels <- function(value, units = "in", dpi = 300) {
  if (is.null(value)) {
    return(NULL)
  }

  switch(
    units,
    "in" = value * dpi,
    "cm" = value * dpi / 2.54,
    "mm" = value * dpi / 25.4,
    "px" = value,
    stop("units must be one of 'in', 'cm', 'mm', or 'px'")
  )
}

# Helper function to add padding to SVG to prevent text cutoff
add_svg_padding <- function(svg_string, padding_pct = 0.05) {
  # Use xml2 to parse and modify the SVG
  insight::check_if_installed("xml2", reason = "to add padding to SVG.")

  # Parse SVG
  svg_doc <- xml2::read_xml(svg_string)

  # Get current dimensions
  width_attr <- xml2::xml_attr(svg_doc, "width")
  height_attr <- xml2::xml_attr(svg_doc, "height")
  viewBox_attr <- xml2::xml_attr(svg_doc, "viewBox")

  # Store original viewBox for background rectangle
  orig_viewBox <- NULL

  # If viewBox exists, adjust it to add padding
  if (!is.na(viewBox_attr)) {
    vb_parts <- as.numeric(strsplit(viewBox_attr, " ")[[1]])
    orig_viewBox <- vb_parts

    # Calculate padding (as percentage of dimensions)
    h_padding <- vb_parts[3] * padding_pct
    v_padding <- vb_parts[4] * padding_pct

    # Adjust viewBox: shift origin and increase dimensions
    new_viewBox <- sprintf(
      "%f %f %f %f",
      vb_parts[1] - h_padding, # shift left
      vb_parts[2] - v_padding, # shift up
      vb_parts[3] + 2 * h_padding, # increase width
      vb_parts[4] + 2 * v_padding
    ) # increase height

    xml2::xml_attr(svg_doc, "viewBox") <- new_viewBox
  }

  # If width/height attributes exist, increase them proportionally
  if (!is.na(width_attr) && !is.na(height_attr)) {
    # Extract numeric values (handles both "300" and "300pt" formats)
    orig_width <- as.numeric(gsub("[^0-9.]", "", width_attr))
    orig_height <- as.numeric(gsub("[^0-9.]", "", height_attr))

    # Get unit suffix if present
    width_unit <- gsub("[0-9.]", "", width_attr)
    height_unit <- gsub("[0-9.]", "", height_attr)

    # Calculate new dimensions
    new_width <- orig_width * (1 + 2 * padding_pct)
    new_height <- orig_height * (1 + 2 * padding_pct)

    # Apply new dimensions with original units
    xml2::xml_attr(svg_doc, "width") <- paste0(new_width, width_unit)
    xml2::xml_attr(svg_doc, "height") <- paste0(new_height, height_unit)
  }

  # Add a white background rectangle as the first child element
  # This ensures the background is white instead of transparent
  if (!is.null(orig_viewBox)) {
    # Create background rectangle that covers the entire new viewBox
    h_padding <- orig_viewBox[3] * padding_pct
    v_padding <- orig_viewBox[4] * padding_pct

    bg_rect <- xml2::read_xml("<rect/>")
    xml2::xml_attr(bg_rect, "x") <- as.character(orig_viewBox[1] - h_padding)
    xml2::xml_attr(bg_rect, "y") <- as.character(orig_viewBox[2] - v_padding)
    xml2::xml_attr(bg_rect, "width") <- as.character(
      orig_viewBox[3] + 2 * h_padding
    )
    xml2::xml_attr(bg_rect, "height") <- as.character(
      orig_viewBox[4] + 2 * v_padding
    )
    xml2::xml_attr(bg_rect, "fill") <- "white"

    # Insert as first child of the SVG root
    first_child <- xml2::xml_child(svg_doc, 1)
    xml2::xml_add_sibling(first_child, bg_rect, .where = "before")
  }

  # Return modified SVG as string
  as.character(svg_doc)
}
