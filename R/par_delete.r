#------------------------------------------ par_delete ------------------------------------------
#' Delete parenthesis including a numeric within a vector
#'
#' This function deletes all parenthesis from a character vector that has a numeric value inside.
#' This is applicable as THETA(n), ETA(n), DADT(n) is not always allowed in R coding
#'
#' @param vect the vector that should be scanned for parenthesis
#' @param excfun exclude functions from deleting parenthesis (taken from the globally defined function list in the package)
#'
#' @export
#' @return a vector with the stripped parenthesis
#' @author Richard Hooijmaijers
#' @examples
#'
#'   par_delete(c("LOG(1)","ETA(1)","EXP(2)/ETA(3)+THETA(4)"))
par_delete <- function(vect,excfun=TRUE){
  avect <- NULL
  for(i in 1:length(vect)){
    numx  <- gregexpr("\\([[:digit:]]*\\)",vect[i])[[1]]
    if(min(numx)<0){
      avect <- c(avect,vect[i])
    }else{
      if(excfun){
        funcs <- get("nmfuncs",envir=.simenv)
        numx2 <- gregexpr(paste(names(funcs),collapse="|"),vect[i])[[1]]
        if(min(numx2)>=0){
          numx2 <- numx2+attr(numx2,"match.length")-1
          tatt  <- attr(numx,"match.length")[!numx%in%numx2]
          numx  <- numx[!numx%in%numx2];attr(numx,"match.length") <- tatt
        }
        #print(numx)
      }
      if(length(numx)==0){
        avect <- c(avect,vect[i])
      }else{
        for(j in length(numx):1){
          vect[i] <- paste0(substr(vect[i],1,numx[j]-1),
                            substr(vect[i],numx[j]+1,numx[j]+attr(numx,"match.length")[j]-2),
                            substr(vect[i],numx[j]+attr(numx,"match.length")[j],nchar(vect[i])))
        }
        avect <- c(avect,vect[i])
      }
    }
  }
  return(avect)
}
