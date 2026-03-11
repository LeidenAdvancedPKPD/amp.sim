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
#' \dontrun{settings2df(savedsims=savedsims)}
settings2df <- function(savedsims,leaveout=c("go","updOpts","sett","refr","tabsel")){
  if (!requireNamespace("tidyr", quietly = TRUE)) stop("Package \"tidyr\" needed for this function to work", call. = FALSE)
  sett          <- lapply(savedsims,function(x) x[names(x)!="alllabs"])
  sett          <- lapply(sett,function(x) lapply(x,paste,collapse=", ")) # take into account sliders
  sett          <- do.call(rbind,lapply(sett,"as.data.frame"))
  sett$sim      <- row.names(sett)
  # sett          <- reshape2::melt(sett,id="sim")
  # sett          <- reshape2::dcast(sett,variable~sim,value.var = "value")
  sett          <- tidyr::pivot_longer(sett,cols=!tidyr::contains("sim"))
  sett          <- tidyr::pivot_wider(sett,names_from = "sim",values_from="value")
  labsr         <- savedsims[[1]]$alllabs
  labs          <- sub(".*%=%","",labsr)
  names(labs)   <- sub("%=%.*","",labsr)
  sett          <- sett[!sett$name%in%leaveout,]
  #sett$name     <- plyr::revalue(sett$name,labs)
  sett$name     <- labs[match(sett$name,names(labs))]
  return(sett)
}
