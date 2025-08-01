##### Chapter 4: Naive Bayes --------------------

## Example from the book "Machine Learning with R", by Brett Lantz

# Filtering mobile phone spam with the Naive Bayes algorithm
# 
# Since Naive Bayes has been used successfully for email spam filtering, it seems likely that it could
# also be applied to SMS spam. However, relative to email spam, SMS spam poses additional challenges 
# for automated filters. SMS messages are often limited to 160 characters, reducing the
# amount of text that can be used to identify whether a message is junk.


# Step 2: Exploring and preparing the data 
################################################################################
# import the CSV file
sms_raw <- read.csv(file.path("Chapter04", "sms_spam.csv"))


#See the structure
str(sms_raw)


#See some records
head(sms_raw)

#The type element is currently a character vector. Since this is a categorical variable, it would be
#better to convert it into a factor
sms_raw$type <- factor(sms_raw$type)
# Now -> $ type: Factor w/ 2 levels "ham","spam": 1 1 1 2

table(sms_raw$type)
#  ham spam 
#  4812  747 

# For now, we will leave the message text alone. As you will learn in the next section, processing
# raw SMS messages will require the use of a new set of powerful tools designed specifically for
# processing text data.

################################################################################
#        Data preparation – cleaning and standardizing text data               #
################################################################################
#For this we need the package "tm" ("text mining")

#install.packages("tm")
library(tm)

#create corpus
sms_corpus <- VCorpus(VectorSource(sms_raw$text))

# examine the sms corpus

print(sms_corpus)
# <<VCorpus>>
# Metadata:  corpus specific: 0, document level (indexed): 0
# Content:  documents: 5559

# Now, because the tm corpus is essentially a complex list, we can use list operations to select docments
# in the corpus. The inspect() function shows a summary of the result. For example, the
# following command will view a summary of the first and second SMS messages in the corpus:
inspect(sms_corpus[1:2])
# ..
# [[1]]
# <<PlainTextDocument>>
# Metadata:  7
# Content:  chars: 49
# ..

#To see the content of one sms
as.character(sms_corpus[[1]])  #-> [1] "Hope you are having a good week. Just checking in"
#of some of them
lapply(sms_corpus[1:20], as.character)

#Transform the sms (to lowercase)
sms_corpus_clean <- tm_map(sms_corpus, content_transformer(tolower))

#Check the result
as.character(sms_corpus[[1]])
as.character(sms_corpus_clean[[1]])

#Remove numbers now (function "removeNumbers" is included in package tm)
sms_corpus_clean <- tm_map(sms_corpus_clean, removeNumbers)

#Remove words such as to, and, but, and or
# We’ll use the stopwords() function provided by the tm package, and also removeWords
# check workds and languages with ?stopwords
sms_corpus_clean <- tm_map(sms_corpus_clean, removeWords, stopwords()) # remove stop words
#Remove punctuation too
sms_corpus_clean <- tm_map(sms_corpus_clean, removePunctuation) 


#To do stemming, we need an additional package
#install.packages("SnowballC")
library(SnowballC)
#example of stemming:
wordStem(c("learn", "learned", "learning", "learns"))  # -> [1] "learn"   "unlearn" "learn"   "learn" 

#To apply the wordStem() function to an entire corpus of text documents, the tm package includes
#a stemDocument() transformation.
sms_corpus_clean <- tm_map(sms_corpus_clean, stemDocument)

#Finally eliminate unneeded whitespace produced by previous steps
sms_corpus_clean <- tm_map(sms_corpus_clean, stripWhitespace) 

#Check final result
# before cleaning
lapply(sms_corpus[1:3], as.character)
# after
lapply(sms_corpus_clean[1:3], as.character)

################################################################################
#  Data preparation – splitting text documents into words -> tokenization      #
################################################################################

#the DocumentTermMatrix() function takes a corpus and creates a data structure called a document-term matrix (DTM)
#in which rows indicate documents (SMS messages) and columns indicate terms (words).

sms_dtm <- DocumentTermMatrix(sms_corpus_clean)
sms_dtm

#Creating training and test datasets from the DocumentTermMatrix
# We’ll divide the data into two portions: 75 percent for training and 25 percent for testing.
sms_dtm_train <- sms_dtm[1:4169, ]
sms_dtm_test<- sms_dtm[4170:5559, ]

#Labels
# For convenience later, it is also helpful to save a pair of vectors with the labels for each of the rows in the training and
# testing matrices. These labels are not stored in the DTM, so we need to pull them from the original sms_raw data frame:
sms_train_labels <- sms_raw[1:4169, ]$type
sms_test_labels <- sms_raw[4170:5559, ]$type

#To confirm that the subsets are representative of the complete set of SMS data, let’s compare the proportion of spam 
#in the training and test data frames:
prop.table(table(sms_train_labels))
#       ham      spam 
# 0.8647158 0.1352842 
prop.table(table(sms_test_labels))
#       ham      spam 
# 0.8683453 0.1316547 
# The proportion of spam is the same, around 13% in both sets


################################################################################
#              Visualizing text data – word clouds                             #
################################################################################

# We neeed the package "wordcloud"
#install.packages("wordcloud")
library(wordcloud)

#A word cloud can be created directly from a tm corpus object like this
wordcloud(sms_corpus_clean, min.freq = 50, random.order = FALSE)


#A perhaps more interesting visualization involves comparing the clouds for SMS spam and ham:

ham <- subset(sms_raw, type == "ham")
spam <- subset(sms_raw, type == "spam")

wordcloud(ham$text, max.words = 50, scale = c(3, 0.5), random.order = FALSE)
wordcloud(spam$text, max.words = 50, scale = c(3, 0.5), random.order = FALSE)

# Spam messages include words such as call, free, mobile, claim, and stop; these terms do not appear 
# in the ham cloud at all. Instead, ham messages use words such as can, sorry, love, and time. 
# These stark differences suggest that ourNaive Bayes model will have some strong keywords to differentiate between the classes.

# Data preparation – creating indicator features for frequent words
# the function findFreqTerms() in the tm package takes a DTM and returns a character vector containing words that appear at least a
# minimum number of times:
findFreqTerms(sms_dtm_train, 5)
# we save those words in a vector
sms_freq_words <- findFreqTerms(sms_dtm_train, 5)

str(sms_freq_words)


sms_dtm_freq_train <- sms_dtm_train[ , sms_freq_words]
sms_dtm_freq_test <- sms_dtm_test[ , sms_freq_words]
# Now the training and test datasets include 1,137 columns/features


# The Naive Bayes classifier is usually trained on data with categorical features. This poses a problem since the cells 
# in the sparse matrix are numeric and measure the number of times a word appears in a message. 
# We need to change this to a categorical variable that simply indicates yes or no, depending on whether the word appears at all.

# We need a function that converts counts to a factor
convert_counts <- function(x) {
  x <- ifelse(x > 0, "Yes", "No")
}
# and we apply it
sms_train <- apply(sms_dtm_freq_train, MARGIN = 2, convert_counts)  # MARGIN = 2 <- columns
sms_test <- apply(sms_dtm_freq_test, MARGIN = 2, convert_counts)
# The result will be two character-type matrices, each with cells indicating "Yes" or "No" for whether
# the word represented by the column appears at any point in the message represented by the row.

str(sms_train)

# Step 3: Training a model on the data
################################################################################

#The Naive Bayes algorithm will use the presence or absence of words to estimate the probability that a given SMS message is spam.

install.packages("naivebayes")
library(naivebayes)

sms_classifier <- naive_bayes(sms_train, sms_train_labels)

# warnings() -> 1: naive_bayes(): Feature £wk - zero probabilities are present. Consider Laplace smoothing.   <- we will consider it later ,)

# Step 4: Evaluating the model 
################################################################################

#predict
sms_test_pred <- predict(sms_classifier, sms_test)

library(gmodels)

CrossTable(sms_test_pred, sms_test_labels, prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE, dnn = c('predicted', 'actual'))


#  Total Observations in Table:  1390 
#
#
#              | actual 
#    predicted |       ham |      spam | Row Total | 
# -------------|-----------|-----------|-----------|
#          ham |      1201 |        30 |      1231 | 
#              |     0.864 |     0.022 |           | 
# -------------|-----------|-----------|-----------|
#         spam |         6 |       153 |       159 | 
#              |     0.004 |     0.110 |           | 
# -------------|-----------|-----------|-----------|
# Column Total |      1207 |       183 |      1390 | 

# 36 messages were wrongly classified:   36 / 1390 = 2.6% only!

library(caret) 
confusionMatrix(reference = sms_test_labels, data = sms_test_pred, mode = "everything")

#  Accuracy : 0.9741     
# Precision : 0.9756          
#    Recall : 0.9950          
#        F1 : 0.9852  
# 
# 'Positive' Class : ham 

# Step 5: Improving the model 
################################################################################


#  laplace = 1
sms_classifier_laplace <- naive_bayes(sms_train, sms_train_labels, laplace = 1)


sms_test_pred_laplace <- predict(sms_classifier_laplace, sms_test)


confusionMatrix(reference = sms_test_labels, data = sms_test_pred_laplace, mode = "everything")

#             Reference
# Prediction  ham  spam
#        ham  1202   28
#       spam     5  153

#The number of false positives was reduced from 6 to 5, and the number of false negatives from 30 to 28.

#  Accuracy : 0.9763     
# Precision : 0.9772          
#    Recall : 0.9959          
#        F1 : 0.9865  

