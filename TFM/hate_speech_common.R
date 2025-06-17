# ---
# title: "hate_speech_common"
# author: "Fran Camacho"
# date: "2025-06-13"
# output: word_document
# ---


# Código común para todos los datasets
# Common code needed to process all datasets

################################################################################
#                                                                              #
#  Load needed libraries                                                       #
#                                                                              #
################################################################################
load_libraries <- function() { 
  
  print("Loading libraries:")
  
  print("Loading tm ...")
  if (!require(tm)) install.packages('tm', dependencies = T)   # text mining
  library(tm)
  
  print("Loading SnowballC ...")
  if (!require(SnowballC)) install.packages('SnowballC', dependencies = T)   # stemming
  library(SnowballC)
  
  print("Loading textclean ...")
  if (!require(textclean)) install.packages('textclean', dependencies = T)  
  library(textclean)
  
  print("Loading dplyr ...")
  if (!require(dplyr)) install.packages('dplyr', dependencies = T)
  library(dplyr)
  
  print("Loading caret ...")
  if (!require(caret)) install.packages('caret', dependencies = T)   # data partitioning, confusion matrix
  library(caret)         
  
  # LiblineaR instead of LIBSVM
  #
  # https://www.csie.ntu.edu.tw/~cjlin/liblinear/
  #
  # https://cran.r-project.org/web/packages/LiblineaR/
  print("Loading LiblineaR ...")
  if (!require(LiblineaR)) install.packages('LiblineaR', dependencies = T)
  library(LiblineaR)   

  print("All libraries loaded.")
}



################################################################################
#                                                                              #
#  Preprocess posts: remove emoticons, references to users ...                 #
#                                                                              #
################################################################################
preprocess_posts <- function(df, df_raw) {
  
  #remove references to other users
  df_raw$post <- gsub("@\\w+", "", df_raw$post) 
  print("Removed references to users (@).")
  
  #remove non ascii characters and emoticons using textclean
  df <- df_raw
  df$post <- df_raw$post |> 
    replace_non_ascii() |> 
    replace_emoticon() 
  print("Removed non ascii and emoticons.")
  
  df 
}



################################################################################
#                                                                              #
#  Clean corpus                                                                #
#                                                                              #
################################################################################
clean_corpus <- function(corpus) { 


  print("#To lowercase") 
  posts_corpus_clean <- tm_map(corpus, content_transformer(tolower))
  
  print("#Remove numbers")
  posts_corpus_clean <- tm_map(posts_corpus_clean, removeNumbers)

  print("#Remove stopwords")
  # check words and languages with ?stopwords
  posts_corpus_clean <- tm_map(posts_corpus_clean, removeWords, stopwords()) 

  print("#Remove punctuation signs")
  posts_corpus_clean <- tm_map(posts_corpus_clean, removePunctuation) 

  print("#Carry out the stemming")
  # To apply the wordStem() function to an entire corpus of text documents, the tm package includes
  # the stemDocument() transformation.
  posts_corpus_clean <- tm_map(posts_corpus_clean, stemDocument)

  print("#Finally eliminate unneeded whitespace produced by previous steps")
  posts_corpus_clean <- tm_map(posts_corpus_clean, stripWhitespace) 
  
  posts_corpus_clean
}

################################################################################
#                                                                              #
#  train_test_split: create train and tests sets                               #
#                                                                              #
################################################################################
train_test_split  <- function(df, dtm, percentage) {
  
  #Set seed to make the process reproducible
  set.seed(123)
  
  #partitioning data frame into training (75%) and testing (25%) sets
  train_indices <- createDataPartition(df$label, times=1, p=percentage, list=FALSE)
  
  #create training set
  dtm_train <- dtm[train_indices, ]
  
  #create testing set
  dtm_test  <- dtm[-train_indices, ]
  
  #create labels sets
  train_labels <- df[train_indices, ]$label
  test_labels <- df[-train_indices, ]$label

  #view number of rows in each set
  cat("train dtm nrows: ", nrow(dtm_train), "\n")  # 
  cat(" test dtm nrows: ", nrow(dtm_test), "\n")   # 
  cat("length of train labels: ", length(train_labels), "\n")  # 
  cat(" length of test labels: ", length(test_labels), "\n")   # 
  
  return(list(dtm_train = dtm_train, dtm_test = dtm_test, train_labels = train_labels, test_labels = test_labels))
}


