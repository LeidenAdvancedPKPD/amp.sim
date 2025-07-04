#' @export
# Set up and environment to hold some global variables
.simenv <- new.env(parent=emptyenv())
# NONMEM functions and the corresponding translation (mrsolve has some deviations for std::min/max which is handled in convert_nmsyntax)
assign("nmfuncs", c("EXP\\("="exp(","LOG\\("="log(","ABS\\("="abs(","SIN\\("="sin(","COS\\("="cos(",
                  "SQRT\\("="sqrt(","TANH\\("="tan(","MIN\\("="min(","MAX\\("="max(","FLOOR\\("="floor(","CEILING\\("="ceiling("), envir=.simenv)
# NONMEM operators and the corresponding translation
assign("nmoper", c("\\.LT\\."=" < ","\\.LE\\."=" <= ","\\.EQ\\."=" == ","\\.GE\\."=" >= ","\\.GT\\."=" > ",
                 "\\.NE\\."=" != ","\\.AND\\."=" & ","\\.OR\\."=" | ","IF\\(|IF[[:blank:]]*\\("="if(","THEN"="{","ENDIF"="}",
                 "ELSE IF"="}else if","ELSE$"="}else{","END IF$"="}"), envir=.simenv)
# reserved keywords, for now listed all reserved keywords from mrgsolve:::reserved(). If necessary extend for rxode2 or NONMEM (e.g. reserved2, etc)
assign("reserved1", c("ID", "amt", "cmt", "ii", "ss", "evid", "addl", "rate", "time","SOLVERTIME", "table", "ETA", "EPS", "AMT", "CMT", "ID", "TIME",
                     "EVID", "simeps", "self", "simeta", "NEWIND", "DONE", "CFONSTOP", "DXDTZERO", "CFONSTOP", "INITSOLV", "_F", "_R", "_ALAG", "SETINIT",
                     "report", "_VARS_", "VARS", "SS_ADVANCE", "AMT", "CMT", "II", "SS", "ADDL", "RATE", "THETA", "pred_CL", "pred_VC", "pred_V",
                     "pred_V2", "pred_KA", "pred_Q", "pred_VP", "pred_V3", "double", "int", "bool", "capture", "T"), envir=.simenv)
