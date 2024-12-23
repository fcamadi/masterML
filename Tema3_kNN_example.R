##### Chapter 3: Classification using Nearest Neighbors --------------------

## Example from the book "Machine Learning with R", by Brett Lantz

# Classifying Cancer Samples
# 
# The breast cancer data includes 569 examples of cancer biopsies, each with 32 features. 
# One feature is an identification number, another is the cancer diagnosis, and 30 are 
# numeric-valued  laboratory measurements. 
# The diagnosis is coded as “M” to indicate malignant or “B” to indicate benign.


## Step 2: Exploring and preparing the data 
################################################################################
# import the CSV file
wbcd <- read.csv(file.path("Chapter03", "wisc_bc_data.csv"))

str(wbcd)

# remove the id
wbcd <- wbcd[-1]

# The diagnosis feature is of particular interest as it is the target outcome we want to predict
table(wbcd$diagnosis)
#   B   M 
# 357 212 

round(prop.table(table(wbcd$diagnosis))*100, digits = 2)
# Benign Malignant 
#  62.74     37.26 

# Many R machine learning classifiers require the target feature to be coded as a factor, 
# so we will need to recode the diagnosis column. 
# We will also take this opportunity to give the values more informative labels using the labels parameter
wbcd$diagnosis <- factor(wbcd$diagnosis, levels = c("B", "M"),
                         labels = c("Benign", "Malignant"))

# We will only take a closer look at three of the other 30 features:
summary(wbcd[c("radius_mean", "area_mean", "smoothness_mean")])

#  The distance calculation for k-NN is heavily dependent upon the measurement scale of the
# input features. Smoothness ranges from 0.05 to 0.16, while area ranges from 143.5 to 2501.0,
# so the impact of area is going to be much greater than smoothness in the distance calculation. 
# This # could potentially cause problems for our classifier, so let’s apply normalization

# create normalization function
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

# test normalization function - result should be identical
normalize(c(1, 2, 3, 4, 5))
normalize(c(10, 20, 30, 40, 50))
# normalize(c(1, 2, 3, 4, 5))
# [1] 0.00 0.25 0.50 0.75 1.00
# normalize(c(10, 20, 30, 40, 50))
# [1] 0.00 0.25 0.50 0.75 1.00


#  We can now apply the normalize() function to the numeric features in our data frame. Rather
# than normalizing each of the 30 numeric variables individually, we will use one of R’s functions
# to automate the process: lapply

wbcd_n <- as.data.frame(lapply(wbcd[2:31], normalize))
#str(wbcd_n)
summary(wbcd_n$area_mean)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.0000  0.1174  0.1729  0.2169  0.2711  1.0000   <- now they are between 0 and 1
#summary(wbcd$area_mean)

# Create training and test data
wbcd_train <- wbcd_n[1:469, ]
wbcd_test <- wbcd_n[470:569, ]

#  Create labels for training and test data
# When we constructed our normalized training and test datasets, we excluded the target variable,
# diagnosis. For training the k-NN model, we will need to store these class labels in factor vectors,
# split between the training and test datasets:
wbcd_train_labels <- wbcd[1:469, 1]
wbcd_test_labels <- wbcd[470:569, 1]


## Step 3: Training a model on the data 
################################################################################
#  For the k-NN algorithm, the training phase involves no model building; the process of training a
# so-called “lazy” learner like k-NN simply involves storing the input data in a structured format.
#
# To classify our test instances, we will use a k-NN implementation from the class package, which
# provides a set of basic R functions for classification. If this package is not already installed on
# your system, you can install it by typing install.packages("class")

# install and load the "class" library
#install.packages("class")
library(class)

# And call the function knn:
#> ?knn
wbcd_pred_k_11 <- knn(train = wbcd_train, test = wbcd_test, cl = wbcd_train_labels, k = 11)
wbcd_pred_k_21 <- knn(train = wbcd_train, test = wbcd_test, cl = wbcd_train_labels, k = 21)

#sum(wbcd_pred_k_10==wbcd_pred_k_21) # -> 2 different predictions out of 100
sum(wbcd_pred_k_11!=wbcd_pred_k_21) # -> only 1 different predictions out of 100

#sum(wbcd_pred_k_11!=wbcd_test_labels)  # 3 errores
sum(wbcd_pred_k_21!=wbcd_test_labels)   # 2 errores

## Step 4 – evaluating model performance
################################################################################
# The next step of the process is to evaluate how well the predicted classes in the wbcd_test_pred
# vector match the actual values in the wbcd_test_labels vector. To do this, we can use the
# CrossTable() function in the gmodels package

install.packages("gmodels")
library(gmodels)

CrossTable(x = wbcd_test_labels, y = wbcd_pred_k_21, prop.chisq = FALSE)
#
# 
# Total Observations in Table:  100 
# 
# 
#                    |wbcd_pred_k_21 
#   wbcd_test_labels |    Benign | Malignant | Row Total | 
#   -----------------|-----------|-----------|-----------|
#             Benign |        61 |         0 |        61 | 
#                    |     1.000 |     0.000 |     0.610 | 
#                    |     0.968 |     0.000 |           | 
#                    |     0.610 |     0.000 |           | 
#   -----------------|-----------|-----------|-----------|
#          Malignant |         2 |        37 |        39 | 
#                    |     0.051 |     0.949 |     0.390 | 
#                    |     0.032 |     1.000 |           | 
#                    |     0.020 |     0.370 |           | 
#   -----------------|-----------|-----------|-----------|
#       Column Total |        63 |        37 |       100 | 
#        |     0.630 |     0.370 |           | 
#   -----------------|-----------|-----------|-----------|

#  The two examples in the lower-left cell are false negative results;
# in this case, the predicted value was benign, but the tumor was actually malignant. 
# Errors in this direction could be extremely costly, as they might lead a patient 
# to believe that they are cancer-free, but in reality, the disease may continue to spread.
#
# The top-right cell would contain the false positive results, if there were any. These values occur
# when the model has classified a mass as malignant when it actually was benign.

# A total of 2 out of 100, or 2 percent of masses were incorrectly classified by the k-NN approach.
# While 98 percent accuracy seems impressive for a few lines of R code, we might try another it-
#  eration of the model to see if we can improve the performance and reduce the number of values
# that have been incorrectly classified


## Step 5: Improving model performance
################################################################################

#  Although normalization is commonly used for k-NN classification, z-score standardization may
# be a more appropriate way to rescale the features in a cancer dataset.

# To standardize a vector, we can use R’s built-in scale() function, which by default rescales values
# using the z-score standardization.

# use the scale() function to z-score standardize a data frame
wbcd_z <- as.data.frame(scale(wbcd[-1]))

# confirm that the transformation was applied correctly
summary(wbcd_z$area_mean)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# -1.4532 -0.6666 -0.2949  0.0000  0.3632  5.2459 

# The mean of a z-score standardized variable should always be zero, and the range should be fairly
# compact. A z-score less than -3 or greater than 3 indicates an extremely rare value. Examining
# the summary statistics with these criteria in mind, the transformation seems to have worked.

# We repeat the same steps (divide in train and test sets, labels ...)
wbcd_z_train <- wbcd_z[1:469, ]
wbcd_z_test <- wbcd_z[470:569, ]

wbcd_z_train_labels <- wbcd[1:469, 1]
wbcd_z_test_labels <- wbcd[470:569, 1]

wbcd_z_pred <- knn(train = wbcd_z_train, test = wbcd_z_test, cl = wbcd_z_train_labels, k = 21)
CrossTable(x = wbcd_test_labels, y = wbcd_z_pred, prop.chisq = FALSE)
#
# Total Observations in Table:  100 
# 
#                    | wbcd_z_pred 
#   wbcd_test_labels |    Benign | Malignant | Row Total | 
#   -----------------|-----------|-----------|-----------|
#             Benign |        61 |         0 |        61 | 
#                    |     1.000 |     0.000 |     0.610 | 
#                    |     0.924 |     0.000 |           | 
#                    |     0.610 |     0.000 |           | 
#   -----------------|-----------|-----------|-----------|
#          Malignant |         5 |        34 |        39 | 
#                    |     0.128 |     0.872 |     0.390 | 
#                    |     0.076 |     1.000 |           | 
#                    |     0.050 |     0.340 |           | 
#   -----------------|-----------|-----------|-----------|
#       Column Total |        66 |        34 |       100 | 
#                    |     0.660 |     0.340 |           | 
#   -----------------|-----------|-----------|-----------|


# It turns out the result is worse now. Now the number of false negatives is 5, not 2


# Testing alternative values of k

k_values <- c(1, 5, 11, 15, 21, 27)
for (k_val  in k_values) {
  wbcd_pred <- knn(train = wbcd_train,
                        test = wbcd_test,
                        cl = wbcd_train_labels,
                        k = k_val)
  CrossTable(x = wbcd_test_labels, y = wbcd_pred, prop.chisq = FALSE)
}
# Results:
#  The false negatives, false positives, and overall error rate are shown for each iteration:
#  k value   | False negatives  | False positives  |   Error rate
#     1              1                    3             4 percent
#     5              2                    0             2 percent
#    11              3                    0             3 percent
#    15              3                    0             3 percent
#    21              2                    0             2 percent
#    27              4                    0             4 percent

