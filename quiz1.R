twitter <- readLines(paste(getwd(), '/final/en_US/en_US.twitter.txt', sep = ""), n = -1, encoding = 'UTF-8')

head(twitter)

class(twitter)

x <- lapply(twitter, nchar)

max(unlist(x))


blogs <- readLines(paste(getwd(), '/final/en_US/en_US.blogs.txt', sep = ""), n = -1, encoding = 'UTF-8')

x <- lapply(blogs, nchar)

max(unlist(x))

news <- readLines(paste(getwd(), '/final/en_US/en_US.news.txt', sep = ""), n = -1, encoding = 'UTF-8', warn = F)

y <- lapply(news, nchar)

max(unlist(y))


head(twitter)
length(twitter)

lc_twitter <- tolower(twitter)

love <- grepl('love', lc_twitter)

hate <- grepl('hate', lc_twitter)

sum(love)/sum(hate)

lc_twitter[grepl('biostats', lc_twitter)]

sum(grepl('A computer once beat me at chess, but it was no match for me at kickboxing', twitter))
