#------------------------------------------ get_est ------------------------------------------
#' Get model estimates from NONMEM ext or model file
#'
#' This function gets the estimates (THETA, ETA and OMEGA) from a NONMEM ext or model file to be used
#' within the simulations in R. The model file is included as option as the names of THETAs can be
#' obtained in case this is set as comment in the model file
#'
#' @param from the model or ext file (or data.frame/model text string from results object) to be read in to obtain estimates.
#'  extension or class of object of file determines the actions to be taken
#'
#' @details the function will return a list with theta, eta, omega and naming of theta values. In case a model is used as input, the values represent
#'  the initial values from a model. In case the ext file is used, the final estimates are taken. The eta values
#'  are all set to 0. The omega values are returend as a matrix so it can be used for sampling (e.g. using mvrorm).
#'  naming of thetas is taken from the model comments in the THETA block or in case an ext file is used naming is
#'  set to THETA1:n.
#'  In case the model is used as input, there are some assumptions within the function on how the model is coded. For the
#'  omega block the value of omega must always be placed on a separate line (e.g. $OMEGA 0.1 is not permitted as 0.1 should be placed
#'  on the next line. Also covariance within the omega block should be placed on the same line separated by spaces (e.g. for a BLOCK(2)
#'  the first line should state variance eta1 and the second line should state covariance eta1, eta2 followed by variance eta2).
#'  For the theta block, it is assumed that in case lower and upper boundaries are available they are separated by commas.
#'
#' @export
#' @return a list with theta, eta and omega values
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   # get the intial estimates from the model or final estimates from ext file
#'   get_est("run1.mod")
#'   get_est("run1.ext")
#' }
get_est <- function(from){
  if(inherits(from,"data.frame")){
    # In the new structure we can no longer support data frames for ext files 
    lifecycle::deprecate_stop("0.1.0","get_est(from = 'must be a location to ext or model file')")
  }
  if(length(grep("\\.ext$",from))!=0){
    # actions for ext data
    est    <- NMdata::NMreadExt(from)
    theta  <- est[est$par.type=="THETA","value"]
    theta  <- stats::setNames(theta, est[est$par.type=="THETA","parameter"])
    thetan <- names(theta)
    ome    <- est[est$par.type=="OMEGA",] |> NMdata::dt2mat(col.value = "value")
    sigm   <- est[est$par.type=="SIGMA",] |> NMdata::dt2mat(col.value = "value")
  }else{
    # actions for model file (be aware sigma is not mandatory!)
    if(length(from)==1 && file.exists(from))  from <- readLines(from)
    from   <- iconv(from, "latin1", "ASCII", sub="") # make sure there are no non-ASCII characters
    est    <- NMdata::NMreadInits(lines=from, return = "all")
    theta  <- est$pars$init[est$pars$par.type=="THETA"]
    theta  <- stats::setNames(theta, est$pars$parameter[est$pars$par.type=="THETA"])
    thetan <- merge(est$elements[!duplicated(est$elements$linenum),c("linenum","parameter","par.type")],
                    est$lines[est$lines$par.type=="THETA",c("linenum","text.after")])
    thetan <- trimws(thetan[order(thetan$linenum),][thetan$par.type=="THETA","text.after"])
    ome    <- NMdata::dt2mat(est$pars[est$pars$par.type=="OMEGA",], col.value = "init")
    sigm   <- est$pars[est$pars$par.type=="SIGMA",]
    if(nrow(sigm)>0) sigm <- NMdata::dt2mat(sigm, col.value = "init") else sigm   <- NULL
  }
  # create result list
  eta    <- stats::setNames(rep(0,nrow(ome)), paste0("ETA",1:nrow(ome)))
  retlst <- list(THETA = theta, THETAN = thetan, OMEGA = ome, ETA = eta, SIGMA = sigm)
  return(retlst)
}