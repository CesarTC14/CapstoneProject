if(!file.exists('Coursera-SwiftKey.zip')){
    download.file('https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip', 'Coursera-SwiftKey.zip')}
unzip('Coursera-SwiftKey.zip', overwrite = FALSE)

list_of_packages <- c("tm", "filehash", "openNLP", "readr", "SnowballC", "R.utils","tidyverse","tidytext")
new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(tm)
library(filehash)
library(openNLP)
library(readr)
library(SnowballC)
library(stringr)
library(R.utils)
library(tidyverse)
library(tidytext)

## read lines into vectors, create Vector based Source, operate in smaller pieces of the database
n_lines <- countLines(paste(getwd(), '/final/en_US/en_US.blogs.txt', sep = ""))

countLines(paste(getwd(), '/final/en_US/en_US.twitter.txt', sep = ""))

lines_per_text <- 10000

sample_text <- readLines(paste(getwd(), '/final/en_US/en_US.blogs.txt', sep = ""), n = lines_per_text, encoding = 'UTF-8')

# ## too slow...
# n_texts <- round((n_lines + lines_per_text)/lines_per_text, 0)
# 
# text_list <- vector('list')
# 
# for (i in 1:lines_per_text) {
#     text_list[[i]] <- readr::read_lines(paste(getwd(), '/final/en_US/en_US.blogs.txt', sep = ""), skip = (i * lines_per_text) - lines_per_text, n_max = lines_per_text)
# }
# ## too slow...

## create sample Source
texts <- VectorSource(sample_text)

## create text collection for all elements in the Source (in memory load - check file size first!)
corpus <- SimpleCorpus(texts, control = list(language = 'en_US'))

## manipulations
blogs_clean <- corpus
blogs_clean <- tm_map(blogs_clean, removePunctuation, preserve_intra_word_contractions = TRUE, preserve_intra_word_dashes = FALSE, ucp = FALSE)

blogs_clean <- tm_map(blogs_clean, removeNumbers)

# blogs_clean <- tm_map(blogs_clean, stemDocument)

# blogs_clean <- tm_map(blogs_clean, removeWords, stopwords())

blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = '”', replacement = '"')
blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = '“', replacement = '"')

blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = '’', replacement = '\'')

blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = ' - ', replacement = '')
blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = ' \"', replacement = '')
blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = ' \'', replacement = '')
blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = '\" ', replacement = '')
blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = '\' ', replacement = '')

blogs_clean <- tm_map(blogs_clean, iconv, from = 'latin1', to = 'ASCII', sub = '') #remove unexpected characters - for example, chinese/japanese/korean characters

# blogs_clean <- tm_map(blogs_clean, gsub, pattern = "[\U4E00-\U9FFF\U3000-\U303F\U3040-\U309F\U1F00-\U1FFF]", replacement = "") #remove unexpected characters - for example, chinese/japanese/korean characters


blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = '  ', replacement = ' ')
blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = '  ', replacement = ' ')
blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = '  ', replacement = ' ')
blogs_clean <- tm_map(blogs_clean, str_replace_all, pattern = '  ', replacement = ' ')


blogs_clean <- blogs_clean[lapply(blogs_clean$content,length)>0]

## exploratory analysis
# df <- blogs_clean[["1"]][["content"]]
# df <- strsplit(df, " ") #splits string into vector containing each word

df <- tibble(string = blogs_clean$content)

word_freq <- df %>% 
    # mutate(strings = as.character(strings)) %>% 
    unnest_tokens(word, string) %>%   #this tokenize the strings and extract the words
    count(word) %>% 
    arrange(desc(n))

word_freq[word_freq$word %in% c('don\'t','dont'),]

gram_2_freq <- df %>% 
    # mutate(strings = as.character(strings)) %>% 
    unnest_tokens(gram2, string, token = 'ngrams', n = 2) %>%   #this tokenize the strings and extract the words
    count(gram2) %>% 
    arrange(desc(n))


gram_3_freq <- df %>% 
    # mutate(strings = as.character(strings)) %>% 
    unnest_tokens(gram3, string, token = 'ngrams', n = 3) %>%   #this tokenize the strings and extract the words
    count(gram3) %>% 
    arrange(desc(n))

head(word_freq)
head(gram_2_freq)
head(gram_3_freq)




x <- 'i don\'t know what\'s going on'
iconv(x, from = 'UTF-8', to = 'ASCII', sub = '')

removePunctuation(x, preserve_intra_word_contractions = TRUE, preserve_intra_word_dashes = FALSE, ucp = FALSE)


table(word_freq$n)
table(gram_2_freq$n)
table(gram_3_freq$n)


hist(word_freq$n)
hist(word_freq$n[word_freq$n > 1])

hist(gram_2_freq$n)
hist(gram_2_freq$n[gram_2_freq$n > 1])


## create term-document matrix for the 'blogs' file
term_doc_matrix <- TermDocumentMatrix(blogs_clean, control = list(tokenize = Maxent_Word_Token_Annotator))

inspect(term_doc_matrix)

## create Source with all files on directory (only .txt files on this one)
texts <- DirSource(directory = paste(getwd(), '/final/en_US', sep = ""),
                   encoding = 'UTF-8')

# ## create text collection for all elements in the Source (data base like structure - slower, but a good solution for data too big for RAM)
# corpus <- PCorpus(texts 
#                   # ,readerControl = list(reader = readPlain(elem = texts,
#                   #                                               language = 'en_US',
#                   #                                               id = 'all'),
#                   #                           language = 'en_US',
#                   #                           load = FALSE)
#                   ,dbControl = list(useDb = TRUE,
#                                    dbName = 'texts.db',
#                                    dbType = 'DB1')
#                   )

## create text collection for all elements in the Source (in memory load - check file size first!)
corpus <- SimpleCorpus(texts, control = list(language = 'en_US'))

## manipulations - learn which ones to use!
blogs_clean <- removeNumbers(corpus[[1]])


blogs_clean <- tolower(blogs_clean)
blogs_clean <- removeWords(blogs_clean, stopwords())

## create term-document matrix for the 'blogs' file
term_doc_matrix <- TermDocumentMatrix(corpus[[3]], control = list(tokenize = Maxent_Sent_Token_Annotator))

