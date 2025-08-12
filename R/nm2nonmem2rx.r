#------------------------------------------ nm2rxode2 ------------------------------------------
#' Convert NONMEM model to nonmem2rx syntax
#'
#' This function converts a NONMEM model to syntax useable in rxode2 simulations fully based on the nonmem2rx package
#'
#' @param mod character with the model file to be read in and converted
#' @param out character with the name of the output file without a file extension
#' @param control character with the type of control to be returned (see \code{\link{convert_nonmem}} for more details)
#'
#' @export
#' @return a list is returned inluding all building blocks to create a model
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   nm2nonmem2rx("run1.mod")
#' }
nm2nonmem2rx <- function(mod, out=NULL,control=""){
  res         <- nonmem2rx::nonmem2rx(file=mod)
  theta_names <- stats::setNames(res$iniDf$label[!is.na(res$iniDf$ntheta)],res$iniDf$name[!is.na(res$iniDf$ntheta)]) 
  covs        <- res$allCovs[!res$allCovs%in%unique(unlist(dimnames(res$sigma)))]
  covs        <- stats::setNames(rep(-999,length(covs)),covs)
  parm        <- c(res$theta,covs)
  retlst      <- list()
  retlst$modelfun  <- deparse(body(res$fun))
  retlst$modelfun  <- c("model <- function()",retlst$modelfun)
  retlst$modelfun  <- paste(retlst$modelfun,collapse="\n")
  retlst$modname   <- paste0(out,".r")
  
  retlst$control    <- c("library(rxode2)",paste0("source(\"",out,".r\")"))
  retlst$control    <- c(retlst$control, dput2(theta_names,TRUE,"theta_names"))
  retlst$control    <- c(retlst$control, dput2(parm,FALSE,"parm","\n"))
  retlst$control    <- c(retlst$control, dput2(res$omega,FALSE,"ome","\n"))
  retlst$control    <- c(retlst$control, dput2(res$sigma,FALSE,"sigm","\n"))
  retlst$control    <- c(retlst$control, "evnt <- et(amt = 100, ii = 24, addl = 1)")
  retlst$control    <- c(retlst$control, "out  <- rxSolve(model,parm,evnt,omega=ome,sigma=sigm,nSub=10)","plot(out)")
  if(control=="model") retlst$control <- retlst$control[-1:-2]
  
  return(retlst)
}
