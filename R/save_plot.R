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
#' @param width The width of the output image in pixels. If `NULL` (default), uses the
#'              SVG's natural dimensions which automatically crops to content including
#'              title, note, and fit statistics.
#' @param height The height of the output image in pixels. If `NULL` (default), uses the
#'               SVG's natural dimensions which automatically crops to content.
#' @param dpi Dots per inch for raster formats (PNG/JPG). Only used for ggplot objects
#'            from `nice_tidySEM()`. Defaults to 300.
#' @param ... Additional arguments passed to the underlying save functions
#'            (`ggplot2::ggsave()` for ggplot objects or `rsvg::rsvg_*()` functions
#'            for grViz objects).
#'
#' @details For plots from `nice_lavaanPlot()` (grViz/htmlwidget objects):
#' - The plot is first converted to SVG using `DiagrammeRsvg::export_svg()`
#' - By default (no width/height specified), all formats use the SVG's natural dimensions,
#'   which automatically crops to the actual content including title, note, and fit statistics
#' - All dimension parameters are in **pixels** (not inches) for consistency across formats
#' - For PNG: SVG is rendered directly to PNG using `rsvg::rsvg_png()`
#' - For JPG: SVG is rendered to raster array using `rsvg::rsvg()` and saved with `grDevices::jpeg()`
#' - For PDF: SVG is rendered to PDF using `rsvg::rsvg_pdf()` (also uses pixels)
#' - For SVG: The SVG string is saved directly to file
#'
#' For plots from `nice_tidySEM()` (ggplot objects):
#' - The plot is saved using `ggplot2::ggsave()` with the specified format
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
#' # Custom dimensions
#' save_plot(plot, "myplot_large.png", width = 2400, height = 1800)
#' }
save_plot <- function(plot, filename, width = NULL, height = NULL, dpi = 300, ...) {
  # Determine file format from extension
  ext <- tolower(tools::file_ext(filename))

  if (!ext %in% c("png", "pdf", "svg", "jpg", "jpeg")) {
    stop("Unsupported file format. Use .png, .pdf, .svg, .jpg, or .jpeg")
  }

  # Detect plot type
  is_ggplot <- inherits(plot, "ggplot")
  is_grViz <- inherits(plot, c("grViz", "htmlwidget"))

  if (!is_ggplot && !is_grViz) {
    stop("plot must be either a ggplot object (from nice_tidySEM) or a grViz object (from nice_lavaanPlot)")
  }

  # Handle ggplot objects (from nice_tidySEM)
  if (is_ggplot) {
    insight::check_if_installed("ggplot2", reason = "to save ggplot objects.")

    # Set default dimensions for ggplot (in inches)
    if (is.null(width)) width <- 7
    if (is.null(height)) height <- 5

    # Use ggsave for all formats
    ggplot2::ggsave(
      filename = filename,
      plot = plot,
      width = width,
      height = height,
      dpi = dpi,
      ...
    )

    message("Plot saved to: ", filename)
    return(invisible(filename))
  }

  # Handle grViz objects (from nice_lavaanPlot)
  if (is_grViz) {
    insight::check_if_installed(
      c("DiagrammeRsvg", "rsvg"),
      reason = "to save grViz/lavaanPlot objects."
    )

    # Convert to SVG first
    svg_string <- DiagrammeRsvg::export_svg(plot)

    if (ext == "svg") {
      # Save SVG directly
      writeLines(svg_string, filename)
      message("Plot saved to: ", filename)
      return(invisible(filename))
    }

    # For other formats, we need to render the SVG
    # If dimensions are not specified, rsvg will use the SVG's natural dimensions
    # which automatically crops to content (including title, note, fit stats, etc.)
    
    if (ext == "pdf") {
      # Render to PDF (dimensions in pixels, same as PNG/JPG)
      # If no dimensions specified, uses SVG's natural size for perfect cropping
      if (is.null(width) && is.null(height)) {
        rsvg::rsvg_pdf(
          charToRaw(svg_string),
          file = filename,
          ...
        )
      } else {
        # Use specified dimensions (in pixels)
        rsvg::rsvg_pdf(
          charToRaw(svg_string),
          file = filename,
          width = if (is.null(width)) 1200 else width,
          height = if (is.null(height)) 900 else height,
          ...
        )
      }
    } else if (ext == "png") {
      # Render to PNG (dimensions in pixels)
      # If no dimensions specified, uses SVG's natural size for perfect cropping
      if (is.null(width) && is.null(height)) {
        rsvg::rsvg_png(
          charToRaw(svg_string),
          file = filename,
          ...
        )
      } else {
        # Use specified dimensions
        rsvg::rsvg_png(
          charToRaw(svg_string),
          file = filename,
          width = if (is.null(width)) 1200 else width,
          height = if (is.null(height)) 900 else height,
          ...
        )
      }
    } else if (ext %in% c("jpg", "jpeg")) {
      # Render to JPEG (dimensions in pixels)
      # rsvg doesn't have direct JPEG support, so we render to array and save as JPEG
      insight::check_if_installed("png", reason = "to save JPEG images.")

      # Render SVG to bitmap array
      # If no dimensions specified, uses SVG's natural size for perfect cropping
      if (is.null(width) && is.null(height)) {
        img_data <- rsvg::rsvg(
          charToRaw(svg_string),
          ...
        )
      } else {
        img_data <- rsvg::rsvg(
          charToRaw(svg_string),
          width = if (is.null(width)) 1200 else width,
          height = if (is.null(height)) 900 else height,
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

    message("Plot saved to: ", filename)
    return(invisible(filename))
  }
}
