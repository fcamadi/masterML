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
  
  print("Loading caret ...")
  if (!require(caret)) install.packages('caret', dependencies = T) # data partitioning, confusion matrix
  library(caret)         
  
  print("Loading tidyverse ...")
  if (!require(tidyverse)) install.packages('tidyverse', dependencies = T)
  library(tidyverse)   
  
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
  
  # Remove rows where the post column has empty or null values
  result <- with(df, df[!(trimws(post) == "" | is.na(post)), ])
  print("Removed lines with empty posts.")
  
  result
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


################################################################################
#                                                                              #
#  creat_mat_in_chunks: create a huge matrix from a huge DTM in chunks         #
#                       so the R session does not "explode"                    #             
#                                                                              #
#  (Don't tell anybody: I used duckduckgo.ia (mistral) to help                 #
#                       develop this code :)                                   #
#                                                                              #
################################################################################
creat_mat_in_chunks <- function(dtm, chunk_size) {
  
  n_docs     <- nrow(dtm)
  n_chunks   <- ceiling(n_docs / chunk_size)
  
  # helper function to get chunk [i] #
  get_chunk_i <- function(i) {
    start <- (i - 1) * chunk_size + 1
    end <- min(i * chunk_size, n_docs)
    
    # subset the DocumentTermMatrix
    sub_dtm <- dtm[start:end, ]
    
    # convert to a dense matrix
    mat <- as.matrix(sub_dtm)
    rm(sub_dtm) #to free space
    
    cat("chunk ", i, "processed. \n") 
    return(mat)
  }
  
  # i) generate list of chunk‐matrices
  chunk_list <- lapply(seq_len(n_chunks), get_chunk_i)
  
  # ii) bind all together
  #full_mat <- do.call(rbind, chunk_list)
  chunk_list
}

################################################################################
#                                                                              #
#  creat_sparse_mat_in_chunks: create a huge matrix from a huge DTM in chunks  #
#                       so the R session does not "explode"                    #             
#                                                                              #
#  Now using sparse matrices, which are incredibly much smaller than dense     #
#  matrices. This allows processing much bigger datasets.                      #
#                                                                              #
################################################################################
creat_sparse_mat_in_chunks <- function(dtm, chunk_size) {
  
  n_docs     <- nrow(dtm)
  n_chunks   <- ceiling(n_docs / chunk_size)
  
  # helper function to get chunk [i] #
  get_chunk_i <- function(i) {
    start <- (i - 1) * chunk_size + 1
    end <- min(i * chunk_size, n_docs)
    
    # subset the DocumentTermMatrix
    sub_dtm <- dtm[start:end, ]
    
    # convert to a sparse matrix
    mat <- as.matrix(sub_dtm)
    result <- as(as(as(mat, "dMatrix"), "generalMatrix"), "RsparseMatrix")
    rm(sub_dtm) #to free space
    rm(mat)
    cat("chunk ", i, "processed. \n") 
    return(result)
  }
  
  # i) generate list of chunk‐matrices
  chunk_list <- lapply(seq_len(n_chunks), get_chunk_i)
  
  # ii) bind all together
  #full_mat <- do.call(rbind, chunk_list)
  chunk_list
}

