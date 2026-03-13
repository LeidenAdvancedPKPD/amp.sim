#------------------------------------------ convert_nmsyntax ------------------------------------------
#' Convert NONMEM specific syntax to R syntax
#'
#' This function converts a NONMEM syntax to R syntax, mainly for functions and operators
#'
#' @param x character vector with the syntax to be converted
#' @param type character with the type of syntax to convert to (currently "deSolve" and "mrgsolve" and "RxODE" are supported)
#'
#' @export
#' @return character vector with the converted syntax
#' @author Richard Hooijmaijers
#' @examples
#'
#' convert_nmsyntax("IF(VAR.GT.0) VAR2 = PHI(1)")
convert_nmsyntax <- function(x,type="mrgsolve"){
  # list of NONMEM functions and operators and the R version of if
  funcs <- get("nmfuncs",envir=.simenv)
  oper  <- get("nmoper",envir=.simenv)
  for(i in 1:length(oper))  x <- gsub(names(oper)[i], oper[i], x, ignore.case = TRUE)
  for(i in 1:length(funcs)){
    if(type=="mrgsolve" & funcs[i]%in%c('min(','max(')){
      x <- gsub(names(funcs)[i], paste0("std::",funcs[i]), x, ignore.case = TRUE)
    }else if(type=="mrgsolve" & funcs[i]=='ceiling('){
      x <- gsub("CEILING\\(","ceil(", x, ignore.case = TRUE)
    }else if(type=="mrgsolve" & funcs[i]=='phi('){
      #x <- gsub("PHI\\((.*)\\)", "R::pnorm(\\1, 0.0, 1.0, 1, 0)", x, ignore.case = TRUE)
      x <- gsub("PHI\\(([^)]*)\\)", "R::pnorm(\\1, 0.0, 1.0, 1, 0)", x, ignore.case = TRUE)
    }else{
      x <- gsub(names(funcs)[i], funcs[i], x, ignore.case = TRUE)
    }
  }
  return(x)
}
