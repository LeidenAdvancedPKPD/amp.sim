#------------------------------------------ simdata ------------------------------------------
#' Create a simulation dataset for NONMEM simulation
#'
#' This function creates a simulation dataset including information
#'  for dosing and sampling. The function is setup to return a datframe
#'  to be used within NONMEM
#' @param time a vector with all sampling times to be used
#' @param dosetime a vector with the different dosing times
#' @param doseheight a vector with the different dosing heights (to be added to AMT)
#' @param addl a vector with the additional dose levels (must be same length as doseheight)
#' @param ii a vector with the interdose interval (must be same length as doseheight)
#' @param rate a vector with the dosing rate (must be same length as doseheight)
#' @param numid a vector with the number of IDs to be created
#'
#' @export
#' @return a dataframe that can be used for NONMEM simulations
#' @author Richard Hooijmaijers
#' @examples
#'
#' sim1 <- simdata(seq(0,24,1),0.5,100,10,12,NA,2)
#' sim2 <- simdata(seq(0,24,1),c(0.5,1),c(100,200),c(10,5),c(12,24),NA,2)
#' # Directly create a sequence of different dose levels
#' sim3 <- lapply(seq(25,60,5),function(x){
#'   simdata(time=1:12,dosetime=0,doseheight=x,addl=139,ii=120,rate=0,numid=10)
#' }) 
#' sim3 <- do.call(rbind,sim3)
simdata <- function(time,dosetime,doseheight,addl,ii,rate=NA,numid=5){
  dose     <- data.frame(TIME=dosetime,AMT=doseheight,ADDL=addl,II=ii,RATE=rate)
  obs      <- data.frame(TIME=time,DV=NA)
  out      <- plyr::rbind.fill(dose,obs)
  out$DOSE <- doseheight[1]
  out      <- out[rep(1:nrow(out),numid),]
  out$ID   <- rep(1:numid,each=nrow(out)/numid)
  #out      <- subset(out,,c(ID,DOSE,TIME,AMT,ADDL,II,RATE,DV))
  out      <- out[,c("ID", "DOSE", "TIME", "AMT", "ADDL", "II", "RATE", "DV")]
  out      <- out[order(out$ID,out$TIME),]
  if(all(is.na(out$RATE))) out <- dplyr::select(out, !dplyr::all_of("RATE"))  
  return(out)
}
