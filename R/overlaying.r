#------------------------------------------ overlaying ------------------------------------------
#' Performs overlaying of simulations
#'
#' This function basically appends the simulation output and add this to a reactiveValue
#'
#' @param input list with the input elements from a shiny app
#' @param out dataframe with the results from a simulation to be appended for overlaying
#' @param savedsims reactiveValue or list that contains the saved simulations
#'
#' @export
#' @return a list with a dataframe with the appended simulations and settings
#' @author Richard Hooijmaijers
#' @examples
#' if(requireNamespace("shiny")){
#'   out   <- data.frame(time=0:4, A1=rnorm(5), numsim=1)
#'   input <- shiny::reactiveValues(CL=2, KA=0.3, updOpts="appsim")
#'   overlayres <- overlaying(out,input)
#'   savedsims  <- list(res = overlayres$results, sett = overlayres$settings)
#'   overlayres <- overlaying(input=input,out=out,savedsims=savedsims)
#'   head(overlayres$result)
#' }
#'
overlaying <- function(out,input,savedsims=NULL){
  if(is.null(input)) stop("no input object can be found")
  inpl <- shiny::isolate(shiny::reactiveValuesToList(input))
  if(!exists("out")) stop("Make sure a dataframe is available with simulation results")
  if(inpl$updOpts=="appsim" & !is.null(savedsims$res)){
    resn            <- out
    resn$numsim     <- max(savedsims$res$numsim) + 1
    resn$Simulation <- paste0("sim ",resn$numsim)
    resn$Simulation <- factor(resn$Simulation,levels=unique(resn$Simulation))
    res             <- rbind(savedsims$res,resn)
    sett            <- c(savedsims$sett,list(vals=inpl))
    names(sett)[length(sett)] <- unique(as.character(resn$Simulation))
  }else{
    res            <- out
    res$numsim     <- 1
    res$Simulation <- paste0("sim ",res$numsim)
    res$Simulation <- factor(res$Simulation,levels=unique(res$Simulation))
    sett           <- list(`sim 1`=inpl)
  }
  return(list(results=res,settings=sett))
}
