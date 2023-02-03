
air_y_tr <- read.csv("data_airbnb/data_cleaned_test_y.csv")
air_y_te <- read.csv("data_airbnb/data_cleaned_train_y.csv")
air_y_val <- read.csv("data_airbnb/data_cleaned_val_y.csv")

air_X_tr <- read.csv("data_airbnb/data_cleaned_test_comments_X.csv")
air_X_te <- read.csv("data_airbnb/data_cleaned_train_comments_X.csv")
air_X_val <- read.csv("data_airbnb/data_cleaned_val_comments_X.csv")

air_y<-rbind(air_y_tr, air_y_val, air_y_te)[,1]
air_X<-rbind(air_X_tr, air_X_val, air_X_te)

for (i in 1:4)
  air_X[,i] <- factor(air_X[,i])



####HURRAY. In total 49976 observations (train+test) + host_id factor with 39393 levels as in Rosset's paper
########I didn't perform variable selection step as DMRnet does that too but better. 

# out of those 768 columns 
# there is one constant categorical column (country) with only 1 level and 2 continous constant columns (with sd=0), 
# so 765 predictive columns in total  

cat("data loaded\n")


model_choices<-c( "gic.PDMR", "gic.DMRnet", #"scope", "scope",
                                 # SCOPE wouldn't complete because of this or similar error
                                 #  (for all gammas = 8, 32, 100,250)
                                    #Numerical instability in SCOPE detected. Will skip this 1-percent set. Original error:
                                    #procedura Lapack dgesv: system jest dokładnie osobliwy: U[414,414] = 0
                  "cv.glmnet", #"RF",
                                 #RANDOM FOREST wouldn't complete because of this error:
                                    #Błąd w poleceniu 'randomForest.default(airbnb.train.5percent.x, y = airbnb.train.5percent.y)':
                                    #Can not handle categorical predictors with more than 53 categories.
                  "cv.MCP", "cv.grLasso")


source("gaussian.R")

gaussian(air_X, air_y, factor_columns=1:4, model_choices=model_choices,
         set_name="airbnb", train_percent=0.02)
