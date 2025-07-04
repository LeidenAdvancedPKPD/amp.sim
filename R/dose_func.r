#------------------------------------------ dose_func ------------------------------------------
#' Create data.frame with dosing for usage in simulation
#'
#' This function creates a data.frame that can be used for events of the lsoda function
#'
#' @param cmt number of compartment or differential equation where the dosing should be given
#' @param value the value of the dosing that should be given
#' @param tinf in case value is set an infusion is assumed with tinf as infusion time
#' @param tau dosing interval to be used
#' @param ndose number of doses to be used
#' @param times In case tau and ndose cannot be used (unequal dosing), this parameter can be
#'   used to set times of dosing (e.g c(0,24,168))
#'
#' @export
#' @return a data frame that can be used as an event dataset within lsoda
#' @author Richard Hooijmaijers
#' @examples
#'
#'  dose_func(8,100,tau=48,ndose=5,tinf=2)
dose_func <- function(cmt,value,tinf,tau,ndose,times){
  if(missing(times)){
    timing <- seq(0,(ndose-1)*tau,tau)
  }else{
    timing <- times
  }
  dose <- data.frame(var=paste0("A",cmt),time=timing,value=value,method="add")
  if(!missing(tinf)){
    dose2 <- data.frame(var=paste0("A",cmt),time=timing+tinf,value=0,method="rep")
    dose  <- rbind(dose,dose2)
    dose  <- dose[order(dose$time),]
    dose$value[dose$value!=0] <- dose$value[dose$value!=0] / tinf
  }
  return(dose)
}
