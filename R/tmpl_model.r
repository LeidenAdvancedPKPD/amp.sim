#------------------------------------------ tmpl_model ------------------------------------------
#' Get coding for template models
#'
#' This function returns the code for some template models
#'
#' @param tmpl string with template
#'
#' @details There are templates available for 1-2 CMT PK models for IV/bolus/oral administration
#'   as both analytical as closed form and parameterized with constants or as CL/V.
#'   To see which templates are available in the package
#'   run the function without arguments
#'
#' @export
#' @return model syntax is returned either to console or script (within Rstudio)
#' @author Richard Hooijmaijers
#' @examples
#'
#'  tmpl_model("des1CMToralK.tmp")
tmpl_model <- function(tmpl){
  if (!requireNamespace("rstudioapi", quietly = TRUE)) stop("Package \"rstudioapi\" needed for this function to work", call. = FALSE)
  if (missing(tmpl)) {
    list.files(system.file(package = "pmxsimtools"), pattern = "\\.tmp$")
  }else{
    ret <- readLines(paste0(system.file(package = "pmxsimtools"),"/",tmpl))
    if(rstudioapi::isAvailable()){
      range <- rstudioapi::getSourceEditorContext()$selection[[1]]$range
      nrang <- rstudioapi::document_position(range$end[1] + 1, 0)
      if(all(range$start==range$end)) nrang <- nrang - c(1,0)
      rstudioapi::insertText(nrang,paste(c(ret,"\n\n"),collapse="\n"))
    }else{
      cat(ret,sep="\n")
    }
  }
}
