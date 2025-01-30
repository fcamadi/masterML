#Load data from CRAN package ISLR
#install.packages("ISLR")
library("ISLR")


## Export file
#write.csv(Carseats,file='Chapter05/carseats.csv',na='') 

#install.packages("C50")  # Decision trees C5.0 algorithm
library(C50)

#install.packages("caret")  # data partitioning, confusion matrix
library(caret)  


sales_mean <- mean(Carseats$Sales)  # mean and median are almost the same
Carseats$SalesFactor <- factor(ifelse(Carseats$Sales>sales_mean,"Yes","No"))

CarseatsNew <- Carseats[-1]

## Export file
#write.csv(CarseatsNew,file='Chapter05/carseatsNew.csv',na='') 

set.seed(9)
#partitioning data frame into training (75%) and testing (25%) sets
train_indices <- createDataPartition(CarseatsNew$SalesFactor, times=1, p=.75, list=FALSE)
#create training set
CarseatsNew_train <- CarseatsNew[train_indices, ]
#create testing set
CarseatsNew_test  <- CarseatsNew[-train_indices, ]
#create labels sets
CarseatsNew_train_labels <- CarseatsNew[train_indices, ]$SalesFactor
CarseatsNew_test_labels <- CarseatsNew[-train_indices, ]$SalesFactor

sales_model <- C5.0(SalesFactor ~ ., data = CarseatsNew_train)
sales_model

#plotting the model
plot(sales_model)

