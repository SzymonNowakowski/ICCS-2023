
adult.train<-read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data", header=FALSE, comment.char="|", stringsAsFactors = TRUE)
adult.test<-read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.test", header=FALSE, comment.char="|", stringsAsFactors = TRUE)

colnames <- c('age', #
              'workclass', #
              'fnlwgt',
              'education', #
              'education_num',
              'marital_status', #
              'occupation', #
              'relationship', #
              'race', #
              'sex', #
              'capital_gain',
              'capital_loss',
              'hours_per_week',
              'native_country', #
              'income') #
colnames(adult.train)<-colnames
colnames(adult.test)<-colnames
adult.train<-subset(adult.train, adult.train[,14] != " ?")
adult.train<-subset(adult.train, adult.train[,7] != " ?")
adult.train<-subset(adult.train, adult.train[,2] != " ?")
adult.train[,14] <- factor(adult.train[,14])
adult.train[,7] <- factor(adult.train[,7])
adult.train[,2] <- factor(adult.train[,2])
adult.train[,1] <- adult.train[,1] + 0.0  #make a continuous variable out of an integer. Otherwise scope would treat it as a factor
adult.train[,13] <- adult.train[,13] + 0.0

adult.test<-subset(adult.test, adult.test[,14] != " ?")
adult.test<-subset(adult.test, adult.test[,7] != " ?")
adult.test<-subset(adult.test, adult.test[,2] != " ?")
adult.test[,14] <- factor(adult.test[,14])
adult.test[,7] <- factor(adult.test[,7])
adult.test[,2] <- factor(adult.test[,2])
adult.test[,1] <- adult.test[,1] + 0.0  #make a continuous variable out of an integer. Otherwise scope would treat it as a factor
adult.test[,13] <- adult.test[,13] + 0.0

#consiliation of different level names in train and test sets (they end with '.' in test set)
levels(adult.test[,15])[1]<-0
levels(adult.test[,15])[2]<-1
levels(adult.train[,15])[1]<-0
levels(adult.train[,15])[2]<-1


adult.all<-rbind(adult.train, adult.test)
####HURRAY. In total 45222 observations (train+test) as in Stokell's paper

cat("data loaded\n")



model_choices<-c( "gic.PDMR","gic.DMRnet", "scope", "scope",
               "cv.glmnet", "RF",
                  "cv.MCP", "cv.grLasso")


source("binomial.R")

binomial(adult.all[,c(1,2,4,6:10,13:14), drop=FALSE],  #I exclude education_num and fnlwgt and capital_gain & capital_loss)
         adult.all[,15], factor_columns=c(2:8,10), model_choices=model_choices,
         set_name="adult", train_percent=0.01)
