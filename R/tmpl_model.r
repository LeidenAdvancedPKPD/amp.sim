#------------------------------------------ tmpl_model ------------------------------------------
#' Get coding for template models
#'
#' This function returns the code for some template models
#'
#' @param tmpl character with template
#' @param ret character indicating how the result should be returned. Currently "console", "string" and "script" are accepted
#'
#' @details There are templates available for 1-2 CMT PK models for IV/bolus/oral administration
#'   as both analytical as closed form and parameterized with constants or as CL/V.
#'   To see which templates are available in the package
#'   run the function without arguments
#'
#' @export
#' @return model syntax is returned either to console or script (within Rstudio) or a character string
#' @author Richard Hooijmaijers
#' @examples
#'
#' tmpl_model()
#' tmpl_model("ana1CMTbolusK.tmp")
#'
tmpl_model <- function(tmpl, ret="console"){
  if (missing(tmpl)) {
    list.files(system.file(package = "amp.sim"), pattern = "\\.tmp$")
  }else{
    tmplm <- readLines(paste0(system.file(package = "amp.sim"),"/",tmpl))
    if(ret=="script"){
      if(rstudioapi::isAvailable()){
        range <- rstudioapi::getSourceEditorContext()$selection[[1]]$range
        nrang <- rstudioapi::document_position(range$end[1] + 1, 0)
        if(all(range$start==range$end)) nrang <- nrang - c(1,0)
        rstudioapi::insertText(nrang,paste(c(tmplm,"\n\n"),collapse="\n"))
      }else{
        cli::cli_text("code can only be used for output in Rstudio environment (use 'string' or 'console' for ret argument outside Rstudio)")
      }
    }else if(ret=="console"){
      cat(paste(tmplm,collapse="\n"))
    }else if(ret=="string"){
      return(tmplm)
    }
  }
}
