##### Chapter 5: Rule Learners --------------------

## Example from the book "Machine Learning with R", by Brett Lantz

# identifying poisonous mushrooms with rule learners

# Step 1 – collecting data
################################################################################
#
# To identify rules for distinguishing poisonous mushrooms, we will use the Mushroom dataset
# by Jeff Schlimmer of Carnegie Mellon University. The raw dataset is available freely from the UCI
# Machine Learning Repository (http://archive.ics.uci.edu/ml).

# !!!
# This chapter uses a slightly modified version of the mushroom data. If you plan on
# following along with the example, download the mushrooms.csv file from the Packt
# Publishing GitHub repository for this chapter and save it to your R working directory.


# Step 2 – exploring and preparing the data
################################################################################

mushrooms <- read.csv(file.path("Chapter05", "mushrooms.csv"), stringsAsFactors = TRUE)


str(mushrooms)

#See some records
head(mushrooms)


#table(mushrooms$gill_spacing)
table(mushrooms$veil_type)
# partial 
#   8124     <- all records have the same value -> it does not provide information -> it can be removed:
mushrooms$veil_type <- NULL

# target variable
table(mushrooms$type)
# edible poisonous 
#   4208      3916 

# For the purposes of this experiment, we will consider the 8,214 samples in the mushroom data
# to be an exhaustive set of all the possible wild mushrooms. This is an important assumption
# because it means that we do not need to hold some samples out of the training data for testing
# purposes. We are not trying to develop rules that cover unforeseen types of mushrooms; we are
# merely trying to find rules that accurately depict the complete set of known mushroom types.
# Therefore, we can build and test the model on the same data.


# Step 3 – training a model on the data
################################################################################

# We will apply the 1R classifier, which will identify the single feature that is the most predictive of the target class and use this feature to construct a rule.
#
# We will use the 1R implementation found in the OneR package by Holger von Jouanne-Diedrich at the Aschaffenburg University of Applied Sciences.

install.packages("OneR")
library(OneR)

# Using the formula type ~ . with OneR() allows our first rule learner to consider all possible features in the mushroom data when predicting the mushroom type:
mushroom_1R <- OneR(type ~ ., data = mushrooms)

# To examine the rules it created:
mushroom_1R

# Call:
#   OneR.formula(formula = type ~ ., data = mushrooms)
# 
# Rules:
#   If odor = almond   then type = edible
# If odor = anise    then type = edible
# If odor = creosote then type = poisonous
# If odor = fishy    then type = poisonous
# If odor = foul     then type = poisonous
# If odor = musty    then type = poisonous
# If odor = none     then type = edible
# If odor = pungent  then type = poisonous
# If odor = spicy    then type = poisonous
# 
# Accuracy:
# 8004 of 8124 instances classified correctly (98.52%)

# Examining the output, we see that the odor feature was selected for rule generation. The categories of odor, such as almond, anise, and so on, 
# specify rules for whether the mushroom is likely to be edible or poisonous. For instance, if the mushroom smells fishy, foul, musty, pungent, 
# spicy, or like creosote, the mushroom is likely to be poisonous.
# 
# These rules could be summarized in # a simple rule of thumb: “if the mushroom smells unappetizing, then it is likely to be poisonous.”


# Step 4 – evaluating model performance
################################################################################

mushroom_1R_pred <- predict(mushroom_1R, mushrooms)

table(actual = mushrooms$type, predicted = mushroom_1R_pred)

#               predicted
# actual      edible poisonous
# edible      4208         0
# poisonous    120      3796

# It did classify 120 poisonous mushrooms as edible, which makes for an incredibly dangerous mistake!
# Considering that the learner utilized only a single feature, it did reasonably well.

# Step 5 – improving model performance
################################################################################

# For a more sophisticated rule learner, we will use JRip(), a Java-based implementation of the RIPPER algorithm. 
# The JRip() function is included in the RWeka package, which gives R access to the machine learning algorithms 
# in the Java-based Weka software application by Ian H. Witten and Eibe Frank.

install.packages("RWeka")
library(RWeka)

mushroom_JRip <- JRip(type ~ ., data = mushrooms)

mushroom_JRip

# JRIP rules:
# ===========
#   
# (odor = foul) => type=poisonous (2160.0/0.0)
# (gill_size = narrow) and (gill_color = buff) => type=poisonous (1152.0/0.0)
# (gill_size = narrow) and (odor = pungent) => type=poisonous (256.0/0.0)
# (odor = creosote) => type=poisonous (192.0/0.0)
# (spore_print_color = green) => type=poisonous (72.0/0.0)
# (stalk_surface_below_ring = scaly) and (stalk_surface_above_ring = silky) => type=poisonous (68.0/0.0)
# (habitat = leaves) and (cap_color = white) => type=poisonous (8.0/0.0)
# (stalk_color_above_ring = yellow) => type=poisonous (8.0/0.0)
# => type=edible (4208.0/0.0)
# 
# Number of Rules : 9    <- it must be an error, there are 8 rules (in the book it says 8 rules too -it does not consider the last "else" a rule)

# The numbers next to each rule indicate the number of instances covered by the rule and a count
# of misclassified instances. Notably, there were no misclassified mushroom samples using these
# eight rules. As a result, the number of instances covered by the last rule is exactly equal to the
# number of edible mushrooms in the data (N = 4,208).

# Thanks to Mother Nature, each variety of mushrooms was unique enough that the classifier was able to achieve 100 percent accuracy.