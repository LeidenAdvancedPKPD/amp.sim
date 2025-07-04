#------------------------------------------ nm2deSolve ------------------------------------------
#' Convert NONMEM model to deSolve syntax
#'
#' This function converts a NONMEM model to syntax useable in deSolve simulations
#'
#' @param lstblock structured list with information of the model that was read-in, usually obtained from the \code{\link{nmnmlistblock}} function
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
#'   lst <- listblock(lst)
#'   nm2deSolve(lst)
#' }
nm2deSolve <- function(lstblock,ext=NULL,mod_return=NULL,out=NULL,control=""){ # ,mod_return=NULL
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
          #if(grepl("DADT\\(.*\\)",x$orig)) x$LHS <- sub("DADT\\(","d/dt(A",x$LHS)
          #x$RHS <- par_delete(x$RHS)
          rets  <- paste(x$LHS,"=",x$RHS)
          rets <- gsub("="," <- ",rets)
          if(x$type=="init")  rets <- ""
          if(x$comm!="") rets <- paste(rets,"#",x$comm)
          if(x$type=="control+formula") rets <- paste(x$cntrl,rets)
          rets <- par_delete(rets)
        }
        rets <- convert_nmsyntax(rets,type="deSolve")
      }
      rets
    })
  }

  params            <- get_param(lstblock,ext=ext,addparam = TRUE) # check if we want the addparam as argument (maybe always true?)
  sclpar            <- params$all_params[grepl("^S\\d+$",params$all_params)]
  adderr            <- ifelse(!"F"%in%params$all_params,"",ifelse(length(sclpar)>0,paste0("F = A",sub("S","",sclpar[1]),"/",sclpar[1],";"),"F = A1;"))

  retlst             <- list()
  retlst$problem     <- lstblock$PROB[[1]]$orig
  retlst$pkblock     <- paste(paste0("    ",translator(lstblock$PK)),collapse="\n")
  retlst$desblock    <- paste(paste0("    ",translator(lstblock$DES)),collapse="\n")
  retlst$predblock   <- paste(paste0("    ",translator(lstblock$PRED)),collapse="\n")
  retlst$param       <- c(params$params,setNames(rep(0,nrow(params$omega_matrix)),paste0("ETA",1:nrow(params$omega_matrix))))
  retlst$init        <- get_inits(lstblock)
  # inits are defined outside model function, meaning that some values are not available in parameter vector. Try to obtain it by evaluating the PK block
  tempenv  <- new.env()
  list2env(as.list(retlst$param), envir = tempenv)
  parsedpk <- try(eval(parse(text=retlst$pkblock),envir = tempenv))
  if("try-error"%in%class(parsedpk)){
    warning("could not parse for retrieval of intial values, check intials before simulating")
  }else{
    for(i in 1:length(retlst$init)) if(is.na(suppressWarnings(as.numeric(retlst$init[i])))) try(retlst$init[i] <- get(retlst$init[i],envir = tempenv))
  }
  retlst$init        <- setNames(as.numeric(retlst$init),names(retlst$init))
  retlst$modname     <- paste0(out,".r")
  retlst$control2mod <- ifelse(control=="model",TRUE,FALSE)
  retlst$mdl_ret     <- paste0("c(",paste0("DADT",1:sum(grepl("DADT[[:digit:]]",translator(lstblock$DES))),collapse=","),")")
  if(!is.null(mod_return)) retlst$mdl_ret <- paste0("    list(",retlst$mdl_ret,",c(",paste(mod_return,mod_return,sep="=",collapse=", "),"))")
  if(is.null(mod_return))  retlst$mdl_ret <- paste0("    list(",retlst$mdl_ret,")")
  retlst$modtype     <- ifelse(trimws(retlst$desblock)!="","ode",ifelse(trimws(retlst$predblock)!="","pred","other"))
  # These parts do not go into the model and can therefore be omitted (keep in list to return uniform list across packages)
  retlst$errorblock  <- retlst$cmt <- retlst$randstruct <- retlst$sigmablock <- ""

  retlst$control <- ifelse(retlst$modtype=="ode","","# MODEL IS NOT DEFINED AS ODE TAKE INTO ACCOUNT THAT THE MODEL AND CONTROL FILE NEED EXTENSIVE ADAPTATIONS TO MAKE IT WORK!")
  retlst$control <- c(retlst$control,"library(deSolve)","library(ggplot2)",paste0("source(\"",out,".r\")"))
  retlst$control <- c(retlst$control, params$theta_names)
  retlst$control <- c(retlst$control, dput2(retlst$param,FALSE,"parm","\n"))
  retlst$control <- c(retlst$control, dput2(retlst$init,FALSE,"init","\n"))
  retlst$control <- c(retlst$control, "times <- seq(0,48,.1)")
  retlst$control <- c(retlst$control,"evnt <- pmxsimtools::dose_func(cmt=1,value=100,tau=24,ndose=2)")
  retlst$control <- c(retlst$control,"out  <- data.frame(deSolve::lsoda(init,times,model,parm,events=list(data=evnt)))")
  retlst$control <- c(retlst$control,"out  <- tidyr::pivot_longer(out,cols=!contains(\"time\"))")
  retlst$control <- c(retlst$control,"ggplot(out,aes(time,value)) + geom_line() + facet_wrap(\"name\",scales=\"free\")")
  if(control=="model") retlst$control <- retlst$control[-c(2,4)]

  return(retlst)
}
