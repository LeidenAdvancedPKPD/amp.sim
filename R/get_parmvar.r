#------------------------------------------ get_parmvar ------------------------------------------
#' Get the variables within a NONMEM model that should be passed to the simulation model
#'
#' This function go through all formulas and control flows to check if a parameter is created ad-hoc
#' or taken from the input file. This is important as these variables need to be set for simulation
#'
#' @param lstblock list with each item being a separate strucured dollor block, usually obtain from \code{\link{nmlistblock}}
#' @param returnall logical indicating if all variables should be returned or just the ones that are not defined
#'
#' @export
#' @return a vector with model variables for the simulation model
#' @author Richard Hooijmaijers
#' @examples
#'
#' mod    <- system.file("example_models","PK.1CMT.ORAL.COV.mod", package = "amp.sim")
#' mdll   <- get_nmblock(mod,block=c("PK","DES"))
#' mdlls  <- nmlistblock(mdll)
#' get_parmvar(mdlls)
#' 
get_parmvar <- function(lstblock,returnall=FALSE){
  alllst   <- c(lstblock$PK,lstblock$DES,lstblock$ERROR,lstblock$PRED)
  if(is.null(alllst)) stop("There is no PK, DES, PRED or error block in the provided model")
  allvars   <- lapply(alllst,function(x){if(x$type%in%c("formula","control+formula","controlflow","init")) return(x)})
  allvars   <- allvars[!sapply(allvars,is.null)]
  addvars   <- vector("character") # return vector with variables to be added
  noaddvars <- vector("character") # temp vector to check if variable should be added
  for(i in 1:length(allvars)){
    if(allvars[[i]]$type=="controlflow"){
      # if(!grepl("ELSE|END IF|ENDIF",allvars[[i]]$cntrl))  rhsvars <- all.vars(parse(text=paste(gsub(".*if","if",convert_nmsyntax(allvars[[i]]$cntrl)),"}")))
      # The preceding line has issues in case if is also in the name (e.g. IF(CMedif.GT.0)), because a controlflow always start with if we do not need the gsub
      if(!grepl("ELSE|END IF|ENDIF",allvars[[i]]$cntrl))  rhsvars <- all.vars(parse(text=paste(convert_nmsyntax(allvars[[i]]$cntrl),"}")))
    }else if(allvars[[i]]$type=="control+formula"){
      rhsvars  <- c(all.vars(parse(text=allvars[[i]]$RHS)),all.vars(parse(text=paste(convert_nmsyntax(allvars[[i]]$cntrl),"{}"))))
    }else{
      rhsvars   <- all.vars(parse(text=convert_nmsyntax(allvars[[i]]$RHS)))
    }
    # LHS variables are never obtained from data but logically always assigned
    noaddvars <- unique(c(noaddvars,allvars[[i]]$LHS))
    if(length(rhsvars)>0){
      for(j in rhsvars){
        if(j%in%noaddvars)  noaddvars <- unique(c(noaddvars,j))
        if(!j%in%noaddvars) addvars   <- unique(c(addvars,j))
      }
    }
  }
  if(!returnall)  return(addvars[addvars!='']) else return(c(addvars,noaddvars)[c(addvars,noaddvars)!=''])
}
