library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(readr)

# define UI
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

# define server
server <- function(input, output, session) {
  
  # Reactive object to read the dataset
  dataset <- reactive({
    req(input$file1)
    read.csv(input$file1$datapath)
  })
  
  # Dynamic UI for selecting variables after file upload
  output$varselect <- renderUI({
    req(dataset())
    df <- dataset()
    varnames <- colnames(df)
    selectInput("var1", "Choose a variable to plot", choices = varnames)
  })
  
  # Display summary statistics of the data
  output$summary_table <- renderTable({
    req(dataset())
    summary(dataset())
  })
  
  # Create histogram for the selected variable
  output$histPlot <- renderPlot({
    req(input$var1)
    df <- dataset()
    ggplot(df, aes_string(x = input$var1)) + 
      geom_histogram(binwidth = 1, fill = "blue", color = "white") +
      theme_minimal() + 
      labs(title = paste("Histogram of", input$var1))
  })
  
  # Create scatter plot for correlation between two variables
  output$scatterPlot <- renderPlot({
    req(input$var1, input$var2)
    df <- dataset()
    ggplot(df, aes_string(x = input$var1, y = input$var2)) +
      geom_point() +
      theme_minimal() + 
      labs(title = paste("Scatter plot of", input$var1, "vs", input$var2))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
