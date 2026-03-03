#------------------------------------------ get_nmblock ------------------------------------------
#' Get information from dollar blocks inside NONMEM control streams
#'
#' This function returns a list with indices or content of dollar blocks
#'
#' @param model character vector of length 1 with filename of model, in case length is greater than 1 it is assumed to be a vector with model code
#' @param block character vector with names of the model blocks. Take into account that grep is used with respect to partial matching
#' @param ret character with the type of return value can be either "content" or "index"
#' @param omitbn logical indicating if the name of the block should be omited when return (has only effect if ret="content")
#'
#' @export
#' @return a list with either a numeric vector with the indices or a character vector with the content of the dollar blocks
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{get_nmblock("run1.mod","OMEGA")}
get_nmblock <- function(model,block,ret="content",omitbn=TRUE){
  aliases <- list(c("PROBLEM", "PROB"), c("SUBROUTINES", "SUBS","SUB"), c("ESTIMATE","ESTM", "EST"))
  if(length(model)==1) {rmdl <- readLines(model)}else{rmdl <- model}
  rmdl <- iconv(rmdl, "latin1", "ASCII", sub="") # want to get rid of non-ASCII characters
  alldoll  <- c(grep("^[^;]*\\$",rmdl),length(rmdl)+1)
  ret      <- lapply(block,function(x){
    aliaspres <- sapply(aliases, function(nm) any(nm%in%x))
    if(any(aliaspres)) forsub <- paste0("\\$",unlist(aliases[aliaspres]),collapse="|") else forsub <- paste0("\\$",x)
    retblock <- unlist(lapply(grep(paste0("^[^;]*",forsub),rmdl),function(y) y:(min(alldoll[alldoll>y]-1))))
    if(ret=="content") {
      retblock <- rmdl[retblock]
      if(omitbn){trimws(sub(forsub,"",retblock))}else{retblock}
    }else if(ret=="index"){
      retblock
    }
  })
  names(ret) <- block
  return(ret)
}
