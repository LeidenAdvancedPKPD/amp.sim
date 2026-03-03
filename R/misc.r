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
#------------------------------------------ pos_clpar ------------------------------------------
#' Get position of closing parenthesis
#'
#' This function gets the position of the closing parenthesis after the first opening one
#'
#' @param x character string for which the parenthesis should be searched
#'
#' @export
#' @return a numeric with the position of the closing parenthesis (will be -1 if no match is present)
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   tst <- "IF (test == A(1)) a(1)=(1*5)/2"
#'   pos_clpar(tst)
#'   substring(tst,1,pos_clpar(tst))
#' }
pos_clpar <- function(x){
  if(grepl("'|\"",x)) stop("character comparison not supported")  
  ob  <- gregexpr("\\(",x)[[1]] 
  cb  <- gregexpr("\\)",x)[[1]] 
  names(ob) <- rep("+1",length(ob))
  names(cb) <- rep("-1",length(ob))
  ab  <- sort(c(ob, cb))
  cab <- as.numeric(names(ab)) |> cumsum()
  return(ab[which(cab==0)[1]])
}