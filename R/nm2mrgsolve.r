#------------------------------------------ nm2mrgsolve ------------------------------------------
#' Convert NONMEM model to mrgsolve syntax
#'
#' This function converts a NONMEM model to syntax useable in mrgsolve simulations.
#'
#' @param lstblock structured list with information of the model that was read-in, usually obtained from the \code{\link{nmlistblock}} function
#' @param ext character with the name of the NONMEM ext file (if not provided estimates are read directly from control stream)
#' @param mod_return a character vector indicating which items should be returned from the model function (see \code{\link{convert_nonmem}} for more details)
#' @param out character with the name of the output file without a file extension
#'
#' @export
#' @return a list is returned inluding all building blocks to create a model
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   mdl <- readLines("run1.mod")
#'   bl  <- c("PROB","SUB","MODEL","PK","DES","PRED","THETA","OMEGA","ERROR","SIGMA","EST")
#'   lst <- get_nmblock(mdl,block=bl)
#'   lst <- nmlistblock(lst)
#'   nm2mrgsolve(lst)
#' }
nm2mrgsolve <- function(lstblock,ext=NULL,mod_return=NULL,out=NULL){
  # Define a translator function to rewrite specific parts for mrgsolve
  wrn <- msg <- ""
  translator     <- function(block){
    sapply(block,function(x){
      if(x$type=="comment"){
        rets <- paste0("//",x$comm)
      }else if(x$type=="empty"|x$type==""){
        rets <- ""
      }else{
        if(grepl("controlflow",x$type)){
          rets <- x$cntrl
          if(x$comm!="") rets <- paste0(rets,"//",x$comm)
        }else{
          if(grepl("A[[:digit:]]+$",x$LHS) & grepl("A\\([[:digit:]]+\\)$",trimws(x$RHS))){
            assign("msg",c("Assignment of compartment with same name (commented out)",msg),envir = parent.frame(n = 4))
            x$LHS <- paste0("//",x$LHS)
          } 
          if(grepl("A[[:digit:]]+$",x$LHS) & !grepl("A\\([[:digit:]]+\\)$",trimws(x$RHS))){
            assign("wrn",c("Assignment of compartment (commented out), check code to ensure this is correct",wrn),envir = parent.frame(n = 4))
            x$LHS <- paste0("//",x$LHS)
          }
          if(identical(trimws(x$LHS),gsub("\\(|\\)","",trimws(x$RHS)))) acomm <- "//" else acomm <- ""
          rets <- paste(acomm,x$LHS,"=",x$RHS)  
          #rets <- paste(x$LHS,"=",x$RHS)
          if(x$type=="init")  rets <- ""
          rets <- conv_pow(rets)
          rets <- paste(rets,";")
          if(x$comm!="") rets <- paste(rets,"//",x$comm)
          if(x$type=="control+formula") rets <- paste(x$cntrl,rets)
        }
        rets <- convert_nmsyntax(rets,type="mrgsolve")
      }
      rets
    })
  }
  params            <- get_param(lstblock,ext=ext,addparam = TRUE) # check if we want the addparam as argument (maybe always true?)
  sclpar            <- params$all_params[grepl("^S\\d+$",params$all_params)]
  adderr            <- ifelse(!"F"%in%params$all_params,"",ifelse(length(sclpar)>0,paste0("F = A(",sub("S","",sclpar[1]),")/",sclpar[1],";"),"F = A(1);"))
  
  retlst             <- list()
  retlst$modname     <- paste0(out,".cpp")
  retlst$problem     <- lstblock$PROB[[1]]$orig
  retlst$control2mod <- FALSE
  retlst$cmt         <- gsub(";.*","",unlist(lapply(lstblock$MODEL,"[[","orig")))
  if(any(grepl("^NCOMPARTMENTS=|^NCM=|^NCOMPS=",retlst$cmt))){
    retlst$cmt         <- retlst$cmt[grepl("^NCOMPARTMENTS=|^NCM=|^NCOMPS=",retlst$cmt)][1]
    retlst$cmt         <- paste(paste0("A",1:as.numeric(sub("^NCOMPARTMENTS=|^NCM=|^NCOMPS=","",retlst$cmt))),collapse=" ") 
  }else{
    retlst$cmt         <- unlist(regmatches(retlst$cmt,gregexpr("\\(.*?\\)",retlst$cmt)))
    retlst$cmt         <- paste(paste0("A",1:length(retlst$cmt)),collapse=" ") # Do not use names for CMTs
  }
  retlst$cmt         <- paste(c("$CMT",retlst$cmt),collapse="\n")
  retlst$pkblock     <- paste(c("$PK",translator(lstblock$PK)),collapse="\n")
  retlst$init        <- get_inits(lstblock)
  cinit              <- sub("tmp = ","",conv_pow(paste0("tmp = ",retlst$init))) # convert powers for initials
  retlst$init        <- paste(paste0("A_0(",gsub("A","",names(retlst$init)),") = ",cinit,";"),collapse="\n")
  retlst$desblock    <- paste(c("$DES",translator(lstblock$DES)),collapse="\n")
  retlst$predblock   <- paste(c("$PRED",translator(lstblock$PRED)),collapse="\n")
  retlst$errorblock  <- translator(lstblock$ERROR)
  retlst$errorblock  <- paste(c("$ERROR",adderr,retlst$errorblock),collapse="\n")
  retlst$param       <- paste(paste(names(params$params),"=",params$params),collapse=", ")
  retlst$randstruct  <- paste("$OMEGA @block",paste(params$omega_string, collapse="\n"),sep="\n") # we do not need annotations, so keep it as simple as possible
  retlst$sigmablock  <- paste("$SIGMA @block",paste(params$sigma_string, collapse="\n"),sep="\n")
  retlst$modtype     <- ifelse(retlst$desblock!="$DES\n","ode",ifelse(retlst$predblock!="$PRED\n","pred","other"))
  
  if(retlst$modtype=="pred")  {retlst$init <- retlst$pkblock <- retlst$cmt <- retlst$desblock <- retlst$errorblock <- ""}
  if(retlst$modtype=="other") {retlst$init <- retlst$cmt <- retlst$desblock <- retlst$predblock <- ""}
  if(retlst$modtype=="ode")   {retlst$predblock <- ""}
  if(!is.null(mod_return)) retlst$mdl_ret <- paste(c("$CAPTURE",mod_return),collapse=" ") else retlst$mdl_ret <- ""
  
  retlst$control  <- "library(mrgsolve)"
  retlst$control  <- c(retlst$control,paste0("mod <- mread(\"",out,".cpp\")"))
  retlst$control  <- c(retlst$control,params$theta_names)
  retlst$control  <- c(retlst$control,dput2(params$params,TRUE,"parm"))
  retlst$control  <- c(retlst$control,"# mod  <- param(mod,parm)","evnt <- ev(amt = 100, ii = 24, addl = 1)")
  retlst$control  <- c(retlst$control,"# To simulate single subject use zero_re(mod) in combination with nid=1")
  retlst$control  <- c(retlst$control,"out  <- mod %>% ev(evnt) %>% mrgsim(end = 48, delta = 0.1, nid=10)","plot(out)")
  retlst$wrn      <- unique(wrn[wrn!=""])
  retlst$msg      <- unique(msg[msg!=""])
  return(retlst)
}