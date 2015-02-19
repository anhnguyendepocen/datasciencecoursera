# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel('Movie Recommender'),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput('genre.filter', "I'm in the mood for", c('Anything', genres)),
      selectInput('movie_id.1', 'Movie 1:', c('Pick a Movie',dropdown)),
      sliderInput('rating.1', "Rate It: (1-Don't Like, 5-Love It)", min=1, max=5, step=1, value=5),
      selectInput('movie_id.2', 'Movie 2:', c('Pick a Movie',dropdown)), 
      sliderInput('rating.2', "Rate It: (1-Don't Like, 5-Love It)", min=1, max=5, step=1, value=5),
      selectInput('movie_id.3', 'Movie 3:', c('Pick a Movie',dropdown)), 
      sliderInput('rating.3', "Rate It: (1-Don't Like, 5-Love It)", min=1, max=5, step=1, value=5)

      
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = 'tabs', 
                  tabPanel('Directions', 
                           h3('Introduction')
                  ),
                  tabPanel('Your Recommendations', dataTableOutput('recommendation.table')),
                  tabPanel("Reviewer's Ratings", 
                           #plotOutput('all.ratings')
                           ggvisOutput('plot1')
                           )#plotOutput('rating.hist'))
      )
    )
  )
))
