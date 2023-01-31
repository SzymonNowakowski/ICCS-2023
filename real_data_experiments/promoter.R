
library(DMRnet)

data("promoter")

cat("data loaded\n")


model_choices<-c( "gic.PDMR", "gic.DMRnet", "scope", "scope",
                  "cv.glmnet", "RF",
                  "cv.MCP", "cv.grLasso")


source("binomial.R")

binomial(promoter[,2:58, drop=FALSE],
         promoter[,1], factor_columns=c(1:57), model_choices=model_choices,
         set_name="promoter", train_percent=0.7)
