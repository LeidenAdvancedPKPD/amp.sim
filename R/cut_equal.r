#------------------------------------------ cut_equal ------------------------------------------
#' cut function for (appr.) equal intervals
#'
#' This function uses cut to make categories based on approximately equal number of bins
#'
#' @param x the vector that should be cut into equal bins
#' @param n the number of bins that should be used
#' @param type the type of algorithm to be used (see details)
#' @param ntries number of samples/tries for type 2
#'
#' @details Generating equal bins can be quite difficult. There are multiple ways of
#'   assessing if bins are equal. This function provides a method based on quantiles
#'   (type=1) or a method based on sampling proposed by M. Ruppert (type=2). In general
#'   type 1 is faster but less accurate, while type 2 is slower and more accurate
#'   (in case of a reasonable ntries)
#'
#' @export
#' @return  a character vector with the categories/bins
#' @author Richard Hooijmaijers
#' @examples
#'
#'  table(cut_equal(1:101,5))
cut_equal <- function(x,n,type=1,ntries=1000){
  if(type==1){
    brk <- 1
    x2  <- as.numeric(as.factor(x))
    qnt <- quantile(x2,probs=seq(0,1,length.out = brk))
    while(length(unique(qnt)) < (n+1)){
      qnt <- quantile(x2,probs=seq(0,1,length.out = brk))
      brk <- brk+1
    }
    ret   <- as.character(cut(x2,unique(qnt),include.lowest = TRUE,right=FALSE))
    reval <- sapply(unique(ret),function(re) paste(unique(x[which(ret==re)]),collapse="+"))
    return(plyr::revalue(ret,reval))
  }else if(type==2){
    uniques <- length(unique(x))
    n       <- min(n, uniques)
    tv      <- table(x)

    m <- t(replicate(ntries, sample(1 : n, min(n, uniques), replace = FALSE)))
    if (uniques - n > 0) m <- cbind(m, matrix(replicate( ntries, sample(replace = TRUE, 1 : n, max(0, uniques - n))), nrow = ntries))
    colnames(m) <- names(tv)

    counts  <- apply(m, 1, function(r) sapply(1 : n, function(i) sum(tv[which(r == i)])))
    score   <- apply(counts, 2, var)
    best    <- which.min(score)
    assignm <- m[best,  ]

    NAMES <- sapply(1 : n, function(i) paste(names(which(assignm == i)), collapse = "+"))
    return(NAMES[assignm[x]])
  }
}
