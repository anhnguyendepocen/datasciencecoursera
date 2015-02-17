library(dplyr)
library(tidyr)
library(ggplot2)

## Read in the MovieLens 100K data
## Downloaded from http://grouplens.org/datasets/movielens/
data <- read.table('data/u.data', header=FALSE, stringsAsFactors=FALSE)
names(data) <- c('user_id', 'movie_id', 'rating' ,'timestamp')

genres <- read.csv('data/u.genre', header=FALSE, sep='|', stringsAsFactors=FALSE)
genres <- genres[2:19,1] # Removing Unkown

movies <- read.csv('data/u.item', header=FALSE, stringsAsFactors=FALSE, sep='|')
names(movies) <- c('id', 'title', 'release_date', 'video_release_date', 'IMDb_url', 'unknown', genres)

## There are duplicate records in the movies data frame so we need to correct it
dup.titles <- movies %>%
  group_by(title) %>%
  summarise (count = n()) %>%
  filter(count > 1) %>%
  select(title)
dup.titles <- dup.titles$title

corrections <- movies %>%
  filter(title %in% dup.titles) %>%
  arrange(title) %>%
  group_by(title) %>%
  mutate(movie_id = id) %>%
  mutate(new.id = min(id)) %>%
  select(movie_id, new.id) %>%
  filter(!movie_id == new.id)
corrections <- corrections[,2:3]

dup.ids <- corrections$movie_id

## Remove the duplicate movies
movies <- movies %>%
  filter(!id %in% dup.ids)

## Correct the movie_id
data <- merge(data, corrections, all.x=TRUE)
data[!is.na(data$new.id),]$movie_id <- data[!is.na(data$new.id),]$new.id
data <- data %>%
  select(movie_id, user_id, rating)

rm(corrections, dup.ids, dup.titles)

## Adjust the movie ratings
avg.rating <- mean(data$rating)
user.adj <- data %>%
  group_by(user_id) %>%
  summarise(user.avg.rating=mean(rating)) %>%
  mutate(rating.adjustment = avg.rating - user.avg.rating) %>% # Outliers moved closer to mean
  select(user_id, rating.adjustment)

data <- merge(data, user.adj) %>%
  mutate(adj.rating = rating + rating.adjustment)

## Set initial weights
data$user.weight <- 1

## For Movie Dropdown

## We only want movies with 200+ reviews
enough.reviews <- data %>%
  group_by(movie_id) %>%
  summarise(count = n()) %>%
  filter(count > 50)

review.dropdown <- movies %>%
  filter(id %in% enough.reviews$movie_id)%>%
  select(id, title) %>%
  arrange(title)

dropdown <- review.dropdown$id
names(dropdown) <- review.dropdown$title

## Subset the data an movies 
data <- data %>%
  filter(movie_id %in% dropdown)

movies <- movies %>%
  filter(id %in% dropdown)

## Clean up R Environment
rm(enough.reviews)

## For Genre Filter
movies.by.genre <- movies[,c('id', genres)] %>%
  gather(id)
names(movies.by.genre)[2] <- c('genre')
movies.by.genre <- movies.by.genre %>%
  filter(value == 1) %>%
  select(id, genre) %>%
  arrange(id)

titles <- movies %>%
  select(id, title) %>%
  mutate(movie_id = id)