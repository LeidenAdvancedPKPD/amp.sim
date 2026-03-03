#------------------------------------------ get_iiv_ruv_ctl ------------------------------------------
#' Get omega or sigma values from control stream
#'
#' This function gets the omega or sigma values from a model control stream. A separate function is developed as 
#' obtaining these values is more difficult compared to using the output
#'
#' @param mod character vector of length 1 with filename of model, in case length is greater than 1 it is assumed to be a vector with model code
#' @param type character vector of length 1 with the type of block to get (valid types are "OMEGA" and "SIGMA")
#'
#' @export
#' @return a named vector with omega values
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   get_omega_ctl("run1.mod")
#'   get_omega_ctl("run1.mod","SIGMA")
#'   get_omega_ctl(c("$OMEGA BLOCK(3)","0.2","0.1  0.3","0.02 0.03 0.04"))
#' }
get_iiv_ruv_ctl <- function(mod,type="OMEGA"){
  est  <- get_nmblock(mod,type,omitbn = FALSE)
  varbl <- data.frame(cont=unlist(est))
  varbl$cont    <- gsub(";.*","",varbl$cont)
  varbl$numbl   <- cumsum(grepl(paste0("\\$",type),varbl$cont))
  varbl$bl      <- grepl(paste0("\\$",type,".*BLOCK"),varbl$cont)
  varbl$numvar  <- suppressWarnings(ifelse(varbl$bl,as.numeric(gsub(".*BLOCK\\(|\\)","",varbl$cont)),NA))
  numn         <- suppressWarnings(lapply(strsplit(varbl$cont," "),as.numeric))
  varbl$numvar[!varbl$numbl%in%varbl$numbl[varbl$bl]] <- sapply(numn,function(x) length(stats::na.omit(x)))[!varbl$numbl%in%varbl$numbl[varbl$bl]]
  numvar       <- tapply(varbl$numvar, varbl$numbl, sum, na.rm=TRUE)
  varbl$numvar  <- numvar[match(varbl$numbl,as.numeric(names(numvar)))]
  varbl$numvarc <- ifelse(duplicated(varbl[,c("numbl","numvar")]),0,varbl$numvar)
  varbl$numvarc <- cumsum(varbl$numvarc)
  
  fin <- lapply(unique(varbl$numbl),function(x){
    allom <- varbl$cont[varbl$numbl==x]
    ret   <- suppressWarnings(as.numeric(stats::na.omit(as.numeric(strsplit(paste(allom,collapse=" ")," ")[[1]]))))
    if(length(ret)==0){
      return()
    }else if(varbl$bl[varbl$numbl==x][1]){
      bn1        <- rep(1:varbl$numvar[varbl$numbl==x][1],1:varbl$numvar[varbl$numbl==x][1])
      bn2        <- unlist(sapply(1:varbl$numvar[varbl$numbl==x][1],function(y) 1:y))
      bn3        <- (varbl$numvarc[varbl$numbl==x][1]-varbl$numvar [varbl$numbl==x][1])+1
      names(ret) <- paste0(type,".",(bn1+bn3)-1,".",(bn2+bn3)-1,".")
    }else{
      bn <- ((varbl$numvarc[varbl$numbl==x][1]-varbl$numvar[varbl$numbl==x][1])+1):varbl$numvarc[varbl$numbl==x][1]
      names(ret) <- paste0(type,".",bn,".",bn,".")
    }
    ret
  })
  unlist(fin)
}