library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(readr)
library(DT)

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
      # Feature 1 - Upload Data Tab
      tabItem(tabName = "upload",
              fluidRow(
                box(width = 12,
                    fileInput("file1", "Choose CSV File", accept = ".csv"),
                    #varnames <- colnames(df)
                    #uiOutput("varselect")
                ),
                box(width = 12, 
                    tableOutput("dataPreview") # New box to preview the uploaded data
                )
              )
      ),
      # Feature 2 - Data Summary Tab
      tabItem(tabName = "summary",
              fluidRow(
                box(width = 12,
                    selectInput("varSummary", "Select a variable for summary", choices = NULL),  # Dropdown menu
                    tableOutput("summary_table")  # Table to display summary stats
                )
              )
      ),
      
      # Feature 3 - Visualizations Tab of Scatter Plot with Correlation Coeificient
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

# Define Server
server <- function(input, output, session) {
  
  # Reactive object to read the dataset
  dataset <- reactive({
    req(input$file1)
    read.csv(input$file1$datapath)
  })
  
  # Feature 1 - Dynamic UI for selecting variables after file upload
  output$varselect <- renderUI({
    req(dataset())
    df <- dataset()
  })
  
  # Display the first 10 rows of the dataset
  output$dataPreview <- renderTable({
    req(dataset())
    head(dataset(), 10)
  })
  
  # Feature 2 - Display summary statistics of the data
  output$summary_table <- renderTable({
    req(dataset())  # Ensure the dataset is available
    req(input$varSummary)  # Ensure a variable is selected
    
    df <- dataset()
    selected_var <- input$varSummary
    
    # Check if the selected variable is numeric
    if (selected_var %in% colnames(df)) {
      # Check if the selected variable is numeric
      if (is.numeric(df[[selected_var]])) {
        # Calculate summary statistics
        data.frame(
          Statistic = c("Minimum", "Maximum", "Mean", "Median"),
          Value = c(
            min(df[[selected_var]], na.rm = TRUE),
            max(df[[selected_var]], na.rm = TRUE),
            mean(df[[selected_var]], na.rm = TRUE),
            median(df[[selected_var]], na.rm = TRUE)
          )
        )
      } else {
        # If the variable is not numeric, return a message
        data.frame(
          Message = paste("The selected variable", selected_var, "is not numeric.")
        )
      }
    } else {
      # If the variable is not in the dataset, return an error message
      data.frame(
        Message = paste("The variable", selected_var, "does not exist in the dataset.")
      )
    }
  })
  
  # Observe event to update the dropdown for selecting the variable
  observe({
    req(dataset())
    updateSelectInput(session, "varSummary", choices = colnames(dataset()))
  })
  
  # Feature 3 - Create scatter plot for correlation between two variables
  output$histPlot <- renderPlot({
    req(input$var1)  
    df <- dataset()
    ggplot(df, aes_string(x = input$var1)) + 
      geom_histogram(binwidth = 1, fill = "blue", color = "white") +
      theme_minimal() + 
      labs(title = paste("Histogram of", input$var1))
  })
  
  output$scatterPlot <- renderPlot({
    req(input$var1, input$var2) # Ensure both variables are selected
    df <- dataset()
    
    # Calculate correlation coefficient
    corr <- round(cor(df[[input$var1]], df[[input$var2]], use = "complete.obs"), 2)
    
    # Create scatter plot with correlation coefficient overlay
    ggplot(df, aes_string(x = input$var1, y = input$var2)) +
      geom_point() +
      geom_smooth(method = "lm", color = "red", se = FALSE) + # Add linear trend line
      theme_minimal() +
      labs(
        title = paste("Scatter plot of", input$var1, "vs", input$var2),
        subtitle = paste("Correlation:", corr),
        x = input$var1,
        y = input$var2
      )
  })
  
  # Update the dropdown choices whenever the dataset changes
  observe({
    req(dataset())
    updateSelectInput(session, "var1", choices = colnames(dataset()))
    updateSelectInput(session, "var2", choices = colnames(dataset()))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
