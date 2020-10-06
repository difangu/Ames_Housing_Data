library(xgboost)
library(glmnet)

if(T == F){
  data <- read.csv("Ames_data.csv")
  testIDs <- read.table("project1_testIDs.dat")
  j <- 2
  train <- data[-testIDs[,j], ]
  test <- data[testIDs[,j], ]
  test.y <- test[, c(1, 83)]
  test <- test[, -83]
  write.csv(train,"train.csv",row.names=FALSE)
  write.csv(test, "test.csv",row.names=FALSE)
  write.csv(test.y,"test_y.csv",row.names=FALSE)
}

train <- read.csv("train.csv")
test <- read.csv("test.csv")

new_train = train[, -which(colnames(train) %in% c("PID"))]
new_test = test[, -which(colnames(train) %in% c("PID"))]

sum(colnames(new_train) %in% colnames(new_test) == FALSE)
preprocessing = function(df){
  remove.var <- c('Street', 'Utilities',  'Condition_2', 'Roof_Matl', 'Heating', 'Pool_QC', 'Misc_Feature', 'Low_Qual_Fin_SF', 'Pool_Area', 'Longitude','Latitude')
  winsor.vars <- c("Lot_Frontage", "Lot_Area", "Mas_Vnr_Area", "BsmtFin_SF_2", "Bsmt_Unf_SF", "Total_Bsmt_SF", "Second_Flr_SF", 'First_Flr_SF', "Gr_Liv_Area", "Garage_Area", "Wood_Deck_SF", "Open_Porch_SF", "Enclosed_Porch", "Three_season_porch", "Screen_Porch", "Misc_Val")
  df[, which(colnames(df) %in% remove.var)] = NULL
  df$Garage_Yr_Blt[is.na(df$Garage_Yr_Blt)] = 0
  quan.value <- 0.95
  for(var in winsor.vars){
    tmp <- df[, var]
    myquan <- quantile(tmp, probs = quan.value, na.rm = TRUE)
    tmp[tmp > myquan] <- myquan
    df[, var] <- tmp
  }  
  return(df)
}

train.x = preprocessing(df = new_train)
test.x = preprocessing(df = new_test)
sum(colnames(train.x) %in% colnames(test.x) == FALSE)

processing2 = function(df){
  categorical.vars <- colnames(df)[
    which(sapply(df,
                 function(x) mode(x)=="character"))]
  train.matrix <- df[, !colnames(df) %in% categorical.vars, 
                          drop=FALSE]
  n.train <- nrow(train.matrix)
  for(var in categorical.vars){
    mylevels <- sort(unique(train.x[, var]))
    m <- length(mylevels)
    m <- ifelse(m>2, m, 1)
    tmp.train <- matrix(0, n.train, m)
    col.names <- NULL
    for(j in 1:m){
      tmp.train[df[, var]==mylevels[j], j] <- 1
      col.names <- c(col.names, paste(var, '_', mylevels[j], sep=''))
    }
    colnames(tmp.train) <- col.names
    train.matrix <- cbind(train.matrix, tmp.train)
  }
  return(train.matrix)
}

RMSE = function(actual, pred){
  return(sqrt(mean((actual-pred)^2)))
}

train_data_matrix = processing2(train.x)
test_data_matrix = processing2(test.x)
colnames(train_data_matrix) %in% colnames(test_data_matrix)

#train_data_matrix_1 = model.matrix(Sale_Price~(.), data = as.data.frame(train_data_matrix))
#test_data_matrix_1 = model.matrix(test.y[,2]~(.), data = as.data.frame(test_data_matrix))

train.x = train_data_matrix[, -which(colnames(train_data_matrix) == "Sale_Price")]
train.y = as.vector(train_data_matrix$Sale_Price)
test.x = test_data_matrix

train.x = as.matrix(train.x)
train.y = as.matrix(train.y)
test.x = as.matrix(test.x)
# Lasso, using built-in CV to find the optimal lambda
# first fit 
mylasso = cv.glmnet(
                   x = train.x,
                   y = log(train.y),
                   alpha = 1, 
                   nfolds = 10, 
                   standardize = T,
                   type.measure = "mae")

pred = predict(mylasso, test.x, s = mylasso$lambda.1se, type = "coefficients")

var.sel = pred[as.vector(pred[,1]!=0),1][-1]

new_train = as.matrix(train.x[, colnames(train.x) %in% names(var.sel)])
new_test = as.matrix(test.x[, colnames(test.x) %in% names(var.sel)])

refit.mylasso = cv.glmnet(x = as.matrix(new_train), 
                          y = log(train.y),
                          alpha = 1, 
                          nfolds = 10, 
                          standardize = T,
                          type.measure = "mae")

refit.pred = predict(refit.mylasso, s = refit.mylasso$lambda.min, as.matrix(new_test))

#print(RMSE(as.vector(refit.pred), log(test.y[,2])))

xgb_model = xgboost(data = train.x, label = train.y, max_depth = 5,
                    eta = 0.05, nrounds = 5000,
                    subsample = 0.5,
                    verbose = FALSE)
xgb.pred = predict(xgb_model, as.matrix(test.x))

#print(RMSE(log(xgb.pred), log(test.y[,2])))

mysubmission1.txt = data.frame(PID = test$PID, Sale_Price = exp(refit.pred))
mysubmission2.txt = data.frame(PID = test$PID, Sale_Price = exp(xgb.pred))
colnames(mysubmission1.txt) = c("PID", "Sale_Price")
colnames(mysubmission2.txt) = c("PID", "Sale_Price")

write.table(mysubmission1.txt, file = "mysubmission1.txt", sep = ",", row.names = F, col.names = T)
write.table(mysubmission2.txt, file = "mysubmission2.txt", sep = ",", row.names = F, col.names = T)