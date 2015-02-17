# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

# This function calculates weighted average scores
getScores <- function(df){
  df <- df %>%
    group_by(movie_id) %>%
    summarise(score = sum(user.weight * adj.rating), reviews = n()) %>%
    mutate(rating = score / reviews)
  df
}

shinyServer(function(input, output) {
  
  score.data <- reactive({
    data %>%
      filter(Origin == input$msa.filter)
  })
  
  getRecommendationTable <- reactive({
      
    recommendation.table <- merge(getScores(data), titles) %>%
      arrange(-rating, -reviews, titles) %>%
      mutate(rating = round(rating, 2)) %>%
      select(title, rating, reviews)
    
    names(recommendation.table) <- c('Movie Title', 'Rating', 'Reviews')
    
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
  
  output$all.ratings <- renderPlot({
    # Draw scaterplot
    ggplot(getScores(data), aes(x=rating, y=reviews)) + geom_point()
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
