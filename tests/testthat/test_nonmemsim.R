context("Test if functions that perform NONMEM simulations work as expected")

#----------------------
# Test simdata function
test_that("simdata correctly makes data for a simulation model", {
  res1 <- simdata(0:24,dosetime=0,doseheight=10,addl=2,ii=24,numid=5)
  res2 <- simdata(0:24,dosetime=c(0,2),doseheight=10,addl=NA,ii=NA,rate=-2,numid=2)
  
  expect_length(unique(res1$ID),5)
  expect_true(all(unique(res1$TIME)==0:24))
  expect_true(res1$ADDL[1]==2)
  expect_true(res1$II[1]==24)
  expect_true(all(is.na(res1$DV)))
  expect_true(nrow(res1)==(25*5)+5) # 25 times 5 subjects and 5 dose lines
  
  expect_length(unique(res2$ID),2)
  expect_true(nrow(res2[!is.na(res2$AMT),])==4)
  expect_true(all(res2$TIME[!is.na(res2$AMT)]==c(0,2)))
  expect_true(all(is.na(res2$ADDL)))
  expect_true(all(is.na(res2$II)))
  expect_true(unique(res2$RATE[!is.na(res2$AMT)])==-2)
})

#------------------------------
# Test make_nmsimmodel function
test_that("make_nmsimmodel correctly makes a NONMEM simulation model", {
  dat         <- simdata(0:24,dosetime=0,doseheight=10,addl=2,ii=24,numid=50)
  dat$WEIGHT  <- 70
  dat$SEX     <- 1
  dat$STHETA1 <- dat$STHETA2 <- dat$STHETA3 <- dat$STHETA4 <- dat$STHETA5 <- 1
  dat$SETA1   <- dat$SETA2   <- 0
  write.csv(dat,file=paste0(tempdir(),"/simdat.csv"),na=".",quote=FALSE,row.names = FALSE)
  nmmod       <- system.file("testfiles/nonmem.mod",package="pmxsimtools")
  suppressWarnings(make_nmsimmodel(nmmod,paste0(tempdir(),"/simmod.mod"), data=paste0(tempdir(),"/simdat.csv")))
  mod         <- readLines(paste0(tempdir(),"/simmod.mod"))
  modsub      <- mod[grep("\\$PK",mod):length(mod)]
  
  expect_true(any(grepl("\\$SIM",mod)))
  expect_true(substr(mod[grepl("\\$EST",mod)],1,1)==";")
  expect_true(substr(mod[grepl("\\$COV",mod)],1,1)==";")
  expect_true(substr(mod[grepl("\\$THETA",mod)],1,1)==";")
  expect_true(grepl("simdat.csv",mod[grepl("^\\$DATA",mod)]))
  
  expect_true(any(grepl("STHETA1",modsub)))
  expect_true(any(grepl("STHETA5",modsub)))
  expect_true(any(grepl("SETA1",modsub)))
})

#------------------------
# Test split_sim function
# TAKE INTO ACCOUNT THAT THE PREVIOUS TEST SHOULD BE DONE BEFORE RUNNING THE CODE BELOW
test_that("split_sim correctly splits the simulation", {
  split_sim(data=paste0(tempdir(),"/simdat.csv"),model=paste0(tempdir(),"/simmod.mod"),
            locout=tempdir())
  nfo  <- file.info(list.files(tempdir(),full.names = TRUE))
  dats <- nfo$size[grepl(paste0("simdat.[[:digit:]].csv"),row.names(nfo))]
  
  expect_true(all(paste0("simmod.",1:4,".mod")%in%list.files(tempdir())))
  expect_true(all(paste0("simdat.",1:4,".csv")%in%list.files(tempdir())))
  expect_true(sd(dats)/mean(dats)<0.1)
})

