
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
      selectInput('movie_id', 'Pick a Movie:', dropdown), # dropdown defined in global.R
      sliderInput('rating', "Rate It: (1-Don't Like, 5-Love It)", min=1, max=5, step=1, value=5)
      
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = 'tabs', 
                  tabPanel('Directions', 
                           h3('Introduction')
                  ),
                  tabPanel('Your Recommendations', dataTableOutput('recommendation.table'),
                  tabPanel("Reviewer's Ratings", plotOutput('rating.hist')))
      )
    )
  )
))
