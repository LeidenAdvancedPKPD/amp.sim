context("Test if functions that read and convert models work as expected")

#--------------------------
# Test get_nmblock function
test_that("get_nmblock correctly gets all blocks from a NONMEM models", {
  mdl   <- c("$PROB dummy model","$DES\n res = 1 +2","res2= 2+3","$PK variable=1")
  conv1 <- get_nmblock(mdl,"PROB")                  # get single item
  conv2 <- get_nmblock(mdl,"PROBLEM")               # set an alias
  conv3 <- get_nmblock(mdl,c("PROBLEM","DES","PK")) # get multiple blocks
  conv4 <- get_nmblock(mdl,"DES",ret="index")       # get index only
  conv5 <- get_nmblock(mdl,"PK",omitbn=FALSE)       # include dollar block name in content
  
  expect_equal(conv1[[1]],"dummy model")
  expect_equal(conv2[[1]],"dummy model")
  expect_length(conv3, 3)
  expect_named(conv3, c("PROBLEM","DES","PK"))
  expect_equal(conv4[[1]],2:3)
  expect_true(grepl("\\$PK",conv5[[1]]))
})

#--------------------------
# Test nmlistblock function
test_that("nmlistblock correctly lists all different parts of a NONMEM model", {
  mdl   <- c("$PROB dummy model ; comment","$DES\n DADT(1) = -KA * A(1)","$PK","IF(DUMM.EQ.1) KA = 1","A_0(1) = 0")
  lst   <- nmlistblock(get_nmblock(mdl,c("PROBLEM","DES","PK"))) 

  expect_length(lst, 3)
  expect_length(lst$PK, 3)
  expect_named(lst$PK[[1]], c("orig", "type", "LHS", "RHS", "comm", "cntrl", "dupl"))
  
  expect_equal(lst$DES[[1]]$orig,"DADT(1) = -KA * A(1)")
  expect_equal(lst$DES[[1]]$type,"formula")
  expect_equal(lst$DES[[1]]$LHS,"DADT(1)")
  expect_equal(trimws(lst$DES[[1]]$RHS),"-KA * A(1)")
  
  expect_equal(lst$PK[[2]]$type,"control+formula")
  expect_equal(lst$PK[[2]]$cntrl,"IF(DUMM.EQ.1)")
  expect_equal(lst$PK[[3]]$type,"init")
  
  expect_equal(trimws(lst$PROB[[1]]$comm),"comment")
})

#-------------------------------
# Test convert_nmsyntax function
test_that("convert_nmsyntax correctly convert NONMEM specific syntax", {
  mdl   <- c("IF(DUMM.EQ.1.OR.DUMM.GE.3) KA = 1","CL = LOG(2) * EXP(1) + MAX(10)")
  res1  <- convert_nmsyntax(mdl) 
  res2  <- convert_nmsyntax(mdl,type="deSolve") 
  
  expect_equal(res1[1],"if(DUMM == 1 | DUMM >= 3) KA = 1")
  expect_true(grepl("log",res1[2]) & grepl("exp",res1[2]))
  expect_true(grepl("std::max",res1[2]))
})

#-----------------------
# Test conv_pow function
test_that("conv_pow correctly convert the power to syntax used in mrgsolve", {
  res   <- conv_pow("y = par1*(par2/par3)^xy + a - par4**(2/par5) + 3**4") 
  
  expect_true(grepl("pow\\(\\(par2/par3\\), xy\\)",res))
  expect_true(grepl("pow\\(par4, \\(2/par5\\)\\)",res))
  expect_true(grepl("pow\\(3, 4\\)",res))
})

#----------------------
# Test get_est function
test_that("get_est correctly gets the estimate from a model or ext output", {
  ext <- data.frame(ITERATION = c(0L, 24L, -1000000000L),THETA1 = c(0.03,0.07, 0.07),THETA2 = c(2, 2.6, 2.6),
                    SIGMA.1.1. = c(0.1,0.07, 0.07), OMEGA.1.1. = c(0.01, 0.006, 0.006), 
                    OMEGA.2.1. = c(0, 0, 0), OMEGA.2.2. = c(0.02, 0.04, 0.04), OBJ = c(999, 647, 647))
  mdl  <- c("$THETA","(0,.03) ; KA (1/h)"," (0,2) ; K (1/h)","$OMEGA  .01; ETA KA" ," .02; ETA K","$SIGMA  .1  ; Prop. error")
  extr <- get_est(ext)
  modr <- get_est(mdl)
  
  expect_equal(names(extr), names(modr))
  expect_true(is.matrix(extr$OMEGA))
  expect_true(is.matrix(modr$OMEGA))
  expect_true(is.matrix(extr$SIGMA))
  expect_named(extr$THETA)
  expect_named(extr$ETA)
  expect_equal(unname(extr$THETA), c(0.07,2.6))
  expect_equal(unname(extr$ETA), c(0,0))
  expect_equal(extr$OMEGA, matrix(c(0.006,0,0,0.04),nrow=2))
  expect_equal(unname(modr$THETA), c(0.03,2))
  expect_equal(unname(modr$ETA), c(0,0))
  expect_equal(modr$OMEGA, matrix(c(0.01,0,0,0.02),nrow=2))
  expect_equal(extr$THETAN, c("THETA1","THETA2"))
  expect_equal(trimws(modr$THETAN), c("KA (1/h)","K (1/h)"))
})

#--------------------------
# Test get_parmvar function
test_that("get_parmvar gets all correct parameter variables from model", {
  mdl   <- c("$DES\n DADT(1) = -KA * A(1)","$PK","IF(DUMM.EQ.1) THEN","KA=1","ELSE","KA=2","ENDIF","A_0(1) = 0",
             "CL = LOG(2) * EXP(1) + MAX(10)","V2=THETA(1)","$THETA","10")
  lst   <- nmlistblock(get_nmblock(mdl,c("DES","PK"))) 
  res1  <- get_parmvar(lst) 
  res2  <- get_parmvar(lst,returnall=TRUE) 
  
  expect_equal(res1,"DUMM")
  expect_equal(res2,c("DUMM","KA","CL","V2","DADT(1)"))
})

#------------------------
# Test get_param function
test_that("get_param returns the valid parameters and matrices", {
  ext <- data.frame(ITERATION = c(0L, 24L, -1000000000L),THETA1 = c(0.03,0.07, 0.07),THETA2 = c(2, 2.6, 2.6),
                    SIGMA.1.1. = c(0.1,0.07, 0.07), OMEGA.1.1. = c(0.01, 0.006, 0.006), 
                    OMEGA.2.1. = c(0, 0, 0), OMEGA.2.2. = c(0.02, 0.04, 0.04), OBJ = c(999, 647, 647))
  mdl   <- c("$PK","CL=THETA(1)","WT=70","DUMM=ALP","$THETA","(0,.03) ; KA (1/h)"," (0,2) ; K (1/h)",
             "$OMEGA  .01; ETA KA" ," .02; ETA K","$SIGMA  .1  ; Prop. error")
  lst   <- nmlistblock(get_nmblock(mdl,c("PK","THETA","OMEGA","SIGMA"))) 
  res1  <- get_param(mdl,lst,ext) 
  res2  <- get_param(mdl,lst) 
  res3  <- get_param(mdl,lst,addparam = FALSE) 
  
  expect_true(length(res1)==length(res2) & length(res1)==length(res3)) # length is the same for each setting
  expect_true(all(names(res1$params)==c("THETA1","THETA2","ALP")))     # additional parameter added
  expect_true(all(names(res3$params)==c("THETA1","THETA2")))           # additional parameter not added
  expect_true(res1$params[1]==0.07)                                    # THETA value from ext
  expect_true(res2$params[1]==0.03)                                    # THETA value from model
  expect_true(grepl("theta_names.*KA.*K",res1$theta_names))            # creation of names
  expect_true(is.matrix(res1$omega_matrix) & is.matrix(res1$sigma_matrix))
  expect_true(all(trimws(res1$omega_string)==c("0.006","0 0.04" )))
  expect_true(res2$sigma_string=="0.1")
})

#------------------------
# Test get_inits function
test_that("get_inits returns the valid initial states", {
  mdl   <- c("$DES\n DADT(1) = -KA * A(1)","DADT(2) = 0","DADT(3) = 0","$PK","A_0(2) = BL","A_0(3) = 100")
  lst   <- nmlistblock(get_nmblock(mdl,c("DES","PK")))
  res   <- get_inits(lst) 
  
  expect_true(length(res)==3) 
  expect_true(as.numeric(res['A1'])==0)
  expect_true(res['A2']=='BL')
  expect_true(as.numeric(res['A3'])==100)
})

#--------------------------
# Test nm2mrgsolve function
test_that("nm2mrgsolve returns the correctly tranformed model", {
  mdl   <- c("$PROB  example","$PK","KA = THETA(1) * EXP(ETA(1))","CL = THETA(2) * EXP(ETA(2))","V  = THETA(3)","S2  = V","K20 = CL/V","F1  = 1",
             "$MODEL","COMP = (ABS)","COMP = (CENTRAL)",
             "$DES","CP = A(2)/V","DADT(1) = - KA*A(1)","DADT(2) =   KA*A(1) - K20*A(2)","$THETA (0,.1) ; KA (1/h)","(0,2) ; CL (l/h)","(0,1) ; V (l)",
             "$OMEGA",".01 ; ETA KA",".02 ; ETA CL","$ERROR","Y = F * (1 + EPS(1))","IPRED = F","$SIGMA",".1 ; Prop. error")
  lst   <- nmlistblock(get_nmblock(mdl,c("DES","PK","OMEGA","SIGMA","PROB","THETA","MODEL","ERROR")))
  res   <- nm2mrgsolve(lst,mdl) 
  
  expect_true(all(c("modname", "problem", "control2mod", "cmt", "pkblock", "init", 
                    "desblock", "predblock", "errorblock", "param", "randstruct", 
                    "sigmablock", "modtype", "mdl_ret", "control")%in%names(res))) 
  
  expect_true(res$modname==".cpp")
  expect_true(res$problem=="example")
  expect_false(res$control2mod)
  expect_true(grepl("CMT.*A1.*A2",res$cmt))
  expect_true(grepl("PK.*KA.*=.*THETA\\(1\\) \\* exp\\(ETA\\(1\\)\\)",res$pkblock))
  expect_true(grepl("DES.*DADT\\(1\\).*=.*-.*KA\\*A\\(1\\)",res$desblock))
  expect_true(res$predblock=="")
  expect_true(grepl("F = A\\(2\\)/S2",res$errorblock))
  expect_true(grepl("Y =  F \\* \\(1 +.*EPS\\(1\\)\\)",res$errorblock))
  expect_true(res$param=="THETA1 = 0.1, THETA2 = 2, THETA3 = 1")
  expect_true(grepl("OMEGA @block.*0.01.*0.*0.02",res$randstruct))
  expect_true(grepl("SIGMA @block.*0.1",res$sigmablock))
  expect_true(res$modtype=="ode")
  expect_true(grep("mrgsolve",res$control)==1 & grep("mread",res$control)==2)
  expect_true(any(grepl("ev\\(",res$control)))
  expect_true(any(grepl("mrgsim\\(",res$control)))
  
  res2 <- nm2mrgsolve(lst,mdl,mod_return = "Y") 
  expect_true(res2$mdl_ret=="$CAPTURE Y")
  res3 <- nm2mrgsolve(lst,mdl,out = "test") 
  expect_true(res3$modname=="test.cpp")
})

#------------------------
# Test nm2rxode2 function
test_that("nm2rxode2 returns the correctly tranformed model", {
  mdl   <- c("$PROB  example","$PK","KA = THETA(1) * EXP(ETA(1))","CL = THETA(2) * EXP(ETA(2))","V  = THETA(3)","S2  = V","K20 = CL/V","F1  = 1",
             "$MODEL","COMP = (ABS)","COMP = (CENTRAL)",
             "$DES","CP = A(2)/V","DADT(1) = - KA*A(1)","DADT(2) =   KA*A(1) - K20*A(2)","$THETA (0,.1) ; KA (1/h)","(0,2) ; CL (l/h)","(0,1) ; V (l)",
             "$OMEGA",".01 ; ETA KA",".02 ; ETA CL","$ERROR","Y = F * (1 + EPS(1))","IPRED = F","$SIGMA",".1 ; Prop. error")
  lst   <- nmlistblock(get_nmblock(mdl,c("DES","PK","OMEGA","SIGMA","PROB","THETA","MODEL","ERROR")))
  res   <- nm2rxode2(lst,mdl) 
  
  expect_true(all(c("modname", "problem", "control2mod", "cmt", "pkblock", "init", 
                    "desblock", "predblock", "errorblock", "param", "randstruct", 
                    "sigmablock", "modtype", "mdl_ret", "control")%in%names(res))) 
  
  expect_true(res$modname==".r")
  expect_true(res$problem=="example")
  expect_false(res$control2mod)
  expect_true(res$cmt=="" & res$predblock=="" & res$param=="" & res$randstruct=="" & res$sigmablock=="" & res$mdl_ret=="")
  expect_true(grepl("KA.*=.*THETA1.*exp\\(ETA1\\)",res$pkblock))
  expect_true(grepl("A1\\(0\\).*=.*0",res$init))
  expect_true(grepl("d/dt\\(A1\\).*=.*-.*KA\\*A1",res$desblock))
  expect_true(grepl("F = A2/S2",res$errorblock))
  expect_true(grepl("Y =  F \\* \\(1 +.*EPS1\\)",res$errorblock))
  expect_true(res$modtype=="ode")
  expect_true(grep("rxode2",res$control)==1 & grep("source",res$control)==2)
  expect_true(any(grepl("c\\(THETA1 = 0.1.*2.*1",res$control)))
  expect_true(any(grepl("ome.*structure.*0.01.*0.*0.*0.02",res$control)))
  expect_true(any(grepl("sigm.*structure.*0.1.*dim",res$control)))
  expect_true(any(grepl("et\\(",res$control)))
  expect_true(any(grepl("rxSolve\\(",res$control)))
  
  res2 <- nm2rxode2(lst,mdl,control = "model") 
  expect_true(res2$control2mod)
  expect_false(any(grepl("rxode2|source",res2$control)))
  res3 <- nm2rxode2(lst,mdl,out = "test") 
  expect_true(res3$modname=="test.r")
})

#------------------------
# Test nm2nonmem2rx function
test_that("nm2nonmem2rx returns the correctly tranformed model", {
  if(require(nonmem2rx)){
    mdl   <- c("$PROB  example","$PK","KA = THETA(1) * EXP(ETA(1))","CL = THETA(2) * EXP(ETA(2))","V  = THETA(3)","S2  = V","K20 = CL/V","F1  = 1",
               "$MODEL","COMP = (ABS)","COMP = (CENTRAL)",
               "$DES","CP = A(2)/V","DADT(1) = - KA*A(1)","DADT(2) =   KA*A(1) - K20*A(2)","$THETA (0,.1) ; KA (1/h)","(0,2) ; CL (l/h)","(0,1) ; V (l)",
               "$OMEGA",".01 ; ETA KA",".02 ; ETA CL","$ERROR","Y = F * (1 + EPS(1))","IPRED = F","$SIGMA",".1 ; Prop. error")
    tdir   <- tempdir()
    writeLines(mdl,paste0(tdir,"/testmodel.mod"))
    #lst   <- nmlistblock(get_nmblock(mdl,c("DES","PK","OMEGA","SIGMA","PROB","THETA","MODEL","ERROR")))
    res   <- nm2nonmem2rx(paste0(tdir,"/testmodel.mod")) 
    
    expect_true(all(c("modelfun","modname","control")%in%names(res))) 
    
    expect_true(res$modname==".r")
    expect_true(grepl("KA.*exp\\(ETA.*\\)",res$modelfun))
    expect_true(grepl("d/dt\\(ABS\\).*<-.*-.*ka",res$modelfun))
    expect_true(grepl("f\\(ABS\\)",res$modelfun))
    expect_true(any(grepl("parm.*<-.*\\(.*\\)",res$control)))
    expect_true(any(grepl("ome.*structure.*0.01.*0.*0.*0.02",res$control)))
    expect_true(any(grepl("sigm.*structure.*0.1.*dim",res$control)))
    expect_true(any(grepl("et\\(",res$control)))
    expect_true(any(grepl("rxSolve\\(",res$control)))
    
    res2 <- nm2nonmem2rx(paste0(tdir,"/testmodel.mod"),control = "model") 
    expect_false(any(grepl("rxode2|source",res2$control)))
    res3 <- nm2nonmem2rx(paste0(tdir,"/testmodel.mod"),out = "test") 
    expect_true(res3$modname=="test.r")
  }
})

#------------------------
# Test nm2deSolve function
test_that("nm2deSolve returns the correctly tranformed model", {
  mdl   <- c("$PROB  example","$PK","KA = THETA(1) * EXP(ETA(1))","CL = THETA(2) * EXP(ETA(2))","V  = THETA(3)","S2  = V","K20 = CL/V","F1  = 1",
             "$MODEL","COMP = (ABS)","COMP = (CENTRAL)",
             "$DES","CP = A(2)/V","DADT(1) = - KA*A(1)","DADT(2) =   KA*A(1) - K20*A(2)","$THETA (0,.1) ; KA (1/h)","(0,2) ; CL (l/h)","(0,1) ; V (l)",
             "$OMEGA",".01 ; ETA KA",".02 ; ETA CL","$ERROR","Y = F * (1 + EPS(1))","IPRED = F","$SIGMA",".1 ; Prop. error")
  lst   <- nmlistblock(get_nmblock(mdl,c("DES","PK","OMEGA","SIGMA","PROB","THETA","MODEL","ERROR")))
  res   <- nm2deSolve(lst,mdl) 
  
  expect_true(all(c("modname", "problem", "control2mod", "cmt", "pkblock", "init", 
                    "desblock", "predblock", "errorblock", "param", "randstruct", 
                    "sigmablock", "modtype", "mdl_ret", "control")%in%names(res))) 
  
  expect_true(res$modname==".r")
  expect_true(res$problem=="example")
  expect_false(res$control2mod)
  expect_true(res$cmt=="" & trimws(res$predblock)=="" & res$randstruct=="" & res$sigmablock=="" & res$errorblock=="")
  expect_true(grepl("KA.*<-.*THETA1.*exp\\(ETA1\\)",res$pkblock))
  expect_true(grepl("DADT1.*<-.*-.*KA\\*A1",res$desblock))
  expect_true(res$modtype=="ode")
  expect_true(all(names(res$init)==c("A1","A2")))
  expect_true(sum(res$init)==0)
  expect_true(all(names(res$param)==c("THETA1","THETA2","THETA3","ETA1","ETA2")))
  expect_true(all(unname(res$param)==c(0.1,2,1,0,0)))
  expect_true(grepl("list.*DADT1.*DADT2",res$mdl_ret))
  
  expect_true(grep("library.*deSolve",res$control)==2 & grep("source",res$control)==4)
  expect_true(any(grepl("c\\(THETA1 = 0.1.*2.*1",res$control)))
  expect_true(any(grepl("THETA1 = 0.1.*ETA2 = 0",res$control)))
  expect_true(any(grepl("A1 = 0.*A2 = 0",res$control)))
  expect_true(any(grepl("dose_func\\(",res$control)))
  expect_true(any(grepl("lsoda\\(",res$control)))
  
  res2 <- nm2deSolve(lst,mdl,control = "model") 
  expect_true(res2$control2mod)
  expect_false(any(grepl("library.*deSolve|source",res2$control)))
  res3 <- nm2deSolve(lst,mdl,out = "test") 
  expect_true(res3$modname=="test.r")
})

#-----------------------------
# Test convert_nonmem function
test_that("convert_nonmem returns the correctly tranformed model", {
  mdl   <- c("$PROB  example","$PK","KA = THETA(1) * EXP(ETA(1))","CL = THETA(2) * EXP(ETA(2))","V  = THETA(3)","S2  = V","K20 = CL/V","F1  = 1",
             "$MODEL","COMP = (ABS)","COMP = (CENTRAL)",
             "$DES","CP = A(2)/V","DADT(1) = - KA*A(1)","DADT(2) =   KA*A(1) - K20*A(2)","$THETA (0,.1) ; KA (1/h)","(0,2) ; CL (l/h)","(0,1) ; V (l)",
             "$OMEGA",".01 ; ETA KA",".02 ; ETA CL","$ERROR","Y = F * (1 + EPS(1))","IPRED = F","$SIGMA",".1 ; Prop. error")
  tdir   <- tempdir()
  writeLines(mdl,paste0(tdir,"/testmodel.mod"))
  
  cntrl1 <- convert_nonmem(paste0(tdir,"/testmodel.mod"),control="string",out=paste0(tdir,"/testmrgsolve"),overwrite=TRUE) 
  mod1   <- readLines(paste0(tdir,"/testmrgsolve.cpp"))
  
  expect_true(length(cntrl1)>0 & length(mod1)>0) 
  expect_true(grep("mrgsolve",cntrl1)[1]==1 & grep("mread",cntrl1)==2)
  expect_true(any(grepl("\\$PLUGIN",mod1))  & any(grepl("\\$DES",mod1)) & any(grepl("\\$PK",mod1)))
  
  cntrl2 <- convert_nonmem(paste0(tdir,"/testmodel.mod"),control="string",out=paste0(tdir,"/testrxode2"),overwrite=TRUE,type_return="rxode2") 
  mod2   <- readLines(paste0(tdir,"/testrxode2.r"))
  
  expect_true(length(cntrl2)>0 & length(mod2)>0) 
  expect_true(grep("rxode2",cntrl2)[1]==1 & grep("source",cntrl2)==2)
  expect_true(any(grepl("model.*rxode2\\(",mod2))  & any(grepl("d/dt\\(A1\\)",mod2)))
  
  cntrl3 <- convert_nonmem(paste0(tdir,"/testmodel.mod"),control="string",out=paste0(tdir,"/testdesolve"),overwrite=TRUE,type_return="deSolve") 
  mod3   <- readLines(paste0(tdir,"/testdesolve.r"))
  
  expect_true(length(cntrl3)>0 & length(mod3)>0) 
  expect_true(grep("deSolve",cntrl3)[1]==2 & grep("source",cntrl3)==4)
  expect_true(any(grepl("model.*function\\(",mod3))  & any(grepl("DADT1",mod3)))
  
  cntrl4 <- convert_nonmem(paste0(tdir,"/testmodel.mod"),control="string",out=paste0(tdir,"/testreturn1"),overwrite=TRUE,mod_return="CP") 
  mod4   <- readLines(paste0(tdir,"/testreturn1.cpp"))
  expect_true(any(grepl("\\$CAPTURE CP",mod4)))
  
  convert_nonmem(paste0(tdir,"/testmodel.mod"),control="file",out=paste0(tdir,"/testcontrol"),overwrite=TRUE, verbose=FALSE) 
  expect_true(file.exists(paste0(tdir,"/testcontrol_control.r")))
  expect_output(convert_nonmem(paste0(tdir,"/testmodel.mod"),control="console",out=paste0(tdir,"/testcontrol"),overwrite=TRUE, verbose=FALSE))
  
  expect_error(convert_nonmem(paste0(tdir,"/testmodel.mod"),type_return="dummy"))
  convert_nonmem(paste0(tdir,"/testmodel.mod"),control="file",out=paste0(tdir,"/testoverwrite"),overwrite=TRUE, verbose=FALSE) 
  expect_warning(convert_nonmem(paste0(tdir,"/testmodel.mod"),control="file",out=paste0(tdir,"/testoverwrite"),overwrite=FALSE, verbose=FALSE) )
  expect_output(convert_nonmem(paste0(tdir,"/testmodel.mod"),control="console",out=paste0(tdir,"/testcontrol"),overwrite=TRUE, verbose=TRUE))
})


