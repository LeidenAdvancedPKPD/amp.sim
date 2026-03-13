#------------------------------------------ split_sim ------------------------------------------
#' Split a large NONMEM simulation in chunks
#'
#' This function splits a large simulation dataset and accompanying model in chunks
#'  to prevent memory problems within the simulation or to enable simulating over multiple cores
#'
#' @param data character string for input dataset or a dataframe with the simulation data (see details)
#' @param model character string for the simulation model
#' @param locout character string for the location of the split input dataset and models
#' @param splitby character string with the variable in the data to be split on (if this is not ID it could lead to unexpected results)
#' @param numout the number of 'equal length' outputs to be created.
#'
#' @details In general the data can be a character string defining the input dataset (csv file) or a dataframe
#'  it is proposed to use a dataframe as in many cases the splitting should take place for a large problem. In case
#'  a dataframe is used (e.g. from loading an Rdata object)  it is not necessary to import a huge csv file.
#'
#' @export
#' @return split CSV and models files are written to disk
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
#' 
#' split_sim(data = tmp_out, model = mod_out, locout=tempdir())
#' list.files(tempdir(), pattern="\\.mod$")
#' 
split_sim <- function(data,model,locout,splitby="ID",numout=4){

  # Split the input data
  if(!inherits(data,"data.frame")){
    inp           <- utils::read.csv(data,stringsAsFactors = FALSE, na.strings = ".")
    names(inp)[1] <- sub("^X\\.","",names(inp)[1]) # In case a comment char is used #
    nam <- sub("\\.csv$","",basename(data))
  }else{
    inp <- data
    nam <- deparse(substitute(data))
  }
  inps          <- split(inp,cut_equal(inp[,splitby],numout))
  noret         <- lapply(1:length(inps),function(x){
    utils::write.csv(inps[[x]],paste0(locout,"/",nam,".",x,".csv"),row.names=FALSE,quote=FALSE,na=".")
  })

  # Split the simulation model
  mdl       <- readLines(model)
  doll      <- setdiff(c(grep("\\$",mdl),length(mdl)+1),grep(";.*\\$",mdl))
  ddat      <- unlist(lapply(setdiff(grep("\\$DATA",mdl),grep(";.*\\$DATA",mdl)),function(x) x:(min(doll[doll>x]-1))))
  mdl[ddat] <- paste(";",mdl[ddat])
  noret     <- lapply(1:numout,function(x){
    out <- append(mdl,paste("$DATA",paste0(nam,".",x,".csv"),"IGNORE=@"),ddat[1]-1)
    writeLines(out,paste0(locout,"/",sub("\\.mod$","",basename(model)),".",x,".mod"))
  })
}
