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
#' @param engine Rendering engine for grViz objects. One of "rsvg" (default) or "webshot".
#'               "rsvg" uses the rsvg library to render SVG to PNG/JPG/PDF, but may have
#'               font rendering differences compared to browser display due to font substitution.
#'               "webshot" uses a headless browser (PhantomJS) to capture pixel-perfect
#'               screenshots that match exactly what you see in the RStudio viewer.
#'               Use "webshot" when precise font rendering is critical.
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
#' When `engine = "webshot"`:
#' - Uses a headless browser (PhantomJS via webshot package) to render the SVG
#' - Produces pixel-perfect output that matches exactly what you see in the RStudio viewer
#' - Avoids font substitution issues that can cause text misalignment with rsvg
#' - Requires the webshot package and PhantomJS (`webshot::install_phantomjs()`)
#' - Only supports PNG and JPG formats; for PDF, falls back to rsvg
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
  engine = c("webshot", "rsvg"),
  verbose = TRUE,
  ...
) {
  # Match units argument
  units <- match.arg(units)
  engine <- match.arg(engine)
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

    # Use webshot engine for pixel-perfect browser rendering (PNG/JPG only)
    if (engine == "webshot" && ext %in% c("png", "jpg", "jpeg")) {
      return(save_with_webshot(
        plot,
        filename,
        width_px,
        height_px,
        dpi,
        verbose
      ))
    }

    # Use rsvg engine (default)
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

# Helper: save grViz plot using webshot (browser-based pixel-perfect rendering)
save_with_webshot <- function(
  plot,
  filename,
  width_px = NULL,
  height_px = NULL,
  dpi = 300,
  verbose = TRUE
) {
  insight::check_if_installed(
    c("webshot", "htmlwidgets"),
    reason = "to save plots using webshot engine (browser-based rendering)."
  )

  # Create a temporary HTML file to render the widget
  temp_html <- tempfile(fileext = ".html")
  temp_png <- tempfile(fileext = ".png")

  on.exit(
    {
      unlink(temp_html, force = TRUE)
      unlink(temp_png, force = TRUE)
    },
    add = TRUE
  )

  # Save the htmlwidget to HTML
  htmlwidgets::saveWidget(
    widget = plot,
    file = temp_html,
    selfcontained = TRUE
  )

  # Calculate viewport size for webshot
  # Default viewport: 992x744 is a reasonable size that accommodates most plots
  # without excessive whitespace (roughly 10.3"x7.75" at 96 DPI, 4:3 aspect ratio)
  vwidth <- if (!is.null(width_px)) as.integer(width_px) else 992L
  vheight <- if (!is.null(height_px)) as.integer(height_px) else 744L

  # Determine output format
  ext <- tolower(tools::file_ext(filename))

  # Standard screen DPI for zoom calculation
  screen_dpi <- 96

  # Use webshot to capture the rendered HTML
  # selector ".grViz" targets the specific DiagrammeR grViz container
  webshot::webshot(
    url = temp_html,
    file = temp_png,
    vwidth = vwidth,
    vheight = vheight,
    selector = ".grViz",
    expand = c(10, 10, 10, 10), # 10px padding on each side for cleaner edges
    zoom = dpi / screen_dpi # Scale for higher DPI output (e.g., 300/96 ≈ 3.125x)
  )

  # JPEG quality setting (0-100, higher = better quality but larger file)
  jpeg_quality <- 95

  # Convert to JPG if needed
  if (ext %in% c("jpg", "jpeg")) {
    insight::check_if_installed("png", reason = "to convert PNG to JPEG.")

    # Read PNG and save as JPEG
    img <- png::readPNG(temp_png)
    img_height <- dim(img)[1]
    img_width <- dim(img)[2]

    grDevices::jpeg(
      filename = filename,
      width = img_width,
      height = img_height,
      units = "px",
      quality = jpeg_quality
    )

    grid::grid.newpage()
    grid::grid.raster(
      img,
      x = 0.5,
      y = 0.5,
      width = 1,
      height = 1,
      interpolate = TRUE
    )

    grDevices::dev.off()
  } else {
    # For PNG, just copy the temp file
    file.copy(temp_png, filename, overwrite = TRUE)
  }

  if (verbose) {
    message("Plot saved to: ", filename, " (using webshot engine)")
  }

  invisible(filename)
}
