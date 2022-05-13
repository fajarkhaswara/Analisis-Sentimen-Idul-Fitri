# load needed packages
library(dplyr)
library(tidyr)
library(tidytext)
library(tm)
library(dplyr)
library(stringr)
library(wordcloud)
library(ggplot2)
library(rtweet)

# collect twitter data
df <- search_tweets(
  "silaturahmi", n = 5000, include_rts = TRUE, lang = "id", type = "recent"
)

#flaten the tweets
flatenned_tweets <- data.frame(lapply(df, as.character), stringsAsFactors = FALSE)

#save raw twitter data
write.csv(x = flatenned_tweets,
          file = '~/Projects/Twitter/SA/analisissentimen/Datasets/Data Silaturahmi Mentah.csv',
          row.names = FALSE)

# remove duplicate and select single column for only text
tweets.df = df %>% distinct(text, .keep_all = FALSE)

#save twitter data
write.csv(x = tweets.df,
          file = '~/Projects/Twitter/SA/analisissentimen/Datasets/Data Silaturahmi.csv',
          row.names = FALSE)

# Load Data from Computer
tweets.df = read.csv(file = '~/Projects/Twitter/SA/analisissentimen/Datasets/Data Silaturahmi.csv',
                     header = TRUE,
                     sep = ',')

# ===== DATA CLEANSING
# Work with Corpus
tweet.corpus = VCorpus(VectorSource(tweets.df$text))
inspect(tweet.corpus[[1]])

# Import external function
source(file = '~/Projects/Twitter/SA/analisissentimen/Helpers/Function Helper/Cleansing.R')

# TRANSFORM TO LOWER CASE
tweet.corpus = tm_map(tweet.corpus, content_transformer(tolower))
# FILTERING - CUSTOM CLEANSING FUNCTIONS

tweet.corpus = tm_map(tweet.corpus, content_transformer(removeURL))
tweet.corpus = tm_map(tweet.corpus, content_transformer(unescapeHTML))
tweet.corpus = tm_map(tweet.corpus, content_transformer(removeMention))
tweet.corpus = tm_map(tweet.corpus, content_transformer(removeCarriage))
tweet.corpus = tm_map(tweet.corpus, content_transformer(removeEmoticon))
tweet.corpus = tm_map(tweet.corpus, content_transformer(removeInvoice))

# Remove additional symbols to white space
tweet.corpus = tm_map(tweet.corpus, toSpace, "[[:punct:]]") # punctuation
tweet.corpus = tm_map(tweet.corpus, toSpace, "[[:digit:]]") # numbers

# Eliminate extra white spaces
tweet.corpus = tm_map(tweet.corpus, stripWhitespace)

# Check the final result
inspect(tweet.corpus[[1]])

# SPELLING NORMALIZATION
spell.lex = read.csv(file = '~/Projects/Twitter/SA/analisissentimen/Helpers/Data Helper/colloquial-indonesian-lexicon.txt',
                     header = TRUE,
                     sep = ',',
                     stringsAsFactors = FALSE)

# Import external function
source(file = '~/Projects/Twitter/SA/analisissentimen/Helpers/Function Helper/Cleansing.R')
tweet.corpus = tm_map(tweet.corpus, spell.correction, spell.lex)

# STEMMING WORDS
# Import external function
source(file = '~/Projects/Twitter/SA/analisissentimen/Helpers/Function Helper/Cleansing.R')
tweet.corpus = tm_map(tweet.corpus, content_transformer(stemming))


# ===== LEXICON-BASED SENTIMENT SCORING
pos = readLines('~/Projects/Twitter/SA/analisissentimen/Helpers/Data Helper/s-pos.txt')
neg = readLines('~/Projects/Twitter/SA/analisissentimen/Helpers/Data Helper/s-neg.txt')
df.tweet = data.frame(text = sapply(tweet.corpus, as.character),
                      stringsAsFactors = FALSE)


# Negation Handling
negasi = scan('~/Projects/Twitter/SA/analisissentimen/Helpers/Data Helper/negatingword.txt',
              what = 'character')
senti = read.csv('~/Projects/Twitter/SA/analisissentimen/Helpers/Data Helper/sentiwords_id.txt',
                 sep = ':', 
                 header = FALSE) %>% 
  mutate(words = as.character(V1),
         score = as.numeric(V2)) %>% 
  select(c('words','score'))
booster = read.csv('~/Projects/Twitter/SA/analisissentimen/Helpers/Data Helper/boosterwords_id.txt',
                   sep = ":", 
                   header = FALSE) %>%
  mutate(words = as.character(V1),
         score = as.numeric(V2)) %>% 
  select(c('words','score'))
# Import external function
source(file = '~/Projects/Twitter/SA/analisissentimen/Helpers/Function Helper/Lexicon-Based Scoring Analysis.R')
results = scores.sentiment(df.tweet$text, senti, negasi)

set.seed(2211)
random.tweet = sample(x = df.tweet$text, 
                      size = 10)
head(scores.sentiment(random.tweet, senti, negasi),5)
# Convert score to sentiment classes
results$class = as.factor(ifelse(results$score < 0, 'Negative',
                                 ifelse(results$score == 0, 'Neutral','Positive')))

# ===== SAVE DATA RESULTS
write.csv(x = results,
          file = '~/Projects/Twitter/SA/analisissentimen/Datasets/Sentiment Silaturahmi.csv',
          row.names = FALSE)

# ===== FILTERING STOPWORDS
rm.stopword = VCorpus(VectorSource(results$text))
# Using edited stopword list
stopwords.id = readLines('~/Projects/Twitter/SA/analisissentimen/Helpers/Data Helper/stopwords-id.txt')
rm.stopword = tm_map(rm.stopword, removeWords, stopwords.id)
# Using manually added stopword list
stopwords.id = readLines('~/Projects/Twitter/SA/analisissentimen/Helpers/Data Helper/stopwords-manual.txt')
rm.stopword = tm_map(rm.stopword, removeWords, stopwords.id)
# Check the final result
inspect(rm.stopword[[2]])
# Eliminate extra white spaces
rm.stopword = tm_map(rm.stopword, stripWhitespace)

# TOKENIZATION - FREQUENT WORDS
tdm = TermDocumentMatrix(rm.stopword, 
                         control = list(wordLengths = c(1, Inf)))
freq.terms = findFreqTerms(tdm, 
                           lowfreq = 20)
freq.terms[1:50]


# ===== WORDCLOUD
wordcloud(rm.stopword,
          max.words = 100,
          min.freq = 25,
          random.order = FALSE,
          colors = brewer.pal(8, "Dark2"))

# ===== BARPLOT OF FREQUENT WORDS
term.freq = rowSums(as.matrix(tdm))
term.freq = subset(term.freq, term.freq >= 100)
df = data.frame(term = names(term.freq), 
                freq = term.freq)
ggplot(df)+ 
  geom_bar(aes(x = reorder(term,
                           freq),
               y = freq),
           stat = 'identity',
           fill = I('blue'),
           alpha = 0.6)+
  labs(title = 'Frekuensi Kata',
       subtitle = 'Takbiran',
       caption = 'Twitter Crawling 1 Mei 2022')+
  xlab('Kata')+ 
  ylab('Jumlah')+
  coord_flip()+
  theme(axis.text = element_text(size = 9))+
  theme_bw()


