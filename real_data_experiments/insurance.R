
model_choices<-c( "gic.PDMR", "gic.DMRnet", "scope", "scope",
                  "cv.glmnet", #"RF",
                        #RANDOM FOREST wouldn't complete because of this error:
                             #Błąd w poleceniu 'randomForest.default(data.train.percent.x, y = data.train.percent.y)':
                             #Can not handle categorical predictors with more than 53 categories.
                  "cv.MCP", "cv.grLasso")


insurance.all<-read.csv("data_insurance/train.csv", header=TRUE, comment.char="|", stringsAsFactors = TRUE)
insurance.all<-insurance.all[,apply(apply(insurance.all,2,is.na), 2, sum)==0]  #removing columns with NA
insurance.all.x<-insurance.all[,2:(ncol(insurance.all)-1)]  #without ID and the response columns
insurance.all.y<-insurance.all[,ncol(insurance.all)] +0.0

factor_columns = (1:ncol(insurance.all.x))[-c(4, 8, 9, 10, 11)]

for (i in factor_columns) {
  insurance.all.x[,i] <- factor(insurance.all.x[,i])  #int->factors
}

cat("data loaded\n")

source("gaussian.R")

gaussian(insurance.all.x, insurance.all.y, factor_columns=factor_columns, model_choices=model_choices,
         set_name="insurance", train_percent=0.03)

