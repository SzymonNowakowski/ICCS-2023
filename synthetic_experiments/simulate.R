
#library(glmnet)
library(grpreg)   #grMCP
library(digest)  #digest
library(DMRnet)  #DMRnet
library(CatReg)  #scope
library(randomForest) #RF




source("generModel.R")  ##### Model matrix (data.frame) generation
source("submodels_supermodels.R")





#####    M o d e l    p a r a m e t e r s
beta0 <- rep(0, 23)

# Low 1 and 3
#betaLow1 <- c(rep(-3, 10), rep(0, 4), rep(3, 10))
betaLow1 <- c(rep(0, 10-1), rep(3, 4), rep(6, 10))
betaLow <- c(-4.5, rep(betaLow1, 3), rep(beta0, 7) )

# High 1 and 2
#betaHigh1.a <- c(rep(-2, 8),  rep(0, 8), rep(2, 8))
#betaHigh1.b <- c(rep(-2, 10), rep(0, 4), rep(2, 10))
betaHigh1.a <- c(rep(0, 8-1),  rep(2, 8), rep(4, 8))
betaHigh1.b <- c(rep(0, 10-1), rep(2, 4), rep(4, 10))
betaHigh1 <- c(-12, rep(betaHigh1.a, 3), rep(betaHigh1.b, 3), rep(beta0, 94) )

# High 3
betaHigh3.a <- c(rep(0, 8-1), rep(2, 8), rep(4, 8))
betaHigh3.b <- c(rep(0, 16-1), rep(5, 8))
betaHigh3 <- c(-14, rep(betaHigh3.a, 3), rep(betaHigh3.b, 3), rep(beta0, 94) )

# High 4
#betaHigh4.a <- c(rep(-2, 5),  rep(-1, 5), rep(0, 4), rep(1, 5), rep(2, 5))
betaHigh4.a <- c(rep(0, 5-1),  rep(1, 5), rep(2, 4), rep(3, 5), rep(4, 5))
betaHigh4 <- c(-10, rep(betaHigh4.a, 5), rep(beta0, 95))

# High 5 and 6
#betaHigh5.a <- c(rep(-2, 16), rep(3, 8))
betaHigh5.a <- c(rep(0, 16-1), rep(5, 8))
betaHigh5 <- c(-62, rep(betaHigh5.a, 25), rep(beta0, 75))

# High 7
#betaHigh7.a <- c(rep(-2, 4), rep(0, 12), rep(2, 8))
betaHigh7.a <- c(rep(0, 4-1), rep(2, 12), rep(4, 8))
betaHigh7 <- c(-20, rep(betaHigh7.a, 10), rep(beta0, 90) )

# High 8
#betaHigh8.a <- c(rep(-3, 6),  rep(-1, 6), rep(1, 6), rep(3, 6))
betaHigh8.a <- c(rep(0, 6-1),  rep(2, 6), rep(4, 6), rep(6, 6))
betaHigh8 <- c(-15, rep(betaHigh8.a, 5), rep(beta0, 95))

beta_list <- list(setHigh1 = betaHigh1, setHigh3 = betaHigh3, setHigh4 = betaHigh4, setHigh5 = betaHigh5, setHigh7 = betaHigh7, setHigh8 = betaHigh8)


alg_options<-list(A=c("gic.PDMR", "gic.DMRnet", "scope8"), B=c( "scope32", "grMCP", "grLasso", "RF" ))

#####    C h o i c e    o f   p a r a m e t e r s     o f     t h i s     run

args <- commandArgs(trailingOnly = TRUE)

beta_choice <- as.numeric(args[1])
snr_choice <- as.numeric(args[2])
alg_choice <- as.numeric(args[3])

beta <- beta_list[[beta_choice]]       #6 choices
denot <- names(beta_list)[beta_choice]
snr <-(1+1/3)^(log(3)/log(1+1/3) - (5:-2)) [snr_choice]          #8 choices
algs <- alg_options[[alg_choice]]    #2choices
rho <- 0.5

theme <- paste(denot, snr, rho)
seed <- strtoi(substr(digest(theme, "md5", serialize = FALSE),1,7),16)
cat(theme, "and seed:", seed, "for", denot, "snr:", snr, "alg_group:", alg_choice, "\n")

set.seed(seed)

n <- 500; p <- 100;

#####    P r e d i c t i o n    e r r o r    e s t i m a t i o n

gr <- rep(1:p, each=23)



for (alg in algs) {
  cat("alg:", alg, "\n")

  filename <- paste(denot, "snr", as.character(round(snr,3)), "rho", as.character(rho), alg, sep="_")

  #RNGkind("L'Ecuyer-CMRG")

  print( system.time( ################################################
                      OUT <- simplify2array( lapply(1:200, function(i){
                        cat(i,"\n")
                        ##### OUT <- replicate(20,{ #####  w i t h o u t   p a r a l l e l

                        ##### 1. Model generation
                        XX <- generModel(n, p, rho)
                        X <- model.matrix(~., data=XX)
                        mu <- X %*% beta
                        signal2 <- mean( (mu - mean(mu))^2 )
                        sigma <- sqrt(signal2) / snr
                        y <- mu + rnorm(n, sd=sigma)


                        counts_to_be_uncovered_old <- unlist(lapply(apply(matrix(beta[-1], nrow=23),2,table), function(x) x+c(1, rep(0, length(x)-1))))

                        res <- from_beta_vector(beta[-1])
                        numbers_of_levels_to_be_uncovered <- res$numbers_of_levels
                        counts_to_be_uncovered            <- res$counts
                        points_of_change_to_be_uncovered  <- res$points_of_change

                        #####SANITY CHECK
                        if (sum( counts_to_be_uncovered_old != counts_to_be_uncovered) >= 1)
                          stop("Different counts!!!")

                        ##### 2. Fitting methods


                        can_attempt_comparison <- FALSE

                        start.time <- Sys.time()


                        ## SCOPE
                        gamma <- 8
                        if (alg == "scope32") {
                          gamma <- 32
                        }

                        if (alg %in% c("scope32", "scope8")) {

                          MOD <- scope(XX, y, gamma=gamma)
                          #md0 <- sum( sapply(MOD$beta.best[[2]], function(x) length(unique(x))-1 ) )  this is PP version
                          md0 <- sum(abs(MOD$beta.best[[1]]) > 1e-10) +
                            sum(sapply(sapply(sapply(lapply(MOD$beta.best[[2]], as.factor), levels), unique), length)-1)  #this is SzN version

                          can_attempt_comparison <- TRUE
                          numbers_of_levels_identified <- sapply(lapply(lapply(lapply(MOD$beta.best[[2]], as.factor), levels), unique), length)
                          counts_identified <- unlist(lapply(lapply(MOD$beta.best[[2]], rle), function(x) x$lengths))
                          points_of_change_identified <- unlist(lapply(MOD$beta.best[[2]], function(x) which(x[-1]!=x[-length(x)])))
                        }


                        if (alg == "gic.DMRnet") {
                          repeat{
                            tryCatch(
                              {
                                MOD <- DMRnet(XX, y)
                                break
                              },
                              error=function(cond) {
                                message("Numerical instability detected. Will skip this 1-percent set. Original error:")
                                message(cond); cat("\n")

                              })
                          }

                          MOD <- gic.DMR(MOD)
                          md0 <- MOD$df.min

                          can_attempt_comparison <- TRUE

                          res <- from_beta_vector(MOD$dmr.fit$beta[-1, ncol(MOD$dmr.fit$beta) - MOD$df.min + 1])
                          numbers_of_levels_identified <- res$numbers_of_levels
                          counts_identified            <- res$counts
                          points_of_change_identified  <- res$points_of_change

                        }
                        if (alg == "gic.PDMR") {
                          repeat{
                            tryCatch(
                              {
                                MOD <- DMRnet(XX, y, algorithm="PDMR")
                                break
                              },
                              error=function(cond) {
                                message("Numerical instability detected. Will skip this 1-percent set. Original error:")
                                message(cond); cat("\n")

                              })
                          }
                          MOD <- gic.DMR(MOD)
                          md0 <- MOD$df.min

                          can_attempt_comparison <- TRUE

                          res <- from_beta_vector(MOD$dmr.fit$beta[-1, ncol(MOD$dmr.fit$beta) - MOD$df.min + 1])
                          numbers_of_levels_identified <- res$numbers_of_levels
                          counts_identified            <- res$counts
                          points_of_change_identified  <- res$points_of_change
                        }





                        if (alg %in% c("grLasso", "grMCP")) {
                          MOD <- cv.grpreg(X[,-1], y, group=gr, penalty=alg, nfolds=10)
                          md0 <- sum(coef(MOD)!=0)

                          can_attempt_comparison <- TRUE

                          res <- from_beta_vector(coef(MOD)[-1])
                          numbers_of_levels_identified <- res$numbers_of_levels
                          counts_identified            <- res$counts
                          points_of_change_identified  <- res$points_of_change
                        }

                        if (alg == "RF") {
                          MOD <- randomForest(XX, y=y)
                          md0 <- 0

                          can_attempt_comparison <- FALSE
                        }

                        end.time <- Sys.time()
                        wall_time <- as.numeric(end.time)-as.numeric(start.time)

                        #multi level assessment of partition selection
                        true_model_uncovered <- 0
                        submodel_found <- 0
                        supermodel_found <- 0
                        if (can_attempt_comparison) {
                          true_model_uncovered <- equality(numbers_of_levels_to_be_uncovered, numbers_of_levels_identified,
                                                           counts_to_be_uncovered, counts_identified,
                                                           points_of_change_to_be_uncovered, points_of_change_identified )

                          submodel_found   <- submodel(numbers_of_levels_identified, numbers_of_levels_to_be_uncovered,
                                                       counts_identified, counts_to_be_uncovered)
                          supermodel_found <- submodel(numbers_of_levels_to_be_uncovered, numbers_of_levels_identified,
                                                     counts_to_be_uncovered, counts_identified)
                          #############SANITY CHECK!!!!
                          printing(numbers_of_levels_to_be_uncovered, numbers_of_levels_identified,
                                   counts_to_be_uncovered, counts_identified,
                                   points_of_change_to_be_uncovered, points_of_change_identified )
                          if ((true_model_uncovered & !(submodel_found & supermodel_found)) |
                              (!true_model_uncovered & (submodel_found & supermodel_found))) {

                            stop(paste("DIFFERENT RESULTS FOR DIFFERENT COMPARISONS: ", true_model_uncovered, submodel_found, supermodel_found))
                          }

                        }
                        cat("TM =",true_model_uncovered,"\n")
                        cat("SUB=",submodel_found,"\n")
                        cat("SUP=",supermodel_found,"\n")

                        ##### 3. Prediction error estimation
                        ERR <- replicate(100,{
                          XX_test <- generModel(1000, p, rho)
                          X_test <- model.matrix(~., data=XX_test)
                          mu_test <- X_test %*% beta

                          ## scope or DMRnet
                          if (alg %in% c("scope8", "scope32", "gic.DMRnet", "gic.PDMR", "RF")) {
                            yy <- predict(MOD, XX_test)
                          }

                          if (alg %in% c("grLasso", "grMCP")) {
                            yy <- predict(MOD, X_test[,-1])
                          }

                          c( signal2_test = mean((mu_test - mean(mu_test))^2),
                             mse = mean((mu_test - yy)^2) )
                        })
                        c(signal2 = signal2, sigma = sigma, apply(ERR,1,mean), true_model_uncovered=true_model_uncovered, submodel_found=submodel_found, supermodel_found=supermodel_found, wall_time=wall_time, md0=md0)

                      }))
  )) #################################################################


  write.csv(OUT, file=paste(paste("results_iccs/",filename, sep=""),"csv",sep="."))



}

#print( apply(OUT, 1, summary) )
#print( apply(OUT, 1, function(x) c(mean = mean(x), sd = sd(x))) )

#aa <- read.csv(paste(filename, "csv",sep="."))
#rownames(aa) <- aa[,1]; aa <-aa[,-1]; aa <-as.matrix(aa)
