#' @title `flextable::save_as_x`
#'
#' @description These `save_as_x` functions are imported from `flextable`.
#'
#' @param ... arguments passed to `save_as_x` functions
#' @name save_as_x
NULL

#' @return A table, either as an image, Word, PowerPoint, or HTML document.
#' @rdname save_as_x
#' @export
save_as_docx <- function(...) {
  if (isTRUE(requireNamespace("flextable", quietly = TRUE))) {
    flextable::save_as_docx(...)
  }
}

#' @rdname save_as_x
#' @export
save_as_html <- function(...) {
  if (isTRUE(requireNamespace("flextable", quietly = TRUE))) {
    flextable::save_as_html(...)
  }
}

#' @rdname save_as_x
#' @export
save_as_image <- function(...) {
  if (isTRUE(requireNamespace("flextable", quietly = TRUE))) {
    flextable::save_as_image(...)
  }
}

#' @rdname save_as_x
#' @export
save_as_pptx <- function(...) {
  if (isTRUE(requireNamespace("flextable", quietly = TRUE))) {
    flextable::save_as_pptx(...)
  }
}
