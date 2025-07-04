#------------------------------------------ get_param ------------------------------------------
#' Get parameter values from model or ext file
#'
#' This function gets the parameter values from a NONMEM model or ext file including naming and additional
#' variables if present
#'
#' @param model character vector with the model content
#' @param lstblock list with each item being a separate strucured dollor block, usually obtain from \code{\link{nmlistblock}}
#' @param ext character with the name of the NONMEM ext file (if not provided estimates are read directly from the list block)
#' @param addparam logical indicating if the function should try to add parameters (besides THETAs and the ones defined in covariates)
#'  the additional parameters are always returned so it can be used for warnings
#'
#' @export
#' @return a list with parameters, names and matrices
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   get_est("run1.mod")
#' }
get_param <- function(model,lstblock,ext=NULL,addparam=TRUE){
  modst   <- lapply(lstblock,function(x) paste(unlist(x)[names(unlist(x))=="orig"],collapse="\n"))
  modst   <- unlist(strsplit(paste0("$",names(modst)," ",modst),"\n"))
  if(is.null(ext)) mpars <- model else mpars <- ext
  estm    <- get_est(mpars)
  estmm   <- try(get_est(modst),silent=TRUE)
  estma   <- estm$THETA
  ome     <- estm$OMEGA
  dimnames(ome)  <- list(paste0("ETA",1:nrow(ome)),paste0("ETA",1:nrow(ome)))
  sigm    <- estm$SIGMA
  dimnames(sigm) <- list(paste0("EPS",1:nrow(sigm)),paste0("EPS",1:nrow(sigm)))
  omestr  <- ome
  omestr[upper.tri(omestr)] <- ""
  omestr  <- apply(omestr,1,paste,collapse=" ")
  sigmstr <- sigm
  sigmstr[upper.tri(sigmstr)] <- ""
  sigmstr <- apply(sigmstr,1,paste,collapse=" ")

  # Leave out the covariates argument, this should be entirely handled using addparam
  # estma   <- c(estma,covariates)
  allpar  <- get_parmvar(lstblock,returnall=TRUE)
  addpar  <- setdiff(get_parmvar(lstblock),names(estma))
  addpar  <- addpar[!addpar%in%c(get("reserved1",envir=.simenv),"F")] # F is reserved in nm error block
  addparv <- setNames(rep(-999,length(addpar)),addpar) # set unkown values to -999, more likely to fail to ensure user changes this!
  if(addparam) estma <- c(estma,addparv)
  if("try-error"%in%class(estmm) | length(estmm$THETA)!=length(estmm$THETAN)){ # any(is.na(estmm$THETA)): although not perfect NAs can be present for naming
    nams <- ""
  }else{
    nams <- dput2(setNames(trimws(estmm$THETAN),names(estmm$THETA)),TRUE,"theta_names")
  }
  return(list(params=estma,theta_names=nams,omega_matrix=ome,omega_string=omestr,sigma_matrix=sigm,sigma_string=sigmstr,add_params=addpar,all_params=allpar))
}
