#------------------------------------------ nm2rxode2 ------------------------------------------
#' Convert NONMEM model to rxode2 syntax
#'
#' This function converts a NONMEM model to syntax useable in rxode2 simulations
#'
#' @param lstblock structured list with information of the model that was read-in, usually obtained from the \code{\link{nmlistblock}} function
#' @param ext character with the name of the NONMEM ext file (if not provided estimates are read directly from control stream)
#' @param out character with the name of the output file without a file extension
#' @param control character with the type of control to bre returned (see \code{\link{convert_nonmem}} for more details)
#'
#' @export
#' @return a list is returned inluding all building blocks to create a model
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   mdl <- readLines("run1.mod")
#'   lst <- get_nmblock(mdl,block=c("PROB","SUB","MODEL","PK","DES","PRED","THETA","OMEGA","ERROR","SIGMA","EST"))
#'   lst <- nmlistblock(lst)
#'   nm2rxode2(lst)
#' }
nm2rxode2 <- function(lstblock,ext=NULL,out=NULL,control=""){ # ,mod_return=NULL
  # Define a translator function to rewrite specific parts for mrgsolve
  translator     <- function(block){
    sapply(block,function(x){
      if(x$type=="comment"){
        rets <- paste0("#",x$comm)
      }else if(x$type=="empty"|x$type==""){
        rets <- ""
      }else{
        if(grepl("controlflow",x$type)){
          rets <- x$cntrl
          if(x$comm!="") rets <- paste0(rets,"#",x$comm)
        }else{
          if(grepl("DADT\\(.*\\)",x$orig)) x$LHS <- sub("DADT\\(","d/dt(A",x$LHS)
          x$RHS <- par_delete(x$RHS)
          rets  <- paste(x$LHS,"=",x$RHS)
          if(x$type=="init")  rets <- ""
          rets <- paste(rets,";")
          if(x$comm!="") rets <- paste(rets,"#",x$comm)
          if(x$type=="control+formula") rets <- paste(x$cntrl,rets)
        }
        rets <- convert_nmsyntax(rets,type="rxode2")
      }
      rets
    })
  }
  params            <- get_param(lstblock,ext=ext,addparam = TRUE) # check if we want the addparam as argument (maybe always true?)
  sclpar            <- params$all_params[grepl("^S\\d+$",params$all_params)]
  adderr            <- ifelse(!"F"%in%params$all_params,"",ifelse(length(sclpar)>0,paste0("F = A",sub("S","",sclpar[1]),"/",sclpar[1],";"),"F = A1;"))

  retlst             <- list()
  retlst$modname     <- paste0(out,".r")
  retlst$problem     <- lstblock$PROB[[1]]$orig
  retlst$control2mod <- ifelse(control=="model",TRUE,FALSE)
  retlst$cmt         <- ""
  retlst$pkblock     <- paste(translator(lstblock$PK),collapse="\n")
  retlst$init        <- get_inits(lstblock)
  retlst$init        <- paste(paste0("  ",names(retlst$init),"(0) = ",retlst$init),collapse="\n")
  retlst$desblock    <- paste(paste0("  ",translator(lstblock$DES)),collapse="\n")
  retlst$predblock   <- paste(paste0("  ",translator(lstblock$PRED)),collapse="\n")
  retlst$errorblock  <- translator(lstblock$ERROR)
  retlst$errorblock  <- paste(paste0("  ",c(adderr,retlst$errorblock)),collapse="\n")
  retlst$modtype     <- ifelse(trimws(retlst$desblock)!="","ode",ifelse(trimws(retlst$predblock)!="","pred","other"))
  # These parts do not go into the model and can therefore be omitted (keep in list to return uniform list across packages)
  # (It seems that rxode2 always returns all outputs/variables created in the function)
  retlst$mdl_ret     <- retlst$sigmablock  <- retlst$randstruct <- retlst$param <- ""

  if(retlst$modtype=="pred")  {retlst$init <- retlst$pkblock <- retlst$cmt <- retlst$desblock <- retlst$errorblock <- ""}
  if(retlst$modtype=="other") {retlst$init <- retlst$cmt <- retlst$desblock <- retlst$predblock <- ""}
  if(retlst$modtype=="ode")   {retlst$predblock <- ""}

  retlst$control    <- c("library(rxode2)",paste0("source(\"",out,".r\")"))
  retlst$control    <- c(retlst$control, params$theta_names)
  retlst$control    <- c(retlst$control, dput2(params$params,FALSE,"parm","\n"))
  retlst$control    <- c(retlst$control, dput2(params$omega_matrix,FALSE,"ome","\n"))
  retlst$control    <- c(retlst$control, dput2(params$sigma_matrix,FALSE,"sigm","\n"))
  retlst$control    <- c(retlst$control, "evnt <- et(amt = 100, ii = 24, addl = 1)")
  retlst$control    <- c(retlst$control, "out  <- rxSolve(model,parm,evnt,omega=ome,sigma=sigm,nSub=10)","plot(out)")
  if(control=="model") retlst$control <- retlst$control[-1:-2]

  return(retlst)
}
