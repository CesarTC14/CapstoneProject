if(!file.exists('Coursera-SwiftKey.zip')){
    download.file('https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip', 'Coursera-SwiftKey.zip', over)}
unzip('Coursera-SwiftKey.zip', overwrite = FALSE)

list_of_packages <- c("tm", "readtext", "filehash", "openNLP")
new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(tm)
library(filehash)
library(openNLP)
library(readtext)

## create Source with all files on directory (only .txt files on this one)
texts <- DirSource(directory = paste(getwd(), '/final/en_US', sep = ""),
                   encoding = 'UTF-8')

## create text collection for all elements in the Source
corpus <- PCorpus(texts, 
                  # readerControl = list(reader = readPlain(elem = texts,
                  #                                               language = 'en_US',
                  #                                               id = 'all'),
                  #                           language = 'en_US',
                  #                           load = FALSE),
                  dbControl = list(useDb = TRUE,
                                   dbName = 'texts.db',
                                   dbType = 'DB1'))

## create term-document matrix for the 'blogs' file
