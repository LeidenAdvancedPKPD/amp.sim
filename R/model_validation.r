#------------------------------------------ model_validation ------------------------------------------
#' Validates NONMEM estimation model with an mrgsolve simulation model
#'
#' This function uses the estimates from a NONMEM run and compares this with the results of a simulation
#' run. This function is inspired by a blog post from mrgsolve and mainly looks at the differences in population predictions
#'
#' @param nmtable either a character with a file or a data frame including the NONMEM table output
#' @param simmodel character with the file including the mrgsolve model
#' @param rounding numeric with the rounding applied for comparing
#' @param comppred character with the variable in mrgsolve model that should be compared with PRED variable in NONMEM
#' @param out character with the name of the output to create
#' @param ... additional arguments passed through to \code{mrgsim} function
#'
#' @details For a correct comparison, the nmtable should include all variables related to dosing (e.g. AMT/CMT/EVID).
#'   The simulation model should be available as a separate file that can be read in using \code{mrgsolve::mread}.
#'   To use the function, the packages \code{R3port}, \code{ggplot2}, \code{mrgsolve} and \code{dplyr} should be installed.
#'   Be aware that no variables are renamed in $TABLE in the NONMEM control stream (e.g. AMT2=AMT). This can have unexpected results when comparing.
#'
#' @export
#' @return a file with a PDF report is returned
#' @author Richard Hooijmaijers
#' @examples
#'
#' \dontrun{
#'   model_validation("run1.par","run1.cpp")
#' }
model_validation <- function(nmtable,simmodel,rounding=4,comppred="CP",out="validate/result.tex",...){

  if(length(find.package("ggplot2", quiet = TRUE))==0) stop("the ggplot2 package should be installed to use this function")
  if(length(find.package("R3port", quiet = TRUE))==0) stop("the R3port package should be installed to use this function")
  if(length(find.package("mrgsolve", quiet = TRUE))==0) stop("the mrgsolve package should be installed to use this function")
  if(length(find.package("dplyr", quiet = TRUE))==0) stop("the dplyr package should be installed to use this function")

  # read in nonmem table file
  if(inherits(nmtable,"data.frame")){
    parf <- nmtable
  }else{
    parf <- try(utils::read.table(nmtable,header=TRUE,comment.char = "",skip=1))
    if("try-error"%in%class(parf)) stop("Could not read in NONMEM table file")
  }
  if(!all(c("PRED","ID","TIME","AMT")%in%names(parf))) stop("The variables 'PRED', 'TIME', 'ID' and 'AMT' should at least be available for comparison")

  # read in model and simulate
  mod    <- try(mrgsolve::mread(simmodel))
  if("try-error"%in%class(mod)) stop("Could not read in mrgsolve model")
  simres <- try(mrgsolve::mrgsim_df(mrgsolve::zero_re(mod), data=parf, carry_out = "PRED", digits = rounding,...))
  if("try-error"%in%class(simres)) stop("Could not simulate mrgsolve model")
  if(!comppred%in%names(simres))   stop("Selected comppred is not available in model output, make sure it is captured in mrgsolve model")

  simres$diff    <- round(simres[,comppred],rounding) - round(simres$PRED,rounding)
  simres$reldiff <- 100 * (round(simres[,comppred],rounding) - round(simres$PRED,rounding))/round(simres$PRED,rounding)

  # Create results and write to report if applicable
  simrest1 <- dplyr::rename(simres,"value"="diff") |> dplyr::mutate(variable="Absolute difference") |> dplyr::select(!dplyr::all_of("reldiff"))
  simrest2 <- dplyr::rename(simres,"value"="reldiff") |> dplyr::mutate(variable="Relative difference (%)") |> dplyr::select(!dplyr::all_of("diff"))
  simrest  <- rbind(simrest1,simrest2)
  sumtbl   <- dplyr::summarise(dplyr::group_by(simrest,dplyr::across(dplyr::all_of("variable"))), n = dplyr::n(), min=min(.data$value,na.rm=TRUE),
                               p5=stats::quantile(.data$value,0.05,na.rm=TRUE), median=stats::median(.data$value,na.rm=TRUE),
                               p9=stats::quantile(.data$value,0.95,na.rm=TRUE), max=max(.data$value,na.rm=TRUE),
                               mean=mean(.data$value,na.rm=TRUE), sd=stats::sd(.data$value,na.rm=TRUE))

  top10            <- simres[!is.na(simres$reldiff) & simres$reldiff!=0,]
  top10$absreldiff <- formatC(abs(top10$reldiff),2,format="fg",flag="#")
  top10$reldiff    <- formatC(top10$reldiff,2,format="fg",flag="#")
  top10$diff       <- formatC(top10$diff,2,format="fg",flag="#")

  pl1 <- ggplot2::ggplot(simres,ggplot2::aes(.data[["PRED"]],.data[[comppred]])) + ggplot2::geom_point(alpha=.2) + ggplot2::geom_abline(slope=1,intercept = 0) +
    ggplot2::labs(x="Results estimation",y="Results simulation") + ggplot2::theme_bw(base_size = 9)
  pl2a <- ggplot2::ggplot(simres,ggplot2::aes(.data$diff)) + ggplot2::geom_histogram() +
    ggplot2::labs(x="Difference bewteen estimation and simulation") + ggplot2::theme_bw(base_size = 9)
  pl2b <- ggplot2::ggplot(simres,ggplot2::aes(.data$reldiff)) + ggplot2::geom_histogram() +
    ggplot2::labs(x="Relative difference bewteen estimation and simulation (%)") + ggplot2::theme_bw(base_size = 9)

  if(!is.null(out)){
    dir.create(dirname(out),showWarnings = FALSE)
    cat(paste("\\section{Results}","This report shows the results for comparing the NONME results and the results obtained",
              "after simulations by \\texttt{mrgsolve} for model ",simmodel,".\\\\ \\listoftables \\listoffigures\n",sep="\n"),
        file=paste0(dirname(out),"/01.res.tex.rawtex"))
    R3port::ltx_list(sumtbl,out = paste0(dirname(out),"/02.res.tex"), show=FALSE,
                     title="Summary statistics of the differences between estimation and simultion model")
    R3port::ltx_list(utils::head(top10[order(top10$absreldiff,decreasing = TRUE),],10),porder=FALSE,xrepeat=TRUE, show=FALSE,
                     out = paste0(dirname(out),"/03.res.tex"),title="Top 10 highest relative differences between estimation and simultion model")
    R3port::ltx_plot(pl1,out = paste0(dirname(out),"/04.res.tex"),pwidth = 7, show=FALSE,
                     title="Graphical comparison between estimation and simultion model")
    R3port::ltx_plot(list(pl2a,pl2b,ncol=1),out = paste0(dirname(out),"/05.res.tex"),orientation="portrait",linebreak=FALSE, show=FALSE,
                     pwidth = 7,pheight=4, title="Graphical difference between estimation and simultion model")
    R3port::ltx_combine(dirname(out),out=basename(out),orientation='portrait',clean=2, show=FALSE)
  }else{
    return(list(summary=sumtbl,alldif=top10,plot_sim_est=pl1,hist_diff=pl2a,hist_reldiff=pl2b))
  }
}
