#------------------------------------------ settings2df ------------------------------------------
#' Add settings to dataframe
#'
#' This function adds settings or input elements to a dataframe for displaying in app
#'
#' @param savedsims reactiveValue that contains the saved simulations
#' @param leaveout character vector with the the elements that should be lefted out the dataframe
#'
#' @export
#' @return a dataframe with settings
#' @author Richard Hooijmaijers
#' @examples
#'
#' if(requireNamespace("tidyr")){
#'   sim1 <- list(THETA1  = 0.5, THETA2 = 1,
#'                alllabs =c("THETA1%=%DUMMY1","THETA2%=%DUMMY2"))
#'   sim2 <- list(THETA1  = 0.9, THETA2 = 1.5)
#'   settings2df(list(sim1 = sim1, sim2 = sim2))
#' } 
#'
settings2df <- function(savedsims,leaveout=c("go","updOpts","sett","refr","tabsel")){
  if (!requireNamespace("tidyr", quietly = TRUE)) stop("Package \"tidyr\" needed for this function to work", call. = FALSE)
  sett          <- lapply(savedsims,function(x) x[names(x)!="alllabs"])
  sett          <- lapply(sett,function(x) lapply(x,paste,collapse=", ")) # take into account sliders
  sett          <- do.call(rbind,lapply(sett,"as.data.frame"))
  sett$sim      <- row.names(sett)
  sett          <- tidyr::pivot_longer(sett,cols=!tidyr::contains("sim"))
  sett          <- tidyr::pivot_wider(sett,names_from = "sim",values_from="value")
  labsr         <- savedsims[[1]]$alllabs
  labs          <- sub(".*%=%","",labsr)
  names(labs)   <- sub("%=%.*","",labsr)
  sett          <- sett[!sett$name%in%leaveout,]
  sett$name     <- labs[match(sett$name,names(labs))]
  return(sett)
}
