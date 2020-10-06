# Ames Housing Data

In this project, I use R and Rstudio to predict the price of Ames houses using Lasso Regression and XGBoost based on dozens of variables. In this report there will be totally four sections, describing which techniques I’ve used to preprocess the data, some interesting findings on the data, computer configuration, running time of the code as well as the test accuracy of 10 cross validations.

Ames_data.csv, from the Resouces page. The dataset has 2930 rows (i.e., houses) and 83 columns.

* The first column is “PID”, the Parcel identification number;
* The last column is the response variable, Sale_Price;
* The remaining 81 columns are explanatory variables describing (almost) every aspect of residential homes.

## Preprocessing

* Winsorization
* Vairable Removal
* One-Hot Encoding
* Missing Value

There are a few techniques that I have used to pre-process the data. First of all, I removed some of variables from the dataset as those variables do NOT play an important role in prediction. For example, `Pool_Area` is extremely imbalanced: the majority portion of this variable is actually 0 because the most houses do not have a pool attached with them. Therefore, 0 was put in the cell. However, since we have so many 0 in the variable, it will play a trivial role in the prediction. Second, I also remove some outliers from continuous and numerical variables. These outliers, though occupying only a very small portion, will impose a very dramatic and unfair impact on the final prediction result. Suggested by Professor Liang on Piazza, I used Winsorization and replace any outliers beyond it with 95th percentile data. In this way, the unfair outlier effect will be mitigated. One-hot encoding also has been used in the project. All of the categorical data has been one-hot encoded so that each category will have an independent variable with binary indicator. For example, variable `Electrical` has 6 categories: `SBrkr`, `FuseA`, `FuseF`, `FuseP`, `Unknown` and `Mix`. If the observation has the categories of `Mix`, the new variable `Mix` then will show 1. There are also some of missing values in `Garage_Yr_Blt`. I followed the suggestion and set all of them to be 0.

## Models & Modeling Techniques

* Cross-Validation of GLMNET
* Lasso
* Feature Selection with Lambda_1se
* XGBoost
* Measurement Typ

First of all, i used `cv.glmnet` with `alpha = 1` to find the best lambda value through a 10 fold cross validation. After fitting the model, we are able to find features that have been removed due to the nature of Lasso Regression model with lambda 1se. I recorded the selected variables and constructed a new training data set based on these selected variables. Then I fit the model again on the same but smaller data set and predict the result based on the lambda_min. XGBoost is the second model used in the project. The standard procedures of data preprocessing for Lasso are also used in the model. I used the suggested hyper-parameters on Pizza, and achieved the performance that is similar to the result in the thread. Additionally, I also used MAE as the measurement type, which improves the performance slightly.

## Findings

There are a fair amount of imbalanced data that is hard to deal with and basically provided trivial value to prediction. As we discussed above, `Pool_Area` has more than 90% of 0 in the variable. Also, we found some of these variables are highly correlated with each other. For example, `Garage Quality` and `Garage Condition` is highly correlated, and one of them will be required. However, it won't be a huge issue in our project as I choose to use Lasso and XGBoost to perform the prediction.

## Computer Configuration

* MacBook Pro
* 6-Core Intel Core i7, 2.6 GHz
* 16 GB Memory

## Running Time

This run time refers to the 1 cross validation run time. I used 2 Sys.time() function to calculate the difference between the start time and end time.
Time difference of 2.468 mins

## Test Accuracy of 10 CV's

Here are 10 CV's for each model. Each split between training and testing set was iterated based on the provided index from `project1_testIDs.dat`. Each column of the "index" matrix is iterated to extract the relevant training and testing set. Therefore, you will see 20 RMSE here.
Time difference of 2.468 mins


