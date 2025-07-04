#------------------------------------------ mdose ------------------------------------------
#' Performs multiple dosing in case of analytical solution of model
#'
#' This function takes a function that defines a model in analytical solution and performs multiple dosing for it
#'
#' @param Dose numeric vector with the dosing height
#' @param tau numeric vector with the tau of dosing
#' @param ndose numeric vector with the number of doses
#' @param t numeric vector with the time-points that should be outputted
#' @param func name of the function for which mutliple dosing should be applied
#' @param ... arguments for func
#'
#' @details This function will create a list that can be used to perform superposition
#'   which is necessary in case of an analytical solution in a multiple dose setting.
#'   The function will check if there is an overlap in arguments and will use the arguments
#'   given to \code{mdose} for the function given in \code{func} if applicable (e.g. it is
#'   likely that \code{func} has an argument for Dose, in this case it will use the Dose argument
#'   provide in \code{mdose})
#'   The function can have any number of arguments that can be passed using "...". However there
#'   should at least be an argument \code{t} which is the time vector for which simulations are
#'   necessary.
#'
#' @export
#' @return a data frame with the superimposed results
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'  ana1CMTiv <- function(Dose,pars,t){
#'    Dose * pars['C'] * exp(-pars['L']*t)
#'  }
#'  pars <- c(L=.01,C=5)
#'  mdose(10,tau=24,ndose=5,t=0:240,func=ana1CMTiv,pars=pars)
#' }
mdose <- function(Dose,tau,ndose,t,func,...){
  # Make sure the overlapping arguments are passed to the function
  args1        <- lapply(ls(),function(x) get(x))
  names(args1) <- ls(pattern="[^args1]")
  args2        <- c(args1,list(...))
  args2        <- args2[names(formals(func))]
  args2        <- args2[names(args2)[names(args2)!="t"]]

  # Create time list for superposition, perform function multiple times and output dfrm
  timlst <- lapply(t, function(x) {
    n.tau <- ceiling( x / (sum.tau <- sum( tau)))
    t     <- c( 0, rep( 0:(n.tau-1) * sum.tau, each = length( tau)) + rep( cumsum( tau), n.tau))
    head(x - t[ t <= x],n=ndose)
  })
  y <- sapply(timlst,function(y){  sum(do.call(deparse(substitute(func)),c(args2,t=list(y)))) })
  return(data.frame(time=t,y=y))
}
