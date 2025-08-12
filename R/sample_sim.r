#------------------------------------------ sample_sim ------------------------------------------
#' Sample model parameters for a simulation
#'
#' This function samples parameters for a simulation. It wraps around the [sample_par] function on the background
#'
#' @param nrepl Number of replicates for the simulation
#' @param nsub Number of subjects for the simulation
#' @param type character with the type of simulation to perform (see details)
#' @param ... Additional arguments passed to [sample_par]
#'   mainly for passing information for ext and cov files
#'
#' @details This function is a high level function wrapper for the \code{sample_par} function specified
#' for different types of simulations that might occur. Currently the following situations can be sampled:
#' - `noIIV`: Sample without uncertainty and without IIV
#' - `sameIIV`: Sample without uncertainty and with the same IIV values within subjects
#' - `varIIV`: Sample without uncertainty and with different IIV values within subjects
#' - `unc_noIIV`: Sample with uncertainty and without IIV
#' - `unc_sameIIV`: Sample with uncertainty and and with the same IIV values within subjects
#' - `unc_varIIV`: Sample with uncertainty and with different IIV values within subjects
#' 
#' In all the cases above where uncertainty is sampled, this is done only for THETA values.
#'
#' @export
#' @return a dataframe with sampled values
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   sample_sim(nrepl=2,nsub=3,type="unc_varIIV",
#'              ext="run2.ext",cov="run2.cov")
#' }

sample_sim <- function(nrepl=2,nsub=3,type="noIIV",...){
  if(type=="noIIV"){
    ret     <- sample_par(...,nrepl=nsub*nrepl)
    ret$REP <- rep(1:nrepl,each=nsub)
    ret$ID  <- rep(1:nsub,nrepl)
  }else if(type=="sameIIV"){
    ret     <- sample_par(...,inc_eta = TRUE,nrepl=nsub)
    ret     <- ret[rep(1:nsub,nrepl),]
    ret$REP <- rep(1:nrepl,each=nsub)
  }else if(type=="varIIV"){
    ret     <- sample_par(...,inc_eta = TRUE,nrepl=nsub*nrepl)
    ret$REP <- rep(1:nrepl,each=nsub)
    ret$ID  <- rep(1:nsub,nrepl)
  }else if(type=="unc_noIIV"){
    ret     <- sample_par(...,uncert=TRUE,nrepl=nrepl)
    ret     <- ret[rep(1:nrow(ret),nsub),]
    ret$REP <- ret$ID
    ret     <- ret[order(ret$REP),]
    ret$ID  <- rep(1:nsub,nrepl)
  }else if(type=="unc_sameIIV"){
    reps    <- sample_par(...,uncert=TRUE,nrepl=nrepl)
    reps    <- reps[rep(1:nrow(reps),each=nsub),]
    subs    <- sample_par(...,inc_theta=FALSE,inc_eta=TRUE,nrepl=nsub)
    subs    <- subs[rep(1:nrow(subs),nrepl),]
    ret     <- cbind(reps,subs[,!names(subs)%in%"ID"])
    ret$REP <- ret$ID
    ret$ID  <- rep(1:nsub,nrepl)
  }else if(type=="unc_varIIV"){
    reps    <- sample_par(...,uncert=TRUE,nrepl=nrepl)
    reps    <- reps[rep(1:nrow(reps),each=nsub),]
    subs    <- sample_par(...,inc_theta=FALSE,inc_eta=TRUE,nrepl=nsub*nrepl)
    ret     <- cbind(reps, subs[,!names(subs)%in%"ID"])
    ret$REP <- ret$ID
    ret$ID  <- rep(1:nsub,nrepl)
  }
  return(ret[,c("REP","ID",names(ret)[!names(ret)%in%c('REP','ID')])])
}
