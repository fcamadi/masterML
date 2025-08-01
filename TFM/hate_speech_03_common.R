# ---
# title: "hate_speech_03_common"
# author: "Fran Camacho"
# date: "2025-07-15"
# output: word_document
# ---


# Código común para procesar comentarios sin etiquetar
# Common code needed to process unlabelled posts 



source("hate_speech_common.R")


################################################################################
#                                                                              #
#  Preprocess unlabelled posts: remove emoticons, references to users ...      #
#                                                                              #
################################################################################
process_unlabelled_posts <- function(new_text_df, train_vocab)  {
  
  # Preprocess posts
  new_text_clean_df <- preprocess_posts(new_text_clean_df, new_text_df)
  
  # additional cleaning for unlabelled posts
  new_text_clean_df$post <- gsub("#\\d+ Cerrar", "", new_text_clean_df$post) 
  new_text_clean_df$post <- gsub("# \\d+", "", new_text_clean_df$post) 
  
  # Create corpus
  new_corpus <- Corpus(VectorSource(new_text_clean_df$post))
  
  # Clean new corpus
  new_corpus_clean <- clean_corpus(new_corpus)
  print("")
  print(new_corpus_clean)
  
  # Create DTM using the training vocabulary
  new_dtm <- DocumentTermMatrix(new_corpus_clean,
                                control = list(dictionary = train_vocab,
                                               wordLengths = c(2, Inf))
  )
  
  # Create matrix from the DTM
  new_matrix <- as.matrix(new_dtm)
  
  #check
  if (!all(colnames(new_matrix) %in% train_vocab)) { 
    # should be TRUE
    print("WARNING: not all colnames are included in the training vocabulary!")
  }
  
  # Convert matrix into a sparse matrix
  new_sparse_matrix <- as(as(as(new_matrix, "dMatrix"), "generalMatrix"), "RsparseMatrix")
  
  # Return it to make the predictions
  new_sparse_matrix
}

