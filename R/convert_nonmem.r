#------------------------------------------ convert_nonmem ------------------------------------------
#' Convert NONMEM model to R syntax
#'
#' This function converts a NONMEM model to syntax useable in R simulations. Currently DeSolve, rxode2 (nonmem2rx) and mrgsolve are available syntaxes to use
#' Additionally a code to control the simulations is created to directly test the simulations
#'
#' @param model character with the model file to be read in and converted
#' @param out character with the name of the output file without a file extension
#' @param ext character with the name of the NONMEM ext file (if not provided estimates are read directly from control stream)
#' @param mod_return a character vector indicating which items should be returned from the model function. For more information see details
#' @param type_return character indicating the type of model that should be created. Currently "deSolve", "rxode2", "nonmem2rx" and "mrgsolve" are accepted
#' @param overwrite logical indicating if the output model should be overwritten
#' @param control character indicating how the model control code should be returned. Currently "file", "console", "string", "script" and "model" (only for rxode2/DeSolve) are accepted
#' @param verbose logical indicating if additional information is written to the console
#'
#' @details For the mod_return argument, the additional variables are added to the output in case the type_return is either mrgsolve or deSolve.
#'
#' @export
#' @return a converted file is generated and a message is returned
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   convert_nonmem("run1.mod",out="rsim/run1")
#' }
convert_nonmem <- function(model,out, ext=NULL, mod_return=NULL,type_return="mrgsolve",overwrite=FALSE, control="file",verbose=TRUE){
  # removed 'addparam=TRUE' from arguments, decided to always use this (cannot think of a reason why not to)
  mdl    <- readLines(model)
  mdll   <- get_nmblock(mdl,block=c("PROB","SUB","MODEL","PK","DES","PRED","THETA","OMEGA","ERROR","SIGMA","EST"))
  mdlls  <- nmlistblock(mdll)
  if(type_return=="mrgsolve"){
    tmplst <- nm2mrgsolve(mdlls,model=mdl,ext=ext, mod_return = mod_return, out=out)
  }else if(type_return=="rxode2"){
    tmplst <- nm2rxode2(mdlls,model=mdl,ext=ext, out=out, control=control)
  }else if(type_return=="deSolve"){
    tmplst <- nm2deSolve(mdlls,model=mdl,ext=ext, out=out, control=control)
  }else if(type_return=="nonmem2rx"){
    tmplst <- nm2nonmem2rx(model,out=out, control=control)
  }else{
    stop("make sure a valid type_return is given")
  }
  # fill in template and write to disk
  # tomod <- ifelse(control=="model",TRUE,FALSE)
  tmpl  <- readLines(paste0(system.file(package="amp.sim"),"/",tolower(type_return),".tmpl"))
  if(!is.null(out)){
    if(!overwrite && file.exists(tmplst$modname)){
      warning("File already present and not overwritten (set overwrite to TRUE if file should be overwritten)")
    }else{
      writeLines(whisker::whisker.render(tmpl,tmplst),tmplst$modname)
    }
  }
  # handle the control part of the simulations
  if(control=="console")  cat(paste(tmplst$control,collapse="\n"))
  if(control=="file")     cat(paste(tmplst$control,collapse="\n"),file=paste0(out,"_control.r"))
  if(control=="string")   return(tmplst$control)
  if(control=="script"){
    if(rstudioapi::isAvailable()){
      range <- rstudioapi::getSourceEditorContext()$selection[[1]]$range
      nrang <- rstudioapi::document_position(range$end[1] + 1, 0)
      if(all(range$start==range$end)) nrang <- nrang - c(1,0)
      rstudioapi::insertText(nrang,paste(c(tmplst$control,"\n\n"),collapse="\n"))
    }else{
      cli::cli_text("script can only be used for output in Rstudio environment (use 'file', 'string' or 'console' for control argument outside Rstudio)")
    }
  }
  # Handle messages (and verbose), check how we want to do this (could add messages in nm2package or have a single message?)
  if(verbose){
    cli::cli_text(paste0("The model is converted to {.pkg ",type_return,"} syntax!"))
    cli::cli_text("However take into account that this function tries to create a good starting point for simultions in R. It is advised though to double check and test the resulting model code to see if everything is handled correctly. At least the following should be taken into account:")
    cli::cli_bullets(c("*"="Be aware of usage of TIME/TALD in model code. In certain cases this works, however rewriting might be necessary (likely when used in des block)"))
    cli::cli_bullets(c("*"="When converting to {.pkg deSolve}, items like IV dosing, bio-availability, lag time and residual error needs to be set manually"))
    cli::cli_bullets(c("*"="When converting to {.pkg deSolve}, initialiization of compartments might need additional checking when model parameters are used (e.g. A_0(1)=BSL)"))
    cli::cli_text("Additional information can be found in the package vignettes.")
  }
  if(length(tmplst$wrn>0)) for(i in tmplst$wrn){cli::cli_alert_warning(i)} 
  if(length(tmplst$msg>0)) for(i in tmplst$msg){cli::cli_alert_info(i)} 
}
