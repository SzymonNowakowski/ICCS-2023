
library(DAAG)

run_list = c( "gic.PDMR", "gic.DMRnet", "scope", "scope",  "cv.glmnet", "RF", "cv.MCP", "cv.grLasso")

data(antigua)
antigua[,"plot"] <- factor(antigua[,"plot"])
antigua[antigua[,6] == -9999,6] = NA
antigua <- na.omit(antigua)
antigua.all.x <- antigua[, -c(1,7)]
cont_columns<-c(3,5)
antigua.all.y<-antigua[,ncol(antigua)] +0.0

cat("data loaded\n")

source("gaussian.R")

gaussian(antigua.all.x, antigua.all.y, factor_columns=c(1,2,3,4), model_choices=run_list,
         set_name="antigua", train_percent=0.7)

