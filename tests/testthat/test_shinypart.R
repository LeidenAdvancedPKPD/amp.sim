context("Test if functions for shiny work as expected")

#--------------------------
# Test mod2shiny function
test_that("mod2shiny correctly creates a shiny app", {
  nmmod <- system.file("testfiles/nonmem.mod",package="amp.sim")
  tst   <- convert_nonmem(nmmod,out=paste0(tempdir(),"/shinytest"),control="string",overwrite = TRUE)
  prm   <- c(THETA1 = 0.08, THETA2 = 2, THETA3 = 1, THETA4 = 0.2, THETA5 = 1.2, WEIGHT = 70, SEX = 1)
  evnt  <- mrgsolve::ev(amt = 100, ii = 24, addl = 1)
  nams  <- c(THETA1 = "KA (1/h)", THETA2 = "CL (l/h)", THETA3 = "V (l)", THETA4 = "effect of WT", THETA5 = "effect of SEX") 
  ret   <- capture.output(mod2shiny(prm,modfile=paste0(tempdir(),"/shinytest.cpp"),evnt=evnt,naming=nams,
                                    framework="mrgsolve",outloc=tempdir()))
  
  uip  <- try(readLines(paste0(tempdir(),"/ui.r")))
  srvp <- try(readLines(paste0(tempdir(),"/server.r")))
  
  expect_false("try-error"%in%class(uip))
  expect_false("try-error"%in%class(srvp))
  expect_true(all(c("etc","www")%in%list.files(tempdir())))
  expect_true(any(grepl("app created",ret)))
  
  expect_true(any(grepl("numericInput.*THETA1.*KA",uip)))
  expect_true(any(grepl("parm.*WEIGHT",srvp)))
})

#--------------------------
# Test settings2df function
test_that("settings2df correctly creates dataframe with settings", {
  sett <- list(`sim 1`=list(THETA1=0.5,THETA2=1,alllabs=c("THETA1%=%DUMMY1","THETA2%=%DUMMY2")),`sim 2`=list(THETA1=0.9,THETA2=1))
  res  <- settings2df(sett)
  
  expect_true("data.frame"%in%class(res))
  expect_true(all(c("name","sim 1","sim 2")%in%names(res)))
  expect_true(all(c("DUMMY1","DUMMY2")%in%res$name))
  expect_true(all(c(0.5,0.9)%in%as.numeric(res[1,2:3])))
})

#--------------------------
# Test overlaying function
test_that("overlaying correctly adds information", {
  out         <- data.frame(time=0:4, A1=rnorm(5), numsim=1)
  input       <- shiny::reactiveValues(CL=2, KA=0.3, updOpts="appsim")
  overlayres1 <- overlaying(out,input)
  savedsims   <- list(res = overlayres1$results, sett = overlayres1$settings)
  overlayres2 <- overlaying(input=input,out=out,savedsims=savedsims)
  
  expect_type(overlayres1, "list")
  expect_true(unique(overlayres1$results$numsim)==1)
  expect_equal(overlayres1$settings$`sim 1`$CL,2)
  
  expect_equal(unique(overlayres2$results$numsim),1:2)
  expect_equal(length(overlayres2$settings), 2)
  expect_equal(overlayres2$settings[[1]], overlayres2$settings[[2]])
})
