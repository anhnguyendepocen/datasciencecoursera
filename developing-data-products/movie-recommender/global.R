library(dplyr)
library(tidyr)
library(ggplot2)

data <- read.table('data/movielens.txt', header=TRUE, stringsAsFactors=FALSE)
movies <- read.csv('data/movies.txt', header=TRUE, stringsAsFactors=FALSE, sep='|')

## For Movie Dropdown

## We only want movies with 200+ reviews
enough.reviews <- data %>%
  group_by(movie_id) %>%
  summarise(count = n()) %>%
  filter(count > 200)

## We only want movies with all ratings (no NA's)
all.ratings <- data %>%
  select(movie_id, rating) %>%
  group_by(movie_id, rating) %>%
  summarise(value = n()) %>%
  mutate(rating = paste0('n.',rating,'.star')) %>%
  spread(rating, value)

all.ratings <- all.ratings[!is.na(all.ratings$n.1.star),]
all.ratings <- all.ratings[!is.na(all.ratings$n.2.star),]
all.ratings <- all.ratings[!is.na(all.ratings$n.3.star),]
all.ratings <- all.ratings[!is.na(all.ratings$n.4.star),]
all.ratings <- all.ratings[!is.na(all.ratings$n.5.star),]

review.dropdown <- movies %>%
  filter(id %in% enough.reviews$movie_id)%>%
  filter(id %in% all.ratings$movie_id)%>%
  select(id, title) %>%
  arrange(title)

dropdown <- review.dropdown$id
names(dropdown) <- review.dropdown$title

## Clean up R Environment
rm(all.ratings, enough.reviews)

## For Genre Filter
genres <- names(movies)[7:24]

movies.by.genre <- movies[,c('id', genres)] %>%
  gather(id)
names(movies.by.genre)[2] <- c('genre')
movies.by.genre <- movies.by.genre %>%
  filter(value == 1) %>%
  select(id, genre) %>%
  arrange(id)

#data <- subset(data, movie_id %in% reviews$movie_id)
#movies <- subset(movies, id %in% unique(data$movie_id))