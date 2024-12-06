library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(readr)
library(DT)

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Statistical Data Analysis Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Upload Data", tabName = "upload", icon = icon("file-upload")),
      menuItem("Data Summary", tabName = "summary", icon = icon("chart-bar")),
      menuItem("Visualizations", tabName = "visualizations", icon = icon("chart-line")),
      menuItem("Help", tabName = "help", icon = icon("info-circle"))
    )
  ),
  dashboardBody(
    tabItems(
      # Feature 1 - upload data tab
      tabItem(tabName = "upload",
              fluidRow(
                                box(width = 12,
                    fileInput("file1", "Choose CSV File (< 5 MB)", accept = ".csv"),
                    textOutput("fileWarning"), # Add this to display warnings
                    tableOutput("dataPreview")
                ),
                box(width = 12, 
                    h4("Filter Options"),
                    uiOutput("filterUI"), # Dynamic filter UI based on dataset
                    dataTableOutput("filteredData") # Show filtered data interactively
                ),
                box(width = 12,
                    downloadButton("downloadData", "Download Filtered Data")  # Button to download data
                )
              )

      ),
      # Feature 2 - data summary tab
      tabItem(tabName = "summary",
              fluidRow(
                box(width = 12,
                    selectInput("varSummary", "Select a NUMERIC variable for summary", choices = NULL),  # Dropdown menu
                    tableOutput("summary_table")  # Table to display summary stats
                )
              )
      ),
      
      # Feature 3 - visualizations tab of scatter plot with correlation coeificient
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
      ),
      
      # Feature 4 - add a "Help" tab to provide usage instructions
      tabItem(tabName = "help",
              h3("How to Use This App"),
              p("1. Upload a CSV file in the 'Upload Data' tab."),
              p("2. Use the filter options to explore subsets of your data."),
              p("3. View data summaries and visualizations in the respective tabs."),
              p("4. Download filtered data for further analysis.")
      )
    )
  )
)

# Define Server
server <- function(input, output, session) {
  
  # Reactive object to read the dataset
  dataset <- reactive({
    req(input$file1)
    
    # Check file size and warn the user
    max_size <- 5 * 1024^2  # 5 MB in bytes
    if (input$file1$size > max_size) {
      validate(need(FALSE, "The uploaded file exceeds the 5 MB size limit. Please upload a smaller file."))
    }
    
    # Load the dataset
    read.csv(input$file1$datapath)
  })
  
  # Feature 1 - dynamic UI for selecting variables after file upload
  output$varselect <- renderUI({
    req(dataset())
    df <- dataset()
  })
  
  # Display the first 10 rows of the dataset
  output$dataPreview <- renderTable({
    req(dataset())
    head(dataset(), 10)
  })
  
  # Feature 2 - display summary statistics of the data
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
  
  # Feature 3 - create histogram & scatter plot for correlation between two variables
  
  # Create histogram for a single variable
  output$histPlot <- renderPlot({
    req(input$var1)  
    df <- dataset()
    
    # Check if the selected variable is numeric or categorical
    selected_var <- df[[input$var1]]
    
    if (is.numeric(selected_var)) {
      # Dynamically calculate binwidth for better representation
      range_var <- max(selected_var, na.rm = TRUE) - min(selected_var, na.rm = TRUE)
      bins <- 15  
      binwidth <- range_var / bins
      
      ggplot(df, aes_string(x = input$var1)) + 
        geom_histogram(binwidth = binwidth, fill = "blue", color = "white") +
        theme_minimal() + 
        labs(title = paste("Histogram of", input$var1), x = input$var1, y = "Frequency")
    } else {
      # Treat non-numeric variables as categorical
      unique_levels <- n_distinct(selected_var)
      top_n <- min(10, unique_levels)  # Adjust the number of top levels to show
      top_levels <- df %>%
        count(!!sym(input$var1), sort = TRUE) %>%
        slice_head(n = top_n) %>%
        pull(!!sym(input$var1))
      
      filtered_df <- df %>% filter(!!sym(input$var1) %in% top_levels)
      
      ggplot(filtered_df, aes_string(x = input$var1)) +
        geom_bar(fill = "blue", color = "white") +
        theme_minimal() +
        labs(
          title = paste("Bar Plot of", ifelse(unique_levels > top_n, paste("Top", top_n, "Levels of"), input$var1)),
          x = input$var1,
          y = "Count"
        ) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels
    }
  })
  # Create Scatter Plot to show the correlation of two variables
  output$scatterPlot <- renderPlot({
    req(input$var1, input$var2)
    df <- dataset()
    
    # Validate if the selected variables are numeric
    if (!is.numeric(df[[input$var1]]) || !is.numeric(df[[input$var2]])) {
      validate(need(FALSE, "Both selected variables must be numeric. Please choose numeric variables."))
    }
    
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
  
  # Feature 4 - generating Filter UI
  output$filterUI <- renderUI({
    req(dataset())  # Ensure dataset is available
    df <- dataset()
    
    # Generate filter UI for each column
    lapply(names(df), function(col) {
      if (is.numeric(df[[col]])) {
        # Numeric range input for numeric columns
        sliderInput(
          inputId = paste0("filter_", col),
          label = paste("Filter", col),
          min = min(df[[col]], na.rm = TRUE),
          max = max(df[[col]], na.rm = TRUE),
          value = c(min(df[[col]], na.rm = TRUE), max(df[[col]], na.rm = TRUE))
        )
      } else if (is.character(df[[col]]) || is.factor(df[[col]])) {
        # Dropdown menu for categorical columns
        selectInput(
          inputId = paste0("filter_", col),
          label = paste("Filter", col),
          choices = unique(df[[col]]),
          selected = unique(df[[col]]),
          multiple = TRUE
        )
      }
    })
  })
  
  # Applying filters to dataset
  filteredData <- reactive({
    req(dataset())  # Ensure dataset is available
    df <- dataset()  # Load the dataset
    
    # Loop through each column in the dataset
    for (col in names(df)) {
      input_id <- paste0("filter_", col)  # Dynamically generate input IDs
      
      # Check if the input value exists for the column
      if (!is.null(input[[input_id]])) {
        if (is.numeric(df[[col]])) {
          # Numeric filtering
          range <- input[[input_id]]
          df <- df[df[[col]] >= range[1] & df[[col]] <= range[2], ]
        } else if (is.character(df[[col]]) || is.factor(df[[col]])) {
          # Categorical filtering
          selected <- input[[input_id]]
          df <- df[df[[col]] %in% selected, ]  # Ensure only selected values are kept
        }
      }
    }
    
    df  # Return the filtered dataset
  })
  
  # Rendering filtered data
  filteredData <- reactive({
    req(dataset())  # Ensure dataset is available
    df <- dataset()
    
    for (col in names(df)) {
      input_id <- paste0("filter_", col)
      if (!is.null(input[[input_id]])) {
        if (is.numeric(df[[col]])) {
          # Numeric filtering
          range <- input[[input_id]]
          df <- df[df[[col]] >= range[1] & df[[col]] <= range[2], ]
        } else if (is.character(df[[col]]) || is.factor(df[[col]])) {
          # Categorical filtering
          selected <- input[[input_id]]
          df <- df[df[[col]] %in% selected, ]
        }
      }
    }
    df
  })
  
  # Update the dropdown choices whenever the dataset changes
  observe({
    req(dataset())
    updateSelectInput(session, "var1", choices = colnames(dataset()))
    updateSelectInput(session, "var2", choices = colnames(dataset()))
  })
  # add downloading button under "upload data" tab
  output$downloadData <- downloadHandler(
    filename = function() { paste("filtered_data", Sys.Date(), ".csv", sep = "") },
    content = function(file) {
      write.csv(filteredData(), file, row.names = FALSE)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
