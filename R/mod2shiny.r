#------------------------------------------ mod2shiny ------------------------------------------
#' Creates a basic simulation app for a given R model
#'
#' This function fills in a default template for simulations within shiny
#'
#' @param parvector named vector with the model parameters, should contain all parameters used by the model
#' @param modfile A script with the model defined in it, it is ssumed that this file is created using \code{\link[amp.sim]{convert_nonmem}}
#' @param evnt dataframe with the events used by the model (this is saved as rds together with the app)
#' @param init vector with the compartment initialization (only applicable for deSolve framework)
#' @param naming named vector with the names in parvector and the new values to use within the shiny app
#' @param apptitle string with the title to be used for the app
#' @param outloc character with location where the resulting shiny app should be saved
#' @param omega vector with the omega matrix for the model (only applicable for rxode2 framework)
#' @param sigma vector with the sigma matrix for the model (only applicable for rxode2 framework)
#' @param delloc logical indicating if the location should be deleted first
#' @param framework character indicating the simulation framework that was used, currently "deSolve", "rxode2", "nonmem2rx" and "mrgsolve" are supported
#' @param logo  character with a png of the company logo added in the header of the shiny app
#' @param times  character vector with the times to simulate or set to NULL to use a default time vector
#'
#' @details This function creates a default shiny app that can be used as a starting point for further
#'   development. There are already some basic features available but it is intended to be adapted when used 
#'   for production. For the automatic creation of an app it is assumed that the model is created using the [convert_nonmem]
#'   function. Although it is not strictly necesary, the information provided to this function will be in the correct format
#'   when this function is used. Some of the arguments in this function are only necessary in case a certain conversion framework
#'   is used. In general a single subject is simulated, but be aware that for the DeSolve and rxode2 framework OMEGA/ETA is implemented.
#'
#' @export
#' @return creates necessary app files for a shiny simulation app
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{mod2shiny(parvector=c(KA=0.1,K20=0.3),modfile='model.r',evnt=evdat)}
mod2shiny <- function(parvector,modfile,evnt,init=NULL,naming=NULL,apptitle="Shiny app title",outloc=".",omega=NULL,sigma=NULL,
                      delloc=FALSE,framework="deSolve",logo=paste0(system.file(package="amp.sim"),"/logo.png"),times=NULL){
  
  if(framework=="nonmem2rx") framework="rxode2" # nonmem2rx can be handled in the same way as rxode2
  if(framework=="deSolve" && is.null(init)) stop("Provide 'init' when the deSolve framework is used")
  if(framework=="rxode2" && (is.null(omega) | is.null(sigma))) stop("Provide 'omega' and 'sigma' when the rxode2 framework is used")
  if(delloc) try(unlink(outloc,recursive=TRUE))
  # Fill in ui template
  parvector2 <- parvector
  if(!is.null(naming)){
    if(any(names(naming)%in%names(parvector))) names(parvector2)[names(parvector)%in%names(naming)] <- naming
  }
  uiIn    <- readLines(paste0(system.file(package="amp.sim"),"/ui.tmpl"))
  #inpe    <- paste0("numericInput(inputId = '",names(parvector),"', label='",names(parvector),":', value=",round(parvector,2),")")
  inpe    <- paste0("numericInput(inputId = '",names(parvector),"', label='",names(parvector2),":', value=",signif(parvector,3),")")
  sourcef <- ifelse(framework=="mrgsolve",paste0("assign('model',mread('etc/",basename(modfile),"'),envir = .GlobalEnv)"),paste0("source('etc/",basename(modfile),"')"))
  uilist  <- list(apptitle=apptitle,inputElements=paste(inpe,collapse=",\n        "),sourcefunc=sourcef,packages=paste0("library(",framework,")"))
  uiOut   <- whisker::whisker.render(uiIn, uilist)
  
  # Fill in server template - decided to place in the entire parm output including changes for input elements
  serverIn   <- readLines(paste0(system.file(package="amp.sim"),"/server.tmpl"))
  parserv1   <- paste0("parm <- c(",paste(paste(names(parvector),"=",round(parvector,2)),collapse=", "),")")
  parserv2   <- paste(paste0("    parm['",names(parvector),"'] <- input$",names(parvector)),collapse="\n")
  parserv    <- paste(parserv1,parserv2,sep="\n")
  usede      <- ifelse(framework=="deSolve",TRUE,FALSE)
  userxode2  <- ifelse(framework=="rxode2",TRUE,FALSE)
  if(is.null(times)){
    times  <- "times <- seq(0,max(events$time)+24,length.out=1000)"
    if("addl"%in%names(evnt)) times <- "times <- seq(0,max(events$time) + ((max(events$addl)+1)*max(events$ii)) ,length.out=1000)"
  }else{
    times <- dput2(times,obj="times",collapse="")
  }
  if(!is.null(init))   initcode   <- dput2(init,obj="inits",collapse="")  else initcode <- ""
  if(!is.null(omega))  omegacode  <- dput2(omega,obj="omega",collapse="") else omegacode <- ""
  if(!is.null(sigma))  sigmacode  <- dput2(sigma,obj="sigma",collapse="") else sigmacode <- ""
  if(framework=="deSolve")  simcode <- "out <- as.data.frame(lsoda(inits,times,model, parm,events=list(data=events)))"
  if(framework=="mrgsolve") simcode <- "model <- param(model,parm)\nout  <- zero_re(model) %>% ev(events) %>% mrgsim(tgrid=times)"
  if(framework=="rxode2")   simcode <- "out   <- rxSolve(model,parm,events,omega=omega,sigma=sigma,nSub=1)"
  #simcode    <- paste(simcode,"out  <- tidyr::pivot_longer(out,cols=!contains('time'))",sep="\n")
  simcode    <- paste(simcode,"out  <- tidyr::pivot_longer(as.data.frame(out),cols=!contains(c('time','ID')))",sep="\n")
  servlist   <- list(changeParm=parserv,usedesolve=usede,initcode=initcode,simcode=simcode,timesv=times,
                     userxode2=userxode2,omegacode=omegacode,sigmacode=sigmacode)
  #print(servlist)
  serverOut  <- whisker::whisker.render(serverIn, servlist)
  
  # Make folders and write files
  dir.create(paste0(outloc,"/etc"),recursive = TRUE, showWarnings = FALSE)
  dir.create(paste0(outloc,"/www"),recursive = TRUE, showWarnings = FALSE)
  saveRDS(evnt,paste0(outloc,"/etc/events.rds"))
  writeLines(uiOut,paste0(outloc,"/ui.r"))
  writeLines(serverOut,paste0(outloc,"/server.r"))
  file.copy(logo,paste0(outloc,"/www/logo.png"))
  file.copy(paste0(system.file(package="amp.sim"),"/modelscheme.png"),paste0(outloc,"/www/modelscheme.png"))
  file.copy(modfile,paste0(outloc,"/etc/",basename(modfile)))
  cat(paste0("Shiny app created in location '",outloc,"'. It can be submitted using:\n",cli::style_bold("shiny::runApp('",outloc,"',launch.browser=TRUE)")))
}
