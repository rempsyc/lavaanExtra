#' @title `flextable::save_as_x`
#'
#' @description These `save_as_x` functions are imported from `flextable`.
#'
#' flextable:
#'       `save_as_docx`,
#'       `save_as_html`,
#'       `save_as_image`,
#'       `save_as_pptx`
#'
#' @param ... arguments passed to `save_as_x` functions
#' @name save_as_x
NULL

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
