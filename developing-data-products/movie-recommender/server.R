# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

# # This function calculates weighted average scores
# getScores <- function(df){
#   df <- df %>%
#     group_by(movie_id) %>%
#     summarise(score = sum(user.weight * adj.rating), reviews = n()) %>%
#     mutate(rating = score / reviews)
#   df
# }

shinyServer(function(input, output) {
  
  getRecommendationTable <- reactive({
      
#     recommendation.table <- merge(getScores(data), titles) %>%
#       arrange(-rating, -reviews, titles) %>%
#       mutate(rating = round(rating, 2)) %>%
#       select(title, rating, reviews)
#     
#     names(recommendation.table) <- c('Movie Title', 'Rating', 'Reviews')
#     
#     recommendation.table
  })
  
  # This function returns the user_id's that gave a movie the same rating
  getReviewerFilter <- reactive({
    r <- data %>% # defined in global.R
      filter(movie_id == input$movie_id) %>%
      filter(rating == input$rating) %>%
      select(user_id)
    r$user_id
  })

  user.ratings <- reactive({
    user.ratings <- movies %>%
      select(id) %>%
      mutate(rating=NA)
#     if(!input$movie.id.1 == 'Pick a Movie'){
#       user.ratings <- user.ratings %>%
#         mutate(rating = ifelse(id == input$movie.id.1, input$rating.1, rating))
#     }
#     if(!input$movie.id.2 == 'Pick a Movie'){
#       user.ratings <- user.ratings %>%
#         mutate(rating = ifelse(id == input$movie.id.2, input$rating.2, rating))
#     }
#     if(!input$movie.id.3 == 'Pick a Movie'){
#       user.ratings <- user.ratings %>%
#         mutate(rating = ifelse(id == input$movie.id.3, input$rating.3, rating))
#     }
    user.ratings
  })

  output$rating.hist <- renderPlot({

    ggplot.data <- data %>%
      filter(movie_id == input$movie_id)
    ggplot.data$rating <- as.factor(ggplot.data$rating)
    
    ggplot(ggplot.data, aes(x=rating,fill=rating)) +geom_bar(stat='bin') + theme(legend.position='none')

  })
  
  output$all.ratings <- renderPlot({
    plot.data <- data %>%
      group_by(movie_id) %>%
      summarise(score = sum(rating), reviews = n()) %>%
      mutate(rating = score / reviews)
    # Draw scaterplot
    ggplot(plot.data) + geom_point(aes(x=rating, y=reviews), color='gray')
  })
  
  output$recommendation.table <- renderDataTable(
    #getRecommendationTable(),
    user.ratings(),
    options = list(
      paging=FALSE,
      searching = FALSE,
      scrollY= 400
    )
  )

  ## Thanks to the folks at RStudio for the inspiration for this visualizion!
  movie_tooltip <- function(x) {
    if (is.null(x) || is.null(x$movie_id)) return(NULL)
    # Pick out the movie with this ID
    all_movies <- isolate(movies)
    movie <- all_movies[all_movies$id == x$movie_id, ]
    paste0("<b>", movie$title, "</b>")
  }

  plot.data <- reactive({
    plot.data <- data %>%
      group_by(movie_id) %>%
      summarise(score=sum(rating), reviews=n()) %>%
      mutate(avg.rating=score/reviews) %>%
      mutate(stroke=1)
    if(!input$genre.filter == 'Anything'){
      plot.data$stroke <- movies[,names(movies) == input$genre.filter]
    }
    plot.data
  })

  vis <- reactive({
    plot.data() %>%
      ggvis(x=~avg.rating, y=~reviews) %>%
      layer_points(size:=50, size.hover:=200, fillOpacity:=~stroke, stroke = ~stroke, key:=~movie_id) %>%
      add_tooltip(movie_tooltip, "hover") %>%
      add_axis('x', title = 'Average Rating') %>%
      add_axis('y', title = 'Number of Reviews') %>%
      hide_legend('stroke')%>%
      set_options(width = 500, height = 500)
    }) %>%
  bind_shiny("plot1")

})
