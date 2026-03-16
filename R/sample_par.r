#------------------------------------------ sample_par ------------------------------------------
#' Sample model parameters from a multivariate normal distribution
#'
#' This function samples model parameters from NONMEMs covariate matrix (*.cov) and final parameter
#'  estimates (*.ext). Furthermore etas can also be sampled where eta blocks are taken into account (see details)
#'
#' @param ext character string with location of ext file with final model parameters 
#' @param covmat character string with location of cov file with covariance matrix or data.frame of cov file
#' @param bootstrap character string with location of ext files from bootrstrap or vector with ext files from bootstrap
#'    (relevant in case ext files should be excluded because of minimization issues)
#' @param seed a numeric with the seed number used in set.seed to enable reproducibility, when not provided 
#'  the seed from the global environment will be used (e.g. using [base::set.seed])
#' @param nrepl numeric with the number of replicates to sample
#' @param inc_theta logical indicating if THETAs should be added to result
#' @param inc_eta logical indicating if ETAs should be added to result
#' @param verbose logical indicating if additional information should be added to result (e.g. OMEGA/SIGMA values)
#' @param dropfixed logical indicating if parameters that are fixed should be dropped (can only be done in case covmat is provided)
#' @param uncert logical indicating if the uncertainty should be sampled
#' @param restheta character with the theta that describes residual error (e.g. "THETA3") in case uncertainty is sampled
#'   this parameter will be set to the population value
#'
#' @details In general the function can be used to sample from covariance matrix so the different parameters can be
#'   added to a simulation dataset or model to enable uncertainty simulations. In most cases it is not necessary to
#'   include OMEGAs or SIGMAs in these type of simulations. It can be convenient to add ETAs in the simulation dataset
#'   to perform a simulation where no $THETA or $OMEGA information is necessary. In case inc_eta is TRUE, the ETAs
#'   from the ext files are used and placed in a matrix to take into account covariance or
#'   'BLOCKS'. A matrix from the ext file is constructed based on the naming of OMEGA values (e.g. OMEGA.2.1. will be
#'   added to row 2, column 1 and column 1, row 2). The matrix is used as Sigma for the mvrnorm function with mu=0.
#'
#' @seealso [MASS::mvrnorm]
#' @export
#' @return a dataframe with sampled values
#' @author Richard Hooijmaijers
#' @examples
#'
#' ext <- system.file("example_models","PK.1CMT.ORAL.COV.ext", package = "amp.sim")
#' cov <- system.file("example_models","PK.1CMT.ORAL.COV.cov", package = "amp.sim")
#' sample_par(ext, inc_eta = TRUE, nrepl = 5)
#' sample_par(ext, cov, uncert = TRUE, nrepl = 5)
#'
sample_par <- function(ext,covmat=NULL,bootstrap=NULL,seed=NULL,nrepl=10,inc_theta=TRUE,inc_eta=FALSE,verbose=FALSE,dropfixed=FALSE,uncert=FALSE,restheta=NULL){
  # set seed and read data (if applicable)
  if(!is.null(seed)){
    if(!exists(".Random.seed")) tmp <- stats::runif(1) # create new .Random.seed in case it is deleted
    oldseed <- .Random.seed
    on.exit({ .Random.seed <<- oldseed })
    set.seed(seed)
  }

  if(inherits(ext,"character"))    extf   <- utils::read.table(ext,skip=1,header=TRUE) else extf <- ext
  if(inherits(covmat,"character")) covmat <- try(utils::read.table(covmat,skip=1,header=TRUE))

  # sample from covariance matrix or bootstrap (for uncertainty only!)
  extf     <- extf[extf$ITERATION==-1e9,-c(1,ncol(extf))]
  if(uncert){
    if(is.null(bootstrap)){
      if(is.null(covmat)) return("In case of sampling with uncertainty, a covmat should be provided (or bootstrap location)")
      fixcov  <- names(covmat[,apply(covmat,2,function(x) all(x==0))])
      if(nrepl!=1)  sampl   <- data.frame(ID=1:nrepl,MASS::mvrnorm(n = nrepl,mu = unlist(extf),Sigma=covmat[,-1]))
      if(nrepl==1)  sampl   <- data.frame(ID=1:nrepl,as.list(MASS::mvrnorm(n = nrepl,mu = unlist(extf),Sigma=covmat[,-1])))
      for(i in fixcov) sampl[,i] <- extf[,i]
      if(dropfixed) sampl   <- sampl[,setdiff(names(sampl),fixcov)]
      #print(sampl)
    }else{
      if(is.null(bootstrap)) return("In case of sampling with uncertainty, a bootstrap location should be provided (or covmat)")
      bsres <- if(length(bootstrap)==1 && file.info(bootstrap)$isdir) list.files(bootstrap,pattern="\\.ext$",full.names=TRUE) else bootstrap
      bsres <- lapply(bsres,utils::read.table,skip=1,header=TRUE)
      bsres <- lapply(bsres,function(x) x[x$ITERATION==-1e9,])
      bsres <- do.call(rbind,bsres)

      if(nrow(bsres)>=nrepl){
        sampl <- bsres[sample(1:nrow(bsres),nrepl),]
      }else{
        sampl <- bsres[c(1:nrow(bsres),sample(1:nrow(bsres),nrepl-nrow(bsres),replace=TRUE)),]
      }
      sampl <- sampl[,!names(sample)%in%c("ITERATION","OBJ")] 
      sampl <- cbind(ID=1:nrepl,sampl)
    }
    if(!is.null(restheta)) sampl[,restheta] <- extf[,restheta]
  }else{
    sampl   <- cbind(ID=1:nrepl,extf[rep(1,nrepl),])
  }

  if(!inc_theta)  sampl <- sampl[,!grepl("THETA",names(sampl)),drop=FALSE]
  if(!verbose){
    sampl <- sampl[,!grepl("OMEGA",names(sampl)),drop=FALSE]
    sampl <- sampl[,!grepl("SIGMA",names(sampl)),drop=FALSE]
  }

  if(any(sampl<0)) warning("Negative values present, take into account when using results within model")

  names(sampl)[-1] <- paste0("S",names(sampl))[-1]

  if(inc_eta){
    ommat <- get_est(ext)
    etas  <- data.frame(ID=1:nrepl,MASS::mvrnorm(n=nrepl,mu=rep(0,length(ommat$ETA)),Sigma=ommat$OMEGA))
    if(nrepl==1) etas  <- data.frame(ID=1,t(data.frame(MASS::mvrnorm(n=nrepl,mu=rep(0,length(ommat$ETA)),Sigma=ommat$OMEGA))))
    names(etas)[-1] <- paste0("SETA",1:length(ommat$ETA))
    sampl <- merge(sampl,etas)
  }
  return(sampl)
}
