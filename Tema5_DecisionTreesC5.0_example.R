##### Chapter 5: Decision Trees --------------------

## Example from the book "Machine Learning with R", by Brett Lantz

# identifying risky bank loans using C5.0 decision trees

# Step 1 – collecting data
################################################################################
#
#Data with these characteristics are available in a dataset donated to the UCI Machine Learning
#Repository (http://archive.ics.uci.edu/ml) by Hans Hofmann of the University of Hamburg.
#The dataset contains information on loans obtained from a credit agency in Germany.


# Step 2 – exploring and preparing the data
################################################################################

credit <- read.csv(file.path("Chapter05", "credit.csv"), stringsAsFactors = TRUE)


#See the structure
str(credit)


#See some records
head(credit)

#Let’s take a look at the table() output for a couple of loan features that seem likely to predict a default. 
#The applicant’s checking and savings account balances are recorded as categorical variables:

table(credit$checking_balance)
#    < 0 DM   > 200 DM   1 - 200 DM    unknown 
#       274         63          269        394 

table(credit$savings_balance)
#  < 100 DM   > 1000 DM    100 - 500 DM   500 - 1000 DM       unknown 
#       603         48              103              63           183

# Some of the loan’s features are numeric, such as its duration and the amount of credit requested:

summary(credit$months_loan_duration)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#     4.0    12.0    18.0    20.9    24.0    72.0 

summary(credit$amount)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    250    1366    2320    3271    3972   18424 

#The loan amounts ranged from 250 DM to 18,420 DM across terms of 4 to 72 months. They had a median amount of 2,320 DM and a median duration of 18 months.

# target variable
table(credit$default)
#  no yes 
# 700 300 


#Data preparation – creating random training and test datasets
# (Data is ordered, so we must create training and test datasets not by simply splitting the original data set)

set.seed(9829)
train_sample <- sample(1000, 900)
# str(train_sample)
# int [1:900] 653 866 119 152 6 617 250 343 367 138    <- we have a random sequence of indexes now

#and we can use it to create the two sets
credit_train <- credit[train_sample, ]
credit_test <- credit[-train_sample, ]

#Check the randomization was done correctly
prop.table(table(credit_train$default))
#        no       yes 
# 0.7055556 0.2944444 
prop.table(table(credit_test$default))
#   no  yes 
# 0.65 0.35  

# Both the training and test datasets have roughly similar distributions of loan defaults,
# so we can now build our decision tree.


# Step 3 – training a model on the data
################################################################################

# We will use the C5.0 algorithm in the C50 package for training our decision tree model.

#install.packages("C50")
library(C50)

# For the first iteration of the credit approval model, we’ll use the default C5.0 settings

# The target class is named default, so we put it on the left-hand side of the tilde, which is followed by a period 
# indicating that all other columns in the credit_train data frame are to be used as predictors:
credit_model <- C5.0(default ~ ., data = credit_train)

credit_model

# Call:
#   C5.0.formula(formula = default ~ ., data = credit_train)
# 
# Classification Tree
# Number of samples: 900 
# Number of predictors: 16 
# 
# Tree size: 67 
# 
# Non-standard options: attempt to group attributes

# The output shows some simple facts about the tree, including the function call that generated it,
# the number of features (labeled predictors), and examples (labeled samples) used to grow the
# tree. Also listed is the tree size of 67, which indicates that the tree is 67 decisions deep—quite a
# bit larger than the example trees we’ve considered so far!


# To see the tree’s decisions, we can call the summary() function on the model:

summary(credit_model)

# Call:
#   C5.0.formula(formula = default ~ ., data = credit_train)
# 
# 
# C5.0 [Release 2.07 GPL Edition]  	Mon Jan 27 18:52:04 2025
# -------------------------------
#   
#   Class specified by attribute `outcome'
# 
# Read 900 cases (17 attributes) from undefined.data
# 
# Decision tree:
# 
# checking_balance in {> 200 DM,unknown}: no (415/55)     <- If the checking account balance is unknown or greater than 200 DM, then classify as “not likely to default”
# checking_balance in {< 0 DM,1 - 200 DM}:                  <- Otherwise, if the checking account balance is less than zero DM or between one and 200 DM ...   
# :...credit_history in {perfect,very good}: yes (59/16)      <- ... and the credit history is perfect or very good, then classify as “likely to default”
# 
# The numbers in parentheses indicate the number of examples meeting the criteria for that decision and the number incorrectly classified by the decision. 
# For instance, on the first line, 415/55 indicates that of the 415 examples reaching the decision, 55 were incorrectly classified as “not likely to default.”
# 
# After the tree, the summary(credit_model) output displays a confusion matrix

# plot(credit_model) -> it plots a huuuuuge diagram



# Step 4 – evaluating model performance
################################################################################

credit_pred <- predict(credit_model, credit_test)


library(gmodels)

CrossTable(credit_test$default, credit_pred, prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actual default', 'predicted default'))

# Total Observations in Table:  100 
# 
# 
#                  | predicted default 
#   actual default |        no |       yes | Row Total | 
#   ---------------|-----------|-----------|-----------|
#               no |        56 |         9 |        65 | 
#                  |     0.560 |     0.090 |           | 
#   ---------------|-----------|-----------|-----------|
#              yes |        24 |        11 |        35 | 
#                  |     0.240 |     0.110 |           | 
#   ---------------|-----------|-----------|-----------|
#     Column Total |        80 |        20 |       100 | 
#   ---------------|-----------|-----------|-----------|

# Step 5 – improving model performance
################################################################################

# One way the C5.0 algorithm improved upon the C4.5 algorithm was through the addition of
# adaptive boosting. This is a process in which many decision trees are built, and the trees vote
# on the best class for each example.

# boosting is rooted in the notion that by combining several weak-performing learners, you
# can create a team that is much stronger than any of the learners alone

# The C5.0() function makes it easy to add boosting to our decision tree. We simply need to add
# an additional trials parameter indicating the number of separate decision trees to use in the
# boosted team. The trials parameter sets an upper limit; the algorithm will stop adding trees
# if it recognizes that additional trials do not seem to be improving the accuracy. We’ll start with
# 10 trials, a number that has become the de facto standard, as research suggests that this reduces
# error rates on test data by about 25 percent.

credit_model_boost <- C5.0(default ~ ., data = credit_train, trials = 10)

credit_model_boost

summary(credit_model_boost)

# boost	         19( 2.1%)   <<
#   
#   
#   (a)   (b)    <-classified as
#  ----  ----
#   633     2    (a): class no
#    17   248    (b): class yes
#
#
# before (without boosting):
#
#    Size     Errors
#      66        118 (13.1%)  <<
# 
#   (a)   (b)    <-classified as
#  ----  ----
#   604    31    (a): class no
#    87   178    (b): class yes  
# 

credit_boost_pred <- predict(credit_model_boost, credit_test)

CrossTable(credit_test$default, credit_boost_pred, prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actual default', 'predicted default'))


# Total Observations in Table:  100 
# 
# 
#                  | predicted default 
#   actual default |        no |       yes | Row Total | 
#   ---------------|-----------|-----------|-----------|
#               no |        58 |         7 |        65 | 
#                  |     0.580 |     0.070 |           | 
#   ---------------|-----------|-----------|-----------|
#              yes |        19 |        16 |        35 | 
#                  |     0.190 |     0.160 |           | 
#   ---------------|-----------|-----------|-----------|
#     Column Total |        77 |        23 |       100 | 
#   ---------------|-----------|-----------|-----------|

# accuracy:  74 %   

# We reduced the total error rate from 33 percent prior to boosting to 26 percent in the boosted model.

# On the other hand, the model is still doing poorly at identifying the true defaults, predicting only
# 46 percent correctly (16 out of 35) compared to 31 percent (11 of 35) in the simpler model. Let’s
# investigate one more option to see if we can reduce these types of costly errors.

# Cost matrix
# 
# The C5.0 algorithm allows us to assign a penalty to different types of errors in order to discourage
# a tree from making more costly mistakes. The penalties are designated in a cost matrix

matrix_dimensions <- list(c("no", "yes"), c("no", "yes"))
names(matrix_dimensions) <- c("predicted", "actual")

matrix_dimensions

# $predicted
# [1] "no"  "yes"
# 
# $actual
# [1] "no"  "yes"

# Next, we need to assign the penalty for the various types of errors by supplying four values to fill the matrix.
# Since R fills a matrix by filling columns one by one from top to bottom, we need to supply the values in a specific order:
# 
# 1. Predicted no, actual no
# 2. Predicted yes, actual no
# 3. Predicted no, actual yes
# 4. Predicted yes, actual yes

# Suppose we believe that a loan default costs the bank four times as much as a missed opportunity.
# Our penalty values then could be defined as:
error_cost <- matrix(c(0, 1, 4, 0), nrow = 2, dimnames = matrix_dimensions)

error_cost
#           actual
# predicted no yes
#       no   0   4
#       yes  1   0

# As defined by this matrix, there is no cost assigned when the algorithm classifies a no or yes
# correctly, but a false negative has a cost of 4 versus a false positive’s cost of 1. To see how this
# impacts classification, let’s apply it to our decision tree using the costs parameter of the C5.0() function.


credit_cost <- C5.0(default ~ ., data = credit_train, costs = error_cost)

credit_cost_pred <- predict(credit_cost, credit_test)

CrossTable(credit_test$default, credit_cost_pred, prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actual default', 'predicted default'))

# Compared to our boosted model, this version makes more mistakes overall: 36 percent error here
# versus 26 percent in the boosted case. However, the types of mistakes are very different. Where
# the previous models classified only 31 and 46 percent of defaults correctly, in this model, 30 / 35 = 86% 
# of the actual defaults were correctly predicted to be defaults. This trade-off resulting in a
# reduction of false negatives at the expense of increasing false positives may be acceptable if our
# cost estimates were accurate.


#############################################
# boosting and cost matrix at the same time #
#############################################

credit_cost_boost <- C5.0(default ~ ., data = credit_train, costs = error_cost, trials = 10)

credit_cost_boost_pred <- predict(credit_cost_boost, credit_test)

CrossTable(credit_test$default, credit_cost_boost_pred, prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actual default', 'predicted default'))

Total Observations in Table:  100 


#                  | predicted default 
#   actual default |        no |       yes | Row Total | 
#   ---------------|-----------|-----------|-----------|
#               no |        58 |         7 |        65 | 
#                  |     0.580 |     0.070 |           | 
#   ---------------|-----------|-----------|-----------|
#              yes |        22 |        13 |        35 | 
#                  |     0.220 |     0.130 |           | 
#   ---------------|-----------|-----------|-----------|
#     Column Total |        80 |        20 |       100 | 
#   ---------------|-----------|-----------|-----------|

# accuracy: 71 %  (worse than only boosting)
