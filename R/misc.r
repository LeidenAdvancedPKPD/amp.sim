#------------------------------------------ dput2 ------------------------------------------
#' Wrapper function around dput to provide more options
#'
#' This function wraps around the dput function and provide more options to save result
#' in a vector
#'
#' @param x An object passed to \code{dput}
#' @param comment logical indicating if comment characters should be prepended to results
#' @param obj character of length one indicating the name of the object that should be prepended to result
#' @param collapse character of length one with the collapse character. If provided the result will be pasted with this collapse character
#' @param ... additional arguments passed to dput
#'
#' @export
#' @return a vector with the result from dput
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   dput2(setNames(rnorm(26),letters))
#' }
dput2 <- function(x,comment=FALSE,obj=NULL,collapse=NULL,...){
  ret <- utils::capture.output(dput(x,...))
  if(!is.null(obj)) ret <- c(paste(obj,"<-",ret[1]),ret[-1])
  if(comment) ret <- paste("#", ret)
  if(!is.null(collapse)) ret <- paste(ret,collapse=collapse)
  return(ret)
}
