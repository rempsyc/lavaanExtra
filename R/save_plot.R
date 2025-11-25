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
#' @param use_webshot Logical. If `TRUE` (default), uses browser-based rendering via
#'               webshot2 package (headless Chrome) for pixel-perfect screenshots that match
#'               exactly what you see in the RStudio viewer. This avoids font substitution
#'               issues that can cause text misalignment with librsvg.
#'               If `FALSE`, uses rsvg library to render SVG to PNG/JPG/PDF, which may have
#'               font rendering differences compared to browser display.
#' @param verbose Logical. If `TRUE` (default), prints a message indicating where the file
#'                was saved. Set to `FALSE` to suppress messages.
#' @param ... Additional arguments passed to the underlying save functions
#'            (`ggplot2::ggsave()` for ggplot objects or `rsvg::rsvg_*()` functions
#'            for grViz objects).
#'
#' @details For plots from `nice_lavaanPlot()` (grViz/htmlwidget objects):
#' - The plot is first converted to SVG using `DiagrammeRsvg::export_svg()`
#' - Graphviz centering attributes (ALIGN, BALIGN, labeljust, center) ensure proper centering
#' - By default (no width/height specified), PNG/JPG/PDF use the SVG's intrinsic viewBox dimensions
#'   to ensure pixel-perfect centering that matches the SVG output. This prevents rsvg from
#'   guessing dimensions inconsistently across formats.
#' - Dimension units are specified by the `units` parameter and converted to pixels internally
#' - For PNG: SVG is rendered directly to PNG using `rsvg::rsvg_png()`
#' - For JPG: SVG is rendered to raster array using `rsvg::rsvg()` and saved with `grDevices::jpeg()`
#' - For PDF: SVG is rendered to PDF using `rsvg::rsvg_pdf()`
#' - For SVG: The SVG string is saved directly to file
#'
#' When `use_webshot = TRUE` (default):
#' - Uses a headless browser (Chrome via webshot2/chromote) to render the SVG
#' - Produces pixel-perfect output that matches exactly what you see in the RStudio viewer
#' - Avoids font substitution issues that can cause text misalignment with rsvg
#' - Requires the webshot2 package (`install.packages("webshot2")`)
#' - Supports PNG, JPG, and PDF formats
#'
#' When `use_webshot = FALSE`:
#' - Uses rsvg library for SVG rendering (faster but may have font differences)
#' - May experience font substitution (e.g., Helvetica → DejaVu Sans) causing text misalignment
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
  use_webshot = TRUE,
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
      width = ifelse(is.null(width), NA, width),
      height = ifelse(is.null(height), NA, height),
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
    # Convert dimensions to pixels for grViz objects
    width_px <- convert_to_pixels(width, units, dpi)
    height_px <- convert_to_pixels(height, units, dpi)

    # Use webshot2 engine for pixel-perfect browser rendering (default)
    # Returns NULL for SVG format which doesn't need webshot2
    if (isTRUE(use_webshot)) {
      result <- save_with_webshot2(
        plot,
        filename,
        width_px,
        height_px,
        dpi,
        verbose
      )
      # If webshot2 handled the file, we're done
      if (!is.null(result)) {
        return(result)
      }
      # Otherwise fall through to rsvg handling (for SVG format)
    }

    # Use rsvg engine (fallback or when use_webshot = FALSE)
    insight::check_if_installed(
      c("DiagrammeRsvg", "rsvg"),
      reason = "to save grViz/lavaanPlot objects."
    )

    # Convert to SVG first
    svg_string <- DiagrammeRsvg::export_svg(plot)

    # Add horizontal padding to provide margin around the plot content
    svg_string <- add_svg_padding(svg_string, padding_pct = 0.10)

    if (ext == "svg") {
      # Save SVG directly
      writeLines(svg_string, filename)
      if (verbose) {
        message("Plot saved to: ", filename)
      }
      return(invisible(filename))
    }

    # For other formats, we need to render the SVG
    # Extract intrinsic dimensions from SVG viewBox to ensure consistent rasterization
    # This prevents rsvg from guessing dimensions inconsistently for PNG/JPG
    if (is.null(width_px) || is.null(height_px)) {
      insight::check_if_installed("xml2", reason = "to extract SVG dimensions.")
      doc <- xml2::read_xml(svg_string)
      vb <- xml2::xml_attr(doc, "viewBox")

      if (!is.na(vb)) {
        # viewBox format: "minx miny width height"
        vb_nums <- as.numeric(strsplit(vb, " +")[[1]])
        svg_w <- vb_nums[3]
        svg_h <- vb_nums[4]

        # Use SVG intrinsic dimensions if not manually specified
        if (is.null(width_px)) {
          width_px <- svg_w
        }
        if (is.null(height_px)) height_px <- svg_h
      }
    }

    if (ext == "pdf") {
      # Render to PDF (dimensions in pixels)
      rsvg::rsvg_pdf(
        charToRaw(svg_string),
        file = filename,
        width = width_px,
        height = height_px,
        ...
      )
    } else if (ext == "png") {
      # Render to PNG (dimensions in pixels)
      rsvg::rsvg_png(
        charToRaw(svg_string),
        file = filename,
        width = width_px,
        height = height_px,
        ...
      )
    } else if (ext %in% c("jpg", "jpeg")) {
      # Render to JPEG (dimensions in pixels)
      # rsvg doesn't have direct JPEG support, so we render to array and save as JPEG
      insight::check_if_installed("png", reason = "to save JPEG images.")
      # Render SVG to bitmap array
      img_data <- rsvg::rsvg(
        charToRaw(svg_string),
        width = width_px,
        height = height_px,
        ...
      )
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

# Helper: add horizontal padding to an SVG by expanding its viewBox width only
add_svg_padding <- function(
  svg_string,
  padding_pct = 0.10,
  add_background = TRUE
) {
  insight::check_if_installed("xml2", reason = "to add padding to SVG.")
  doc <- xml2::read_xml(svg_string)

  vb_attr <- xml2::xml_attr(doc, "viewBox")
  if (is.na(vb_attr)) {
    return(svg_string)
  }

  # viewBox = "min_x min_y width height"
  vb <- as.numeric(strsplit(vb_attr, "[ ,]+")[[1]])
  if (length(vb) != 4L || any(is.na(vb))) {
    return(svg_string)
  }

  x <- vb[1]
  y <- vb[2]
  w <- vb[3]
  h <- vb[4]

  # Horizontal padding only
  hp <- w * padding_pct
  new_x <- x - hp
  new_w <- w + 2 * hp
  new_vb <- sprintf("%f %f %f %f", new_x, y, new_w, h)

  # Update viewBox (same height, wider width)
  xml2::xml_attr(doc, "viewBox") <- new_vb

  if (add_background) {
    # White background covering the new horizontal extent, same height
    bg <- xml2::read_xml("<rect/>")
    xml2::xml_attr(bg, "x") <- as.character(new_x)
    xml2::xml_attr(bg, "y") <- as.character(y)
    xml2::xml_attr(bg, "width") <- as.character(new_w)
    xml2::xml_attr(bg, "height") <- as.character(h)
    xml2::xml_attr(bg, "fill") <- "white"

    first_child <- xml2::xml_child(doc, 1)
    if (is.null(first_child)) {
      xml2::xml_add_child(doc, bg)
    } else {
      xml2::xml_add_sibling(first_child, bg, .where = "before")
    }
  }

  as.character(doc)
}

# Helper: save grViz plot using webshot2 (browser-based pixel-perfect rendering)
save_with_webshot2 <- function(
  plot,
  filename,
  width_px = NULL,
  height_px = NULL,
  dpi = 300,
  verbose = TRUE
) {
  ext <- tolower(tools::file_ext(filename))

  # SVG doesn't need webshot2 - return NULL to let main function handle it via rsvg
  if (ext == "svg") {
    return(NULL)
  }

  insight::check_if_installed(
    c("webshot2", "htmlwidgets", "DiagrammeRsvg", "xml2"),
    reason = "to export grViz plots using browser-based rendering."
  )

  # --- Extract SVG dimensions from Graphviz (uses viz.js, no librsvg font issues) ---
  svg_str <- DiagrammeRsvg::export_svg(plot)
  doc <- xml2::read_xml(svg_str)

  # Get dimensions from viewBox or width/height attributes
  vb <- xml2::xml_attr(doc, "viewBox")
  if (!is.na(vb)) {
    nums <- as.numeric(strsplit(vb, "\\s+")[[1]])
    svg_w <- nums[3]
    svg_h <- nums[4]
  } else {
    w_attr <- xml2::xml_attr(doc, "width")
    h_attr <- xml2::xml_attr(doc, "height")
    svg_w <- as.numeric(gsub("[^0-9.]", "", w_attr))
    svg_h <- as.numeric(gsub("[^0-9.]", "", h_attr))
  }

  # Convert from SVG units to CSS pixels (approximate conversion for viewport)
  # SVG units are roughly 96 DPI, CSS px are 96 DPI, so factor ~1.0–1.2 works
  svg_w_px <- as.integer(svg_w * 1.1)  # Add 10% buffer for safety
  svg_h_px <- as.integer(svg_h * 1.1)

  # Temporary HTML file
  temp_html <- tempfile(fileext = ".html")
  on.exit(unlink(temp_html, force = TRUE), add = TRUE)

  # Save widget as HTML
  htmlwidgets::saveWidget(
    widget = plot,
    file = temp_html,
    selfcontained = TRUE
  )

  # Inject CSS to collapse page margins and force widget to shrink-wrap SVG
  html_content <- readLines(temp_html, warn = FALSE)
  css_inject <- paste0(
    "<style>",
    "html, body { margin: 0 !important; padding: 0 !important; ",
    "width: auto !important; height: auto !important; overflow: hidden !important; }",
    ".html-widget { display: inline-block !important; width: auto !important; height: auto !important; }",
    ".html-widget svg { display: block !important; }",
    "</style>"
  )
  # Insert CSS right after <head> tag
  html_content <- gsub(
    "(<head[^>]*>)",
    paste0("\\1\n", css_inject),
    html_content,
    ignore.case = TRUE
  )
  writeLines(html_content, temp_html)

  # Set viewport dimensions based on SVG size (with buffer)
  # Use user-specified dimensions if provided, otherwise use SVG-derived dimensions
  vwidth <- if (!is.null(width_px)) as.integer(width_px) else svg_w_px
  vheight <- if (!is.null(height_px)) as.integer(height_px) else svg_h_px

  # Use selector to capture only the widget, not the whole page
  widget_selector <- "div.html-widget"

  # ----- PDF EXPORT (vector accurate) -----
  if (ext == "pdf") {
    webshot2::webshot(
      url = temp_html,
      file = filename,
      vwidth = vwidth,
      vheight = vheight,
      selector = widget_selector,
      zoom = dpi / 96
    )
    if (verbose) {
      message("Plot saved to: ", filename, " (via webshot2 PDF)")
    }
    return(invisible(filename))
  }

  # ----- PNG EXPORT -----
  if (ext == "png") {
    webshot2::webshot(
      url = temp_html,
      file = filename,
      vwidth = vwidth,
      vheight = vheight,
      selector = widget_selector,
      zoom = dpi / 96
    )
    if (verbose) {
      message("Plot saved to: ", filename, " (via webshot2 PNG)")
    }
    return(invisible(filename))
  }

  # ----- JPEG EXPORT -----
  if (ext %in% c("jpg", "jpeg")) {
    temp_png <- tempfile(fileext = ".png")
    on.exit(unlink(temp_png, force = TRUE), add = TRUE)

    # First capture PNG with selector
    webshot2::webshot(
      url = temp_html,
      file = temp_png,
      vwidth = vwidth,
      vheight = vheight,
      selector = widget_selector,
      zoom = dpi / 96
    )

    insight::check_if_installed("png", reason = "to convert PNG to JPEG.")
    img <- png::readPNG(temp_png)

    grDevices::jpeg(
      filename = filename,
      width = dim(img)[2],
      height = dim(img)[1],
      units = "px",
      quality = 95
    )
    grid::grid.raster(img)
    grDevices::dev.off()

    if (verbose) {
      message("Plot saved to: ", filename, " (via webshot2 JPEG)")
    }
    return(invisible(filename))
  }

  stop("Unsupported format for webshot2 export: ", ext)
}
