library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(readr)

ui <- dashboardPage(
  dashboardHeader(title = "Statistical Data Analysis Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Upload Data", tabName = "upload", icon = icon("file-upload")),
      menuItem("Data Summary", tabName = "summary", icon = icon("chart-bar")),
      menuItem("Visualizations", tabName = "visualizations", icon = icon("chart-line"))
    )
  ),
  dashboardBody(
    tabItems(
      # Upload Data Tab
      tabItem(tabName = "upload",
              fluidRow(
                box(width = 12,
                    fileInput("file1", "Choose CSV File", accept = ".csv"),
                    uiOutput("varselect")
                )
              )
      ),
      
      # Data Summary Tab
      tabItem(tabName = "summary",
              fluidRow(
                box(width = 12, 
                    tableOutput("summary_table")
                )
              )
      ),
      
      # Visualizations Tab
      tabItem(tabName = "visualizations",
              fluidRow(
                box(width = 6,
                    selectInput("var1", "Choose a variable for the plot", choices = NULL),
                    plotOutput("histPlot")
                ),
                box(width = 6,
                    selectInput("var2", "Choose another variable for correlation", choices = NULL),
                    plotOutput("scatterPlot")
                )
              )
      )
    )
  )
)


# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white',
             xlab = 'Waiting time to next eruption (in mins)',
             main = 'Histogram of waiting times')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
