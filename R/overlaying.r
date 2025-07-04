#------------------------------------------ overlaying ------------------------------------------
#' Performs overlaying of simulations
#'
#' This function basically appends the simulation output and add this to a reactiveValue
#'
#' @param input list with the input elements from a shiny app
#' @param out dataframe with the results from a simulation to be appended for overlaying
#' @param savedsims reactiveValue that contains the saved simulations
#'
#' @export
#' @return a list with a dataframe with the appended simulations and settings
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{overlaying(out=out,input=input,savedsims=savedsims)}
overlaying <- function(out,input=input,savedsims){
  if(is.null(input)) stop("no input object can be found")
  if(!exists("out")) stop("Make sure a dataframe is available with simulation results")
  if(input$updOpts=="appsim" & !is.null(savedsims$res)){
    resn            <- out
    resn$numsim     <- max(savedsims$res$numsim) + 1
    resn$Simulation <- paste0("sim ",resn$numsim)
    resn$Simulation <- factor(resn$Simulation,levels=unique(resn$Simulation))
    res             <- rbind(savedsims$res,resn)
    sett            <- c(savedsims$sett,list(vals=reactiveValuesToList(input)))
    names(sett)[length(sett)] <- unique(as.character(resn$Simulation))
  }else{
    res            <- out
    res$numsim     <- 1
    res$Simulation <- paste0("sim ",res$numsim)
    res$Simulation <- factor(res$Simulation,levels=unique(res$Simulation))
    sett           <- list(`sim 1`=reactiveValuesToList(input))
  }
  return(list(results=res,settings=sett))
}
