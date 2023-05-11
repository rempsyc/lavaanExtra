#' @title Make a quick `tidySEM` plot
#'
#' @description Make a quick and decent-looking `tidySEM` plot.
#'
#' @param fit SEM or CFA model fit to plot.
#' @param layout A matrix (or data.frame) that describes the structure; see
#'               \code{\link[tidySEM]{get_layout}}. If a named list is provided,
#'               with names "IV" (independent variables), "M" (mediator), and
#'               "DV" (dependent variables), `nice_tidySEM` attempts to write
#'               the layout matrix automatically.
#' @param hide_nonsig_edges Logical, hides non-significant edges.
#'                          Defaults to FALSE.
#' @param hide_var Logical, hides variances. Defaults to TRUE.
#' @param hide_cov Logical, hides co-variances. Defaults to FALSE.
#' @param hide_mean Logical, hides means/node labels. Defaults to TRUE.
#' @param est_std Logical, whether to use the standardized coefficients.
#'                Defaults to TRUE.
#' @param plot Logical, whether to plot the result (default). If `FALSE`,
#'             returns the `tidy_sem` object, which can be further edited
#'             as needed.
#' @param label Labels to be used on the plot. As elsewhere in
#'              `lavaanExtra`, it is provided as a named list with
#'              format `(colname = "label")`.
#' @param label_location Location of label along the path, as a percentage
#'                      (defaults to middle, 0.5).
#' @param ... Arguments to be passed to \code{\link[tidySEM]{prepare_graph}}.
#' @keywords CFA lavaan plot fit tidySEM table_results
#' @return A tidySEM plot, of class ggplot, representing the specified
#'         `lavaan` model.
#' @export
#' @examplesIf requireNamespace("lavaan", quietly = TRUE) && requireNamespace("tidySEM", quietly = TRUE)
#'
#' # Calculate scale averages
#' library(lavaan)
#' data <- HolzingerSwineford1939
#' data$visual <- rowMeans(data[paste0("x", 1:3)])
#' data$textual <- rowMeans(data[paste0("x", 4:6)])
#' data$speed <- rowMeans(data[paste0("x", 7:9)])
#'
#' # Define our variables
#' IV <- c("sex", "ageyr", "agemo", "school")
#' M <- c("visual", "grade")
#' DV <- c("speed", "textual")
#'
#' # Define our lavaan lists
#' mediation <- list(speed = M, textual = M, visual = IV, grade = IV)
#'
#' # Define indirect object
#' structure <- list(IV = IV, M = M, DV = DV)
#'
#' # Write the model, and check it
#' model <- write_lavaan(mediation, indirect = structure, label = TRUE)
#' cat(model)
#'
#' # Fit model
#' fit <- sem(model, data)
#'
#' # Plot model
#' \donttest{
#' nice_tidySEM(fit, layout = structure)
#' }
#' @section Illustrations:
#'
#' \if{html}{\figure{nice_tidySEM.png}{options: width="400"}}

nice_tidySEM <- function(fit,
                         layout = NULL,
                         hide_nonsig_edges = FALSE,
                         hide_var = TRUE,
                         hide_cov = FALSE,
                         hide_mean = TRUE,
                         est_std = TRUE,
                         label,
                         label_location = NULL,
                         plot = TRUE,
                         ...) {
  rlang::check_installed(c("tidySEM", "tmvnsim"), reason = "for this function.")

  # We are forced to reimport some tidySEM functions manually here...
  get_edges <- tidySEM::get_edges
  table_results <- tidySEM::table_results
  conf_int <- tidySEM::conf_int
  est_sig <- tidySEM::est_sig
  get_nodes <- tidySEM::get_nodes
  if_edit <- tidySEM::if_edit
  edit_graph <- tidySEM::edit_graph

  # Function starts here
  structure <- layout
  if (all(c("IV", "M", "DV") %in% names(structure)) && length(names(structure)) == 3) {
    sx <- function(x) {
      rep("", x)
    }
    is.odd <- function(x) {
      x %% 2 != 0
    }
    structure <- lapply(structure, function(x) {
      if (is.odd(length(x))) {
        c("", x)
        } else {
          x
          }
    })
    max.length <- max(c(length(structure$IV),
                        length(structure$M),
                        length(structure$DV)))
    IV.s <- (max.length - length(structure$IV))/2
    M.s <- (max.length - length(structure$M))/2
    DV.s <- (max.length - length(structure$DV))/2

    structure <- data.frame(IV = c(sx(IV.s), structure$IV, sx(IV.s)),
                            M = c(sx(M.s), structure$M, sx(M.s)),
                            DV = c(sx(DV.s), structure$DV, sx(DV.s)))
  }
  p <- tidySEM::prepare_graph(fit, layout = structure, ...)
  p <- tidySEM::edit_graph(p, {label_location <- label_location})
  if (isTRUE(hide_nonsig_edges)) {
    p <- tidySEM::hide_nonsig_edges(p)
  }
  if (isTRUE(hide_var)) {
    p <- tidySEM::hide_var(p)
  }
  if (isTRUE(hide_cov)) {
    p <- tidySEM::hide_cov(p)
  }
  if (isTRUE(hide_mean)) {
    tidySEM::nodes(p)$label <- tidySEM::nodes(p)$name
  }
  if (!missing(label)) {
    order.label <- match(tidySEM::nodes(p)$name, names(label))
    if (any(is.na(order.label))) {
      stop("Label names don't match. Please double-check your variable names.")
    }
    tidySEM::nodes(p)$label <- unlist(label[order.label])
  }
  if (isTRUE(est_std)) {
    x <- tidySEM::edges(p)$est_sig_std
    x <- sub("^0", "", x)
    x <- sub("^-0", "-", x)
    tidySEM::edges(p)$label <- x
  }
  if (isTRUE(plot)) {
    return(plot(p))
  } else {
      p
    }
}

