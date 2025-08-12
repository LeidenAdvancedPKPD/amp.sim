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
#' @details In general the data can be a character string defining the input dataset (as csv file!) or a dataframe
#'  it is proposed to use a dataframe as in many cases the splitting should take place for a large problem. In case
#'  a dataframe is used (e.g. from loading an Rdata object)  it is not necessary to import a huge csv file.
#'
#' @export
#' @return split CSV and models files are written to disk
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   split_sim(sim.input,"run1.mod",".")
#' }
split_sim <- function(data,model,locout,splitby="ID",numout=4){

  # Split the input data
  if(!inherits(data,"data.frame")){
    inp           <- utils::read.csv(data,stringsAsFactors = FALSE, na.strings = ".")
    names(inp)[1] <- sub("^X\\.","",names(inp)[1]) # In case a comment char is used #
  }else{
    inp <- data
  }
  inps          <- split(inp,cut_equal(inp[,splitby],numout))
  noret         <- lapply(1:length(inps),function(x){
    utils::write.csv(inps[[x]],paste0(locout,"/",sub("\\.csv$","",basename(data)),".",x,".csv"),row.names=FALSE,quote=FALSE,na=".")
  })

  # Split the simulation model
  mdl       <- readLines(model)
  doll      <- setdiff(c(grep("\\$",mdl),length(mdl)+1),grep(";.*\\$",mdl))
  ddat      <- unlist(lapply(setdiff(grep("\\$DATA",mdl),grep(";.*\\$DATA",mdl)),function(x) x:(min(doll[doll>x]-1))))
  mdl[ddat] <- paste(";",mdl[ddat])
  noret     <- lapply(1:numout,function(x){
    out <- append(mdl,paste("$DATA",paste0(sub("\\.csv$","",basename(data)),".",x,".csv"),"IGNORE=@"),ddat[1]-1)
    writeLines(out,paste0(locout,"/",sub("\\.mod$","",basename(model)),".",x,".mod"))
  })
}
