#------------------------------------------ get_inits ------------------------------------------
#' get the initial states for the differential equations
#'
#' This function will extracts the initial states for the differential equations from a NONMEM model
#'
#' @param lstblock list with each item being a separate strucured dollor block, usually obtain from \code{\link{nmlistblock}}
#'
#' @export
#' @return a named vector with the state values
#' @author Richard Hooijmaijers
#' @examples
#'
#' mod    <- system.file("example_models","PK.1CMT.ORAL.mod", package = "amp.sim")
#' mdll   <- get_nmblock(mod,block=c("PK","DES"))
#' mdlls  <- nmlistblock(mdll)
#' get_inits(mdlls)
#'
get_inits <- function(lstblock){
  inits1 <- unlist(sapply(lstblock$DES,function(x) return(x$LHS[grepl("DADT\\(.*\\)",x$LHS)])))
  inits1 <- paste0("A",gsub("DADT\\(|\\)","",inits1))
  inits1 <- stats::setNames(rep(0,length(inits1)),inits1)
  inits2 <- unlist(lapply(lstblock$PK,function(x) stats::setNames(trimws(x[x$type=="init"][['RHS']]),x[x$type=="init"][['LHS']])))
  if(!is.null(inits2)){
    names(inits2) <- gsub("_0\\(|\\)","",names(inits2))
    inits <- inits1
    inits[match(names(inits2),names(inits))] <- convert_nmsyntax(inits2)
  }else{
    inits <- inits1
  }
  return(inits)
}
