

library(randomForest)
library(glmnet)
library(stats)  #model.matrix
library(CatReg)
library(DMRnet)
library(grpreg)
library(digest)


binomial <- function(allX, ally, factor_columns, model_choices, set_name, train_percent, runs=200, gamma=100) {

  errors<-list()
  effective_lengths<-list()
  sizes<-list()
  computation_times<-list()
  problem_sizes<-list()

  test_sizes<-n_sizes<-p_sizes<-numeric(0)

  args <- commandArgs(trailingOnly = TRUE)

  cat("\n >train percent: ", train_percent, "\n")

  if (length(args)>0) {
    cat("changing train percent to", args[1], "\n")
    train_percent<-as.numeric(args[1])
    cat("changed train percent: ", train_percent, "\n")
    set_name<-paste(set_name, args[1], sep="-")
    cat("updating set name - and consequently a seed - to:", set_name, "\n")
  }

  cat("\n >runs: ", runs, "\n")

  if (length(args)>2) {   #runs change requires two arguments - number of runs + additional argument numbering similar runs
    cat("changing runs value to", args[2], "\n")
    runs<-as.integer(args[2])
    cat("changed runs: ", runs, "\n")
    set_name<-paste(set_name, args[2], args[3], sep="-")
    cat("updating set name - and consequently a seed - to:", set_name, "\n")
  }

  set.seed(strtoi(substr(digest(set_name, "md5", serialize = FALSE),1,7),16))

  cat("model choices: ", model_choices, "\n")

  for (model_choice in model_choices) {

    cat("now running: ", model_choice, "\n")

    gamma <- 350 - gamma    #it alternates between 250 and 100
    times<-dfmin<-misclassification_error<-lengths<-rep(0,runs)


    run<-1

    while (run<=runs) {
      cat("generating train/test sets\n")
      sample.percent <- sample(1:nrow(allX), train_percent*nrow(allX))
      data.train.percent.x <- allX[sample.percent, , drop=FALSE]
      data.train.percent.y <- ally[sample.percent,drop=FALSE]

      data.test.percent.x <- allX[-sample.percent, , drop=FALSE]
      data.test.percent.y <- ally[-sample.percent,drop=FALSE]


      #####RECOMPUTATION OF RELEVANT FACTORS in train set, to remove levels with no representative data (empty factors). Needed for random forest and glmnet
      ###and for DMRnet - old package
      ###but nor for DMRnet - new package
      for (i in factor_columns)
        data.train.percent.x[,i] <- factor(data.train.percent.x[,i])



      #remove data from test set with factors not present in train subsample as this causes predict() to fail
      for (i in factor_columns) {
        train.levels <- levels(data.train.percent.x[,i])
        data.test.percent.y<-data.test.percent.y[which(data.test.percent.x[,i] %in% train.levels)]
        data.test.percent.x<-data.test.percent.x[which(data.test.percent.x[,i] %in% train.levels),]
      }
      for (i in factor_columns)
        data.test.percent.x[,i] <- factor(data.test.percent.x[,i], levels = levels(data.train.percent.x[,i]))   #recalculate factors now for new test


      #removing columns with only one value:
      singular_columns<-which(sapply(lapply(data.train.percent.x, levels), length)==1)   #for continous columns length is 0
      if (length(singular_columns)>0) {
        data.test.percent.x <- data.test.percent.x[,-singular_columns]
        data.train.percent.x <- data.train.percent.x[,-singular_columns]
        cat("removed", length(singular_columns), "columns due to singular values\n")
      }

      X<-stats::model.matrix(~., data.train.percent.x)
      n_size<-nrow(X)
      p_size<-ncol(X)
      test_size<-nrow(data.test.percent.x)

      cat("n=", n_size, "p=", p_size, "test=", test_size, "\n")

      start.time <- Sys.time()
      cat("Started: ", start.time,"\n")

      if (model_choice=="cv.grLasso" | model_choice=="cv.MCP") {
        cat(model_choice, "with CV\n")
        X<-stats::model.matrix(~., data.train.percent.x)
        level_count <- sapply(lapply(data.train.percent.x, levels), length)
        level_count[level_count == 0] <- 2   #make it two for continous variables
        groups<-rep(1:length(level_count), level_count-1)
        if (model_choice == "cv.grLasso") {
          penalty <-  "grLasso"
        } else
          penalty <- "grMCP"

        lev <- levels(factor(data.train.percent.y))
        y <- ifelse(data.train.percent.y == lev[2], 1, 0)

        model.percent <- cv.grpreg(X[,-1], y, group=groups, penalty=penalty, family="binomial", nfolds=10)

      } else if (model_choice=="gic.DMRnet") {
        cat("DMRnet with GIC only\n")
        model.percent <- tryCatch(DMRnet(data.train.percent.x, data.train.percent.y, nlambda=100, family="binomial"),
                                   error=function(cond) {
                                     message("Numerical instability in DMRnet detected. Will skip this 1-percent set. Original error:")
                                     message(cond); cat("\n")
                                     return(c(2,2))
                                   })

        if (length(model.percent)==2) {
          next
        }

        cat("GIC\n")
        gic <- gic.DMR(model.percent)

      } else if (model_choice=="gic.PDMR") {
        cat("PDMR method\n")
        model.percent <- tryCatch(DMRnet(data.train.percent.x, data.train.percent.y, nlambda=100, algorithm="PDMR", family="binomial"),
                                   error=function(cond) {
                                     message("Numerical instability in PDMR detected. Will skip this 1-percent set. Original error:")
                                     message(cond); cat("\n")
                                     return(c(2,2))
                                   })

        if (length(model.percent)==2) {
          next
        }

        cat("GIC\n")
        gic <- gic.DMR(model.percent)   #we are using existing gic calculation which is compatible with PDMR models

      } else if (model_choice=="scope") {
        cat("Scope, no cv, gamma=", gamma,"\n")
        model.percent <- tryCatch(scope.logistic(data.train.percent.x, as.numeric(levels(data.train.percent.y))[data.train.percent.y], gamma=gamma),
                                   error=function(cond) {
                                     message("Numerical instability in SCOPE detected. Will skip this 1-percent set. Original error:")
                                     message(cond); cat("\n")
                                     return(c(2,2))
                                   })

        if (length(model.percent)==2) {
          next
        }

      } else if (model_choice=="RF") {
        cat("random forest. no cv\n")
        model.percent <- randomForest(data.train.percent.x, y=data.train.percent.y)
      } else if (model_choice=="lr") {
        cat("Logistic Regression no cv\n")
        model.percent <- glm(data.train.percent.y~., data = data.train.percent.x, family="binomial")
      } else if (model_choice=="cv.glmnet") {
        cat("glmnet with cv\n")
        glmnetX <- makeX(data.train.percent.x, test = data.test.percent.x)

        trainX<-glmnetX[[1]]
        testX<-glmnetX[[2]]

        model.percent<-cv.glmnet(trainX, data.train.percent.y, family="binomial", nfolds=10)
      } else
        stop("Uknown method")




      if (model_choice=="cv.grLasso" | model_choice=="cv.MCP") {
        cat(model_choice, "with CV prediction\n")
        X_test<-stats::model.matrix(~., data.test.percent.x)
        prediction<- tryCatch(predict(model.percent, X_test[,-1], type="class"),
                              error=function(cond) {
                                message("Numerical instability in predict (grpreg) detected. Will skip this 1-percent set. Original error:")
                                message(cond); cat("\n")
                                return(c(1,1))
                              })

        if (length(prediction)==2) {
          next
        }
      } else if (model_choice=="gic.DMRnet" | model_choice=="gic.PDMR") {
        cat(model_choice, "pred\n")
        prediction<- tryCatch(predict(model.percent, newx=data.test.percent.x, df = gic$df.min, type="class"),
                              error=function(cond) {
                                message("Numerical instability in predict (DMRnet) detected. Will skip this 1-percent set. Original error:")
                                message(cond); cat("\n")
                                return(c(1,1))
                              })

        if (length(prediction)==2) {
          next
        }
      } else if (model_choice=="scope") {
        cat("scope pred\n")
        prediction<- ifelse(predict(model.percent, data.test.percent.x) >0.5,1,0)
      } else if (model_choice=="RF") {
        cat("Random Forest pred\n")
        prediction<- tryCatch(predict(model.percent, data.test.percent.x, type="class"),
                              error=function(cond) {
                                message("Numerical instability in predict (RF) detected. Will skip this 1-percent set. Original error:")
                                message(cond); cat("\n")
                                return(c(1,1))
                              })

        if (length(prediction)==2) {
          next
        }
      } else if (model_choice=="lr") {
        cat("Logistic Regression pred\n")
        prediction<- ifelse(predict(model.percent, data.test.percent.x) >0,1,0)
      } else if (model_choice=="cv.glmnet") {
        cat("glmnet pred\n")
        prediction<- tryCatch(predict(model.percent, newx=testX, s="lambda.min", type="class"),
                              error=function(cond) {
                                message("Numerical instability in predict (cv.glmnet) detected. Will skip this 1-percent set. Original error:")
                                message(cond); cat("\n")
                                return(c(1,1))
                              })

        if (length(prediction)==2) {
          next
        }
      } else
        stop("Uknown method")

      end.time <- Sys.time()
      times[run] <- as.numeric(end.time)-as.numeric(start.time)
      cat("Ended: ", end.time,"elapsed: ", times[run],"\n")


      lengths[run]<-length(prediction[!is.na(prediction)])

      misclassification_error[run]<-mean(prediction[!is.na(prediction)] != data.test.percent.y[!is.na(prediction)])
      
      n_sizes<-c(n_sizes, n_size)
      p_sizes<-c(p_sizes, p_size)
      test_sizes<-c(test_sizes, test_size)

      if (model_choice=="cv.grLasso" | model_choice=="cv.MCP" )
        dfmin[run]<-sum(coef(model.percent)!=0)
      if (model_choice == "gic.DMRnet" | model_choice == "gic.PDMR")
        dfmin[run]<-gic$df.min
      
      if (model_choice == "cv.glmnet" )
        dfmin[run]<-sum(coef(model.percent, s="lambda.min")!=0)-1
      if (model_choice == "scope")
        dfmin[run]<-sum(abs(model.percent$beta.best[[1]]) > 1e-10) +
        sum(sapply(sapply(sapply(lapply(model.percent$beta.best[[2]], as.factor), levels), unique), length)-1)
      #  length(unique(c(sapply(sapply(model.10percent$beta.best[[2]], as.factor), levels), sapply(sapply(model.10percent$beta.best[[1]], as.factor), levels),recursive=TRUE)))-1 + #-1 is for "0" level
      #             -sum(sapply(sapply(model.10percent$beta.best[[2]], as.factor), levels)!="0")   #and we subtract the number of factors = number of constraints from eq. (8) in Stokell et al.
      #the commented formula above had problems with levels close to 0 but nonzero, like these:

      #[[91]]
      #0                    1
      #6.28837260041593e-18 6.28837260041593e-18
      #Levels: 6.28837260041593e-18

      #[[92]]
      #0                    1
      #6.28837260041593e-18 6.28837260041593e-18
      #Levels: 6.28837260041593e-18
      cat(run, "median = ", median(misclassification_error[misclassification_error>0]), "\n")
      cat(run, "df.min = ", mean(dfmin[misclassification_error>0]), "\n")
      cat(run, "lengths = ", mean(lengths[misclassification_error>0]), "\n")

      run<-run+1
    }

    cat("overall median = ", median(misclassification_error[misclassification_error!=0]), "\n")


    model_name<-model_choice
    if (model_choice == "scope")
      model_name<-paste(model_name, gamma, sep="-")

    if (model_choice == "cv.MCP-g")
      model_name<-paste(model_name, gamma, sep="-")


    computation_times[[model_name]]<-times
    effective_lengths[[model_name]]<-lengths
    if (length(dfmin[dfmin>0])>0)
      sizes[[model_name]]<-dfmin
    errors[[model_name]]<-misclassification_error


    
  }

  problem_sizes[["n"]]<-n_sizes
  problem_sizes[["p"]]<-p_sizes
  problem_sizes[["test_n"]]<-test_sizes

  write.csv(errors, paste("results", paste(set_name, "errors.csv", sep="_"), sep="/"))
  write.csv(sizes, paste("results", paste(set_name, "model_sizes.csv", sep="_"), sep="/"))
  write.csv(problem_sizes, paste("results", paste(set_name, "problem_sizes.csv", sep="_"), sep="/"))
  write.csv(computation_times, paste("results", paste(set_name, "computation_times.csv", sep="_"), sep="/"))
}



