
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyServer(function(input, output) {
  
  score.data <- reactive({
    data %>%
      filter(Origin == input$msa.filter)
  })
  
  # This function calculates scores
  # It allows for subsetting by user_id
  # Scores are the average ranking
  getScores <- function(user_id.filter=NA){
    d <- data # defined in global.R
    if(!is.na(user_id.filter)){
      d <- filter(d, user_id %in% user_id.filter)
    }
    d %>%
      group_by(movie_id) %>%
      summarise(agg.rating = sum(rating), count = n()) %>%
      mutate(score=agg.rating / count)
      
  }
  
  getRecommendationTable <- reactive({
    titles <- movies %>%
      select(id, title) %>%
      mutate(movie_id = id)
    
    all.scores <- getScores()
    names(all.scores)[4] <- c('overall.score')
    
    recommendation.table <- getScores(getReviewerFilter())
    recommendation.table <- merge(merge(recommendation.table, titles), all.scores) %>%
      filter(!movie_id == input$movie_id) %>%
      arrange(-score, -agg.rating) %>%
      select(title, score, overall.score)
    
    names(recommendation.table) <- c('Movie Title', 'Rating Given By People Like You', 'Overall Rating')
    ## Let's not overwhelm the user with recommendations
    if(nrow(recommendation.table) > 100)
      recommendation.table <- recommendation.table[1:100,]
    
    recommendation.table
  })
  
  # This function returns the user_id's that gave a movie the same rating
  getReviewerFilter <- reactive({
    r <- data %>% # defined in global.R
      filter(movie_id == input$movie_id) %>%
      filter(rating == input$rating) %>%
      select(user_id)
    r$user_id
  })

  output$rating.hist <- renderPlot({

    ggplot.data <- data %>%
      filter(movie_id == input$movie_id)
    ggplot.data$rating <- as.factor(ggplot.data$rating)
    
    ggplot(ggplot.data, aes(x=rating,fill=rating)) +geom_bar(stat='bin') + theme(legend.position='none')

  })
  
  output$recommendation.table <- renderDataTable(
    getRecommendationTable(),    
    options = list(
      paging=FALSE,
      searching = FALSE,
      scrollY= 400
    )
  )

})
