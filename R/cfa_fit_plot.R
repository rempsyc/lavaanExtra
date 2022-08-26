#' @title Fit and plot CFA simultaneously
#'
#' @description Print and save CAF fit, as well as plot CFA loadings, simultaneously.
#'
#' @param model CFA model to fit.
#' @param data Data set on which to fit the CFA model.
#' @param covs Logical, whether to include covariances on the lavaan plot.
#' @param estimator What estimator to use for the CFA.
#' @param remove.items Optional, if one wants to remove items from the CFA model
#'                     without having to redefine it completely again.
#' @param file.name Optional, if one wants something different than the default
#'                  file name. Defaults to saving to the "/model" subfolder of
#'                  the working directory. If it doesn't exist, it creates it.
#' @keywords CFA, lavaan, plot, fit
#' @export
#' @examples
#' (latent <- list(visual = paste0("x", 1:3),
#'                 textual = paste0("x", 4:6),
#'                 speed = paste0("x", 7:9)))
#'
#' HS.model <- write_lavaan(latent = latent)
#' cat(HS.model)
#'
#' library(lavaan)
#' fit <- cfa_fit_plot(HS.model, HolzingerSwineford1939)
#' @import lavaan

cfa_fit_plot <- function(model, data, covs = FALSE, remove.items = "", file.name,
                         estimator = "MLR"){
  rlang::check_installed(c("lavaanPlot", "DiagrammeRsvg", "rsvg"), reason = "for this function.")
  if(missing(file.name)) {
    prefix <- deparse(substitute(model))
    time <- gsub(":", ".", Sys.time())
    file.name <- paste0("models/cfa_", prefix, "_", time)
    if (!dir.exists("models")) {
      dir.create("models")
      }
  }
  # Remove requested items
  if(!missing(remove.items)) {
    remove.items0 <- paste0("\\s", remove.items, "\\s")
    remove.items1 <- paste0(remove.items, collapse = " \\+ |")
    remove.items1 <- paste0(remove.items1, " \\+")
    remove.items2 <- paste0("\\+ ", remove.items0)
    remove.items2 <- paste0(remove.items2, collapse = "|")
    remove.items3 <- paste0(remove.items, " ", collapse = "|\\+ ")
    model <- gsub("\n", " \n", model)
    model <- gsub(remove.items1, "", model)
    model <- gsub(remove.items2, "", model)
    model <- gsub(remove.items3, "", model)
  }
  # Fit model
  fit <- lavaan::cfa(model, data = data, estimator = estimator, missing = "fiml", std.lv = TRUE)
  print(summary(fit, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE))
  # Plot the model
  lavaanPlot::lavaanPlot(model = fit,
                         node_options = list(shape = "box", fontname = "Helvetica"),
                         edge_options = list(color = "grey"),
                         coefs = TRUE,
                         stand = TRUE,
                         covs = covs,
                         stars = list("regress"),
                         graph_options=list(rankdir="LR"),
                         sig = .05) -> my.plot
  # # Save file
  lavaanPlot::embed_plot_pdf(my.plot, paste0(file.name, ".pdf"))
  utils::browseURL(paste0(file.name, ".pdf"))
  fit
}

serialNext <- function(prefix){
  if(!file.exists(paste0(prefix, ".pdf"))){return(prefix)}
  i <- 1
  repeat {
    f = paste0(prefix, "_", i)
    if(!file.exists(f)){return(f)}
    i <- i + 1
  }
}
