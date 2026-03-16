#------------------------------------------ make_nmsimmodel ------------------------------------------
#' Create a simulation model from original model
#'
#' This function creates a simulation model from an original NONMEM model where dollar blocks are replaced and/or
#'  commented based on input file and other simulation functions within package
#'
#' @param omod character string for the original model
#' @param smod character string for the simulation model (for writing the model to disk)
#' @param data character string for the input dataset for the simulation
#' @param subprobs numeric indicating the number of subproblems in simulation model
#' @param table character of length 1 with the items for the dollar table block (if null it will use items in input dataset)
#' @param sigma_ext character with the name of the ext file which includes the sigma value (in case residual error is coded in the dollar sigma block)
#'
#' @details The function will adapt an original model in such a way that it can be used directly for simulations
#'   the assumptions are that an input dataset is created using [sample_par] and [simdata].
#'   This means that all THETA and ETA values are available in the simulation dataset as respectively STHETAN and SETAN (simulated THETA/ETA n).
#'   Furthermore it is assumed that the input dataset is a csv file.
#'   The function will first comment all applicable dollar blocks. Then a OMEGA is added with 0 FIX and the INPUT, DATA and
#'   TABLE blocks are appended with information based on the input dataset. Finally all THETAs and ETAs are replaced with
#'   the items in the dataset and the simulation model is written to  disk.
#'
#' @export
#' @return a simulation model (file) is created
#' @author Richard Hooijmaijers
#' @examples
#'
#' nmmod   <- system.file("example_models","PK.1CMT.ORAL.mod", package = "amp.sim")
#' dat     <- simdata(0:24, dosetime = 0, doseheight = 10, addl = 2, ii = 24, 
#'                    numid = 50, STHETA1= 1, STHETA2 = 2, STHETA3 = 1,
#'                    SETA1 = 0, SETA2 = 0)
#' tmp_out <- tempfile(fileext = ".csv")
#' mod_out <- tempfile(fileext = ".mod")
#' 
#' write.csv(dat,file=tmp_out, na=".", quote=FALSE, row.names = FALSE)
#' make_nmsimmodel(nmmod, mod_out, data=tmp_out)
#' readLines(mod_out) |> head(n=15) |> cat(sep="\n")
#' 
make_nmsimmodel <- function(omod,smod,data,subprobs=1,table=NULL,sigma_ext=NULL){

  # get model and indices of dollar blocks
  omod  <- readLines(omod)
  dblck <- get_nmblock(omod,c("INPUT","DATA","THETA","OMEGA","EST","COV","TABLE","SIGMA"),ret="index")

  # comment dollar blocks
  out   <- omod
  out[unname(unlist(dblck[names(dblck)!="SIGMA"]))] <- paste(";",out[unname(unlist(dblck[names(dblck)!="SIGMA"]))])
  if(!is.null(sigma_ext)) out[dblck$SIGMA] <- paste(";",out[dblck$SIGMA])
  out   <- append(out,"$OMEGA 0 FIX",dblck$OMEGA[1]-1)

  # correct $INPUT, $DATA and $TABLE
  dnames <- utils::read.csv(data,header=FALSE,nrow=1,stringsAsFactors = FALSE)
  out    <- append(out,paste("$INPUT\n",sub("#","",paste(dnames,collapse=" "))),dblck$INPUT[1]-1)
  out    <- append(out,paste("$DATA",basename(data),"IGNORE=@"),dblck$INPUT[1]-1)
  out    <- append(out,paste0("$SIM (123) SUBPROBLEMS=",subprobs," ONLYSIM"),length(out))
  tbln   <- ifelse(!is.null(table),table,sub("#","",paste(dnames,collapse=" ")))
  out    <- append(out,paste("$TABLE\n",tbln,"\nNOPRINT NOAPPEND FILE=par"),length(out))

  # replace THETA/ETA with simulated ones in input and write model
  thnum  <- as.numeric(sub("STHETA","",dnames[grep("STHETA",dnames)]))
  etnum  <- as.numeric(sub("SETA","",dnames[grep("SETA",dnames)]))
  for(i in thnum) out <- gsub(paste0("THETA\\(",i,"\\)"),paste0("STHETA",i),out)
  for(i in etnum) out <- gsub(paste0("ETA\\(",i,"\\)"),paste0("SETA",i),out)

  # Adapt sigma if indicated
  if(!is.null(sigma_ext)){
    ext  <- utils::read.table(sigma_ext,skip=1,header=TRUE)
    ext  <- ext[ext$ITERATION==-1000000000,grep("SIGMA",names(ext)),drop=FALSE]
    out  <- append(out,paste0("$SIGMA\n",paste(unlist(ext),collapse="\n")),grep("\\$SIGMA",out)[1])
  }
  message("Check residual error; in case coded as sigma use 'sigma_ext' otherwise check if the correct THETA is used icw uncertainty")
  writeLines(out,smod)
}
