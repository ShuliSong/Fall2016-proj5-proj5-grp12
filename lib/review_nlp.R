library(data.table)
library(NLP)
library(tm)
library(SnowballC)
library(ggplot2)
library(wordcloud)

review <- fread("/Users/sun93/Documents/ADS/pro5/yelp_academic_dataset_review.csv")
review <- read.csv("/Users/sun93/Documents/ADS/pro5/yelp_academic_dataset_review.csv")
load("/Users/sun93/Documents/ADS/pro5/review.RData")

View(review[1412530:1412540,])
colnames(review)
str(review)

# data cleaning
set.seed(333)
review_1star <- review[which(review$stars ==1),'text']
review_1star <- as.character(review_1star)
nsample1 <- sample(1:length(review_1star), size = 10000)
review_1star <- review_1star[nsample1]
str(review_1star)
review_1star[1:5]

review_2star <- review[which(review$stars ==2),'text']
review_2star <- as.character(review_2star)
nsample2 <- sample(1:length(review_2star), size = 10000)
review_2star <- review_2star[nsample2]
str(review_2star)
review_2star[1:5]

review_3star <- review[which(review$stars ==3),'text']
review_3star <- as.character(review_3star)
nsample3 <- sample(1:length(review_3star), size = 10000)
review_3star <- review_3star[nsample3]
str(review_3star)
review_3star[1:5]

review_4star <- review[which(review$stars ==4),'text']
review_4star <- as.character(review_4star)
nsample4 <- sample(1:length(review_4star), size = 10000)
review_4star <- review_4star[nsample4]
str(review_4star)
review_4star[1:5]

review_5star <- review[which(review$stars ==5),'text']
review_5star <- as.character(review_5star)
nsample5 <- sample(1:length(review_5star), size = 10000)
review_5star <- review_5star[nsample5]
str(review_5star)
review_5star[1:5]

wordcloud_rating <- function(reviews, rating_i){
  review <- iconv(enc2utf8(reviews),sub="byte")
  # Tansform script text lines into corpus (separated text files)
  myCorpus <- Corpus(VectorSource(review))
  # Check original text data's meta-data
  #inspect(myCorpus_1star)
  # Convert all text to lowercase
  myCorpus <- tm_map(myCorpus, content_transformer(tolower))
  # Remove all numbers
  myCorpus <- tm_map(myCorpus, content_transformer(removeNumbers))
  # Delete all english stopwords. See list: stopwords("english")
  myCorpus <- tm_map(myCorpus, removeWords, stopwords("english"))
  # Remove all punctuation
  myCorpus <- tm_map(myCorpus, content_transformer(removePunctuation))
  # Delete common word endings, like -s, -ed, -ing, etc.
  myCorpus <- tm_map(myCorpus, stemDocument, language = "english")
  myCorpus <- tm_map(myCorpus, removeWords, c("good", "really","like","food","great","great","order","get","place")) 
  # Reduce any whitespace (spaces, newlines, etc) to single spaces
  myCorpus <- tm_map(myCorpus, content_transformer(stripWhitespace))
  

  # Add cleaned textlines to dataframe 
  #review_1star_clean <- as.vector(unlist(sapply(myCorpus_1star, `[`, "content")))
  review_clean <- tm_map(myCorpus, PlainTextDocument)   
  
  #DTM Generating 
  # Tansform corpus into Document Term Matrices
  DTM <- DocumentTermMatrix(review_clean)
  
  # Remove sparsity 
  myDTM.nosparse <- removeSparseTerms(DTM, 0.95)
  
  freq <- sort(colSums(as.matrix(myDTM.nosparse)), decreasing=TRUE)   
  wf <- data.frame(word=names(freq), freq=freq)   
  
  # word cloud
  wordcloud(names(freq), freq, min.freq=800, scale=c(4, .1), colors=brewer.pal(6, "Dark2"))   
  text(x=0.5, y=1, paste("Word Cloud Reviews in Star", rating_i))
  
  # Plot Word Frequencies
  ggplot(subset(wf, freq>1500), aes(reorder(word, -freq), freq)) + 
    geom_bar(stat="identity",fill="light blue") + 
    theme(axis.text.x=element_text(angle=45, hjust=1)) +
    ggtitle(paste("TOP Reviews Words in Star", rating_i)) +
    xlab("TOP Words") + 
    ylab("Freqency")
}

wordcloud_rating(review_1star, 1)
wordcloud_rating(review_2star, 2)
wordcloud_rating(review_3star, 3)
wordcloud_rating(review_4star, 4)
wordcloud_rating(review_5star, 5)

