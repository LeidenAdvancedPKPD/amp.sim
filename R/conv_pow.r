#------------------------------------------ conv_pow ------------------------------------------
#' Convert infix power notation to prefix notation
#'
#' This function will transform the power notation that can be used in R to the one needed by mrgsolve
#'
#' @param x character vector with the formulas to convert
#'
#' @export
#' @return a vector with the transformed power notations
#' @author Richard Hooijmaijers
#' @examples
#'
#' conv_pow("y = par1*(par2/par3)^xy + a - par4**(2/par5)")
conv_pow <- function(x){
  sapply(x,function(y){
    if(!grepl("=",y) | !grepl("\\*\\*|\\^",y)){
      return(y)
    }else{
      ret   <- sub("=","~",y)
      ret   <- paste0("substitute(",ret,",list(`^`='pow',`**`='pow'))")
      ret   <- try(eval(parse(text=ret)),silent=TRUE)
      if("try-error"%in%class(ret)){
        cat(paste("Could not correctly convert powers (",y,"), returned original string\n"))
        return(y)
      }
      ret   <- paste(trimws(deparse(ret)),collapse="")
      ret   <- gsub("\"","",ret)
      return(sub("~","=",ret))
    }

  },USE.NAMES = FALSE)
}
