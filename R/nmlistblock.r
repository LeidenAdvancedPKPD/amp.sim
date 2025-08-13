#------------------------------------------ nmlistblock ------------------------------------------
#' convert a block to a list
#'
#' This function will convert a NONMEM block to a list including the type and separate formula parts
#'
#' @param dollmodel list with each item being a separate dollor block, usually obtain from \code{\link{get_nmblock}}
#'
#' @export
#' @return a list with the structured code
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{nmlistblock(dollmodel)}
nmlistblock <- function(dollmodel){
  finret <- lapply(1:length(dollmodel),function(blck){
    if(length(dollmodel[[blck]])==0){
      ret <- list(list(orig="",type="",LHS="",RHS="",comm="",cntrl="",dupl=FALSE))
    }else if(names(dollmodel)[blck]=="EST"){
      ret <- list(list(orig=paste(dollmodel[[blck]],collapse=" "),type="",LHS="",RHS="",comm="",cntrl="",dupl=FALSE))
    }else{
      ret  <- lapply(dollmodel[[blck]],function(x){
        type <- ""
        xnc  <- sub(";.*","",x) # strip comments for accurate obtaining type of line
        if(grepl("=",xnc)) type <- "formula"
        if(grepl("IF\\(|IF[[:blank:]]*\\(|ENDIF|ELSE IF|ELSE$|END IF$",xnc)) type <- "controlflow"
        if(grepl("IF\\(|IF[[:blank:]]*\\(",xnc) & grepl("=",xnc)) type <- "control+formula"
        if(grepl("A_0\\([[:digit:]]*\\)",xnc)) type <- "init"
        if(grepl("^;",trimws(x))) type <- "comment"
        if(trimws(x)=="")  type <- "empty"
        comm  <- strsplit(x,";")[[1]]
        comm  <- ifelse(length(comm)>1,paste(comm[2:length(comm)],collapse=";"),"")
        cntrl <- ""
        if(type=="controlflow")     cntrl <- gsub(";.*","",x)
        if(type=="control+formula"){
          cntrl <- gsub("=.*","",xnc)
          cntrl <- sub("\\)([^\\)]*)$",")",cntrl)
        }
        if(type%in%c("formula","control+formula","init")){
          LHS   <- gsub("=.*","",xnc)
          LHS   <- gsub("IF.*\\(.*\\)","",LHS)
          LHS   <- trimws(LHS)
          RHS   <- gsub(".*=","",xnc)
          RHS   <- gsub("ERR(\\([[:digit:]]*\\))","EPS\\1",RHS) # Make sure residual is always coded as EPS
        }else{
          LHS <- RHS <- ""
        }
        if(type=="") type <- "comment"
        return(list(orig=x,type=type,LHS=LHS,RHS=RHS,comm=comm,cntrl=cntrl,dupl=FALSE))
      })
      retd <- duplicated(sapply(ret,"[[","LHS"))
      ret <- lapply(1:length(ret), function(x){
        cur      <- ret[[x]]
        cur$dupl <- retd[x]
        cur
      })
    }
    return(ret)
  })
  names(finret) <- names(dollmodel)
  return(finret)
}
