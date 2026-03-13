context("Test miscelaneous functions")

#------------------------
# Test cut_equal function
test_that("cut_equal cuts in general equal bins", {
  expect_equal(length(table(cut_equal(1:101,5))),5)
  expect_equal(round(mean(sapply(gregexpr("\\+",unique(cut_equal(1:101,5))),length)+1)),20)
  expect_equal(round(mean(sapply(gregexpr("\\+",unique(cut_equal(1:143,4,type=2))),length)+1)),36)
  expect_lt(sd(sapply(gregexpr("\\+",unique(cut_equal(1:1134,13))),length)+1),0.5)
})

#------------------------
# Test dose_func function
test_that("dose_func creates valid dosing", {
  dos1 <- dose_func(1,100,times=0)
  dos2 <- dose_func(1,100,ndose=3,tau=24)
  dos3 <- dose_func(2,100,ndose=3,tau=24,tinf=2)
  dos4 <- dose_func(2,100,times=c(0,24,96))
  
  expect_equal(nrow(dos1),1)
  expect_equal(dos1$var,"A1")
  expect_equal(dos1$method,"add")
  expect_equal(dos1$value,100)
  expect_equal(nrow(dos2),3)
  expect_equal(dos2$time,c(0,24,48))
  expect_equal(dos3$time[1:4],c(0,2,24,26))
  expect_equal(dos3$method[1:2],c("add","rep"))
  expect_equal(dos3$value[1:2],c(50,0))
  expect_equal(nrow(dos4),3)
  expect_equal(dos4$time,c(0,24,96))
})

#-------------------------------
# Test model_validation function
test_that("model_validation creates valid output", {
  res  <- model_validation(system.file("testfiles/compareParfile",package="amp.sim"),
                           system.file("testfiles/compareModel.cpp",package="amp.sim"),out=NULL)
  # Omit latex compilation is difficult in covr and CRAN
  # suppressWarnings(model_validation(system.file("testfiles/compareParfile",package="amp.sim"),
  #                                   system.file("testfiles/compareModel.cpp",package="amp.sim"),
  #                                   out=paste0(tempdir(),"/compare.tex")))                           
    
  expect_true("ggplot"%in%class(res$plot_sim_est))
  expect_true("ggplot"%in%class(res$hist_diff))
  expect_true("ggplot"%in%class(res$hist_reldiff))
  expect_true("data.frame"%in%class(res$summary))
  expect_true("data.frame"%in%class(res$alldif))
  
  expect_true(abs(res$summary$mean[2])<0.001)
  expect_true(abs(mean(as.numeric(res$alldif$reldiff)) - res$summary$mean[2])<1e-5) # small differences due to rounding can occur
  #expect_true(file.exists(paste0(tempdir(),"/compare.tex")))
  #expect_true(file.exists(paste0(tempdir(),"/compare.pdf")))
})

#-------------------------
# Test sample_par function
test_that("sample_par samples correctly", {
  
  extf   <- system.file("testfiles/ext_sampling.ext",package="amp.sim")
  covf   <- system.file("testfiles/covariance_sampling.cov",package="amp.sim")
  bsd    <- system.file("testfiles/bootstrap_testing",package="amp.sim")
  samp1  <- suppressWarnings(sample_par(extf,covf,inc_eta=TRUE,uncert=TRUE, seed=1234))
  samp2  <- suppressWarnings(sample_par(extf,covf,inc_eta=TRUE,uncert=TRUE, seed=1234))
  samp3  <- suppressWarnings(sample_par(extf,covf,inc_eta=TRUE,inc_theta = FALSE, uncert = FALSE, seed=1234))
  samp4  <- suppressWarnings(sample_par(extf,covf,restheta = "THETA3",uncert = TRUE))
  samp5  <- suppressWarnings(sample_par(extf,bootstrap = bsd,uncert = TRUE))
  
  mancov <- matrix(c(3.97955E-02,-3.61431E-02,-3.61431E-02,3.46211E-01),nrow=2)
  set.seed(1234)
  omsamp <- data.frame(MASS::mvrnorm(10,c(0,0),Sigma = mancov))
  rext   <- read.table(extf,skip=1,header=TRUE)
  rcov   <- read.table(covf,skip=1,header=TRUE)
  set.seed(1234)
  thsamp <- data.frame(MASS::mvrnorm(10,mu = unlist(rext[rext$ITERATION==-1e9,-c(1,11)]),Sigma = rcov[,-1]))
  allbs  <- list.files("bootstrap_testing",pattern="\\.ext$",full.names=TRUE)
  allbs  <- do.call(rbind,lapply(allbs,read.table,skip=1,header=TRUE))
  allbs  <- allbs[allbs$ITERATION==-1e9,]
  
  expect_mapequal(samp1,samp2)                      # reproducible through seed
  expect_setequal(samp3$SETA1,omsamp$X1)            # omega sampling same as manual
  expect_setequal(samp3$SETA2,omsamp$X2)            # omega sampling same as manual
  expect_true(length(unique(samp4$STHETA3))==1)     # fixing theta for sigma
  expect_setequal(samp1$STHETA1,thsamp$THETA1)      # theta sampling same as manual
  expect_setequal(samp1$STHETA3,thsamp$THETA3)      # theta sampling same as manual
  expect_setequal(samp1$STHETA5,thsamp$THETA5)      # theta sampling same as manual
  expect_true(all(allbs$THETA2%in%samp5$STHETA2))   # theta sampling same as manual bootstrap
  expect_true(all(allbs$THETA4%in%samp5$STHETA4))   # theta sampling same as manual bootstrap
  expect_warning(sample_par(extf,covf,uncert=TRUE, seed=123)) # warning regarding negative values
})

#-------------------------
# Test sample_sim function
test_that("sample_sim samples correctly", {
  extf   <- system.file("testfiles/ext_sampling.ext",package="amp.sim")
  covf   <- system.file("testfiles/covariance_sampling.cov",package="amp.sim")
  samp1  <- suppressWarnings(sample_sim(ext=extf,covmat=covf,type="noIIV",nrepl=3,nsub=4))
  samp2  <- suppressWarnings(sample_sim(ext=extf,covmat=covf,type="sameIIV",nrepl=3,nsub=4))
  samp3  <- suppressWarnings(sample_sim(ext=extf,covmat=covf,type="varIIV",nrepl=3,nsub=4))
  samp4  <- suppressWarnings(sample_sim(ext=extf,covmat=covf,type="unc_noIIV",nrepl=2,nsub=3))
  samp5  <- suppressWarnings(sample_sim(ext=extf,covmat=covf,type="unc_sameIIV",nrepl=2,nsub=3))
  samp6  <- suppressWarnings(sample_sim(ext=extf,covmat=covf,type="unc_varIIV",nrepl=2,nsub=3))
  
  expect_true(length(unique(samp1$REP))==3)              # correct no of subjects and replicates
  expect_true(nrow(samp1)==3*4)                          # correct no of subjects and replicates
  expect_true(length(unique(samp1$STHETA1))==1)          # no uncertainty
  expect_named(samp1,c("REP","ID",paste0("STHETA",1:5))) # only REP, ID and THETAs for noIIV
  expect_true(length(unique(samp2$SETA1))==4)            # same ETA for sameIIV setting
  expect_true(length(unique(samp2$STHETA3))==1)          # no uncertainty for sameIIV setting
  expect_true(length(unique(samp3$SETA1))==12)           # same ETA for varIIV setting
  expect_true(length(unique(samp3$STHETA4))==1)          # no uncertainty for varIIV setting
  expect_named(samp4,c("REP","ID",paste0("STHETA",1:5))) # only REP, ID and THETAs for unc_noIIV
  expect_true(length(unique(samp4$STHETA5))==2)          # uncertainty for unc_noIIV setting (diff sample per replicate)
  expect_true(length(unique(samp5$SETA1))==3)            # same ETA for unc_sameIIV setting
  expect_true(length(unique(samp5$STHETA5))==2)          # uncertainty for unc_sameIIV setting (diff sample per replicate)
  expect_true(length(unique(samp6$SETA2))==3*2)          # diff ETA for unc_varIIV setting
  expect_true(length(unique(samp6$STHETA5))==2)          # uncertainty for unc_varIIV setting (diff sample per replicate)
})

#-------------------------
# Test tmpl_model function
test_that("tmpl_model gets correct template models", {
  tfil  <- tmpl_model()
  afil  <- list.files(system.file(package="amp.sim"),pattern="\\.tmp$")
  mod1  <- tmpl_model("ana1CMTbolusC.tmp", ret="string")
  mod1m <- readLines(system.file("ana1CMTbolusC.tmp",package="amp.sim"))
  expect_setequal(tfil,afil)
  expect_setequal(mod1,mod1m)  
})

#--------------------
# Test mdose function
test_that("mdose performs correct superposition", {
  simmod <- function(Dose,pars,t) Dose * pars['C'] * exp(-pars['L']*t)
  pars   <- c(L=.01,C=5)
  res    <- mdose(10,tau=24,ndose=5,t=0:240,func=simmod, pars=pars)
  
  res2    <- lapply(1:5,function(x){data.frame(time=(0:240)+((x-1)*24),y=simmod(10,pars,0:240))})
  res2    <- suppressWarnings(Reduce(function(x, y) merge(x, y, all=TRUE,by="time"), res2))
  res2$y  <- rowSums(res2[,-1],na.rm = TRUE)
  res2    <- res2[res2$time<=240,c("time","y")]
  
  expect_mapequal(res,res2) 
})



