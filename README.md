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
