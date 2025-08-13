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
  # df_mod <- function(x,type){
  #   rets  <- trimws(gsub(";.*|FIX","",x))
  #   rets  <- strsplit(rets,"[[:blank:]]+") 
  #   for(i in 1:length(rets)){
  #     rets[[i]] <- as.numeric(rets[[i]])
  #     names(rets[[i]]) <- paste0(type,".",i,".",1:length(rets[[i]]),".")
  #     if(length(rets[[i]])==1) names(rets[[i]]) <- paste0(type,".",i,".",i,".")
  #   }
  #   data.frame(t(unlist(rets)))
  # }
  to_matr <- function(x,type){
    npar  <- max(as.numeric(gsub(paste0(type,"\\.[[:digit:]]*|\\."),"",names(x))))
    if(type=="OMEGA") {eta   <- rep(0,npar); names(eta) <- paste0("ETA",1:npar)}
    matr  <- matrix(nrow=npar,ncol=npar)
    for(i in 1:ncol(x)){
      fe <- as.numeric(gsub(paste0(type,"\\.|\\.[[:digit:]]*\\."),"",names(x)[i]))
      le <- as.numeric(gsub(paste0(type,"\\.[[:digit:]]*|\\."),"",names(x)[i]))
      matr[fe,le] <- matr[le,fe] <- x[,i]
    }
    matr[is.na(matr)] <- 0
    if(type=="OMEGA") return(list(matr,eta)) else return(matr)
  }
  # Define function to enable reading the last table (in case multiple estimation methods are used)
  readlast <- function(x){
    dat    <- suppressWarnings(try(readLines(x),silent=TRUE))
    tabpos <- grep("TABLE NO\\.",dat)
    suppressWarnings(try(utils::read.table(x, skip=tabpos[length(tabpos)], header=TRUE,fill = TRUE),silent=TRUE))
  }
  if(inherits(from,"data.frame")  || length(grep("\\.ext$",from))!=0){
    # actions for ext data
    if(inherits(from,"data.frame")) est <- from else  est <- readlast(from)
    est    <- est[est$ITERATION==-1.0e+09,]
    theta  <- est[,grep("THETA",names(est))]
    thetan <- names(theta)
    ome    <- est[,grep("OMEGA",names(est)),drop=FALSE]
    sigm   <- est[,grep("SIGMA",names(est)),drop=FALSE]
  }else{
    # actions for model file
    est    <- get_nmblock(from,c("THETA","OMEGA","SIGMA"))
    thetaa <- est$THETA[trimws(est$THETA)!="" & !grepl("^;",est$THETA)]
    thetan <- gsub('^.+?;(.*)', "\\1",trimws(thetaa))
    theta  <- gsub("\\(|\\).*|;.*","",thetaa)
    theta  <- trimws(gsub("FIX","",theta))
    theta  <- sapply(strsplit(theta,",| "),function(x){
      ret <- stats::na.omit(as.numeric(x))
      ifelse(length(ret)==1,ret,ret[2])
    })
    names(theta) <- paste0("THETA",1:length(theta))
    omega  <- est$OMEGA[trimws(est$OMEGA)!="" & !grepl("^;",est$OMEGA)]
    if(length(omega)>0)  ome  <- data.frame(t(data.frame(get_iiv_ruv_ctl(from)))) else ome <- data.frame()
    sigma  <- est$SIGMA[trimws(est$SIGMA)!="" & !grepl("^;",est$SIGMA)]
    if(length(sigma)>0)  sigm <- data.frame(t(data.frame(get_iiv_ruv_ctl(from,"SIGMA")))) else sigm <- data.frame()
    # omega  <- est$OMEGA[trimws(est$OMEGA)!="" & !grepl("^;",est$OMEGA) & !grepl("BLOCK\\(.*\\)",est$OMEGA)]
    # if(length(omega)>0)  ome <- df_mod(omega,"OMEGA") else ome <- data.frame()
    # sigma  <- est$SIGMA[trimws(est$SIGMA)!="" & !grepl("^;",est$SIGMA)]
    # if(length(sigma)>0)  sigm <- df_mod(sigma,"SIGMA") else sigm <- data.frame()
  }
  # create valid matrix for omegas and sigma
  if(nrow(ome)>0)   omer <- to_matr(ome,"OMEGA")
  if(nrow(sigm)>0) sigmr <- to_matr(sigm,"SIGMA")

  retlst <- list(THETA=unlist(theta),THETAN=thetan,OMEGA=matrix(),ETA=0,SIGMA=matrix)
  if(nrow(ome>0))  {retlst$OMEGA <- omer[[1]];retlst$ETA <- omer[[2]];}
  if(nrow(sigm>0)) retlst$SIGMA <- sigmr
  return(retlst)
}
