# Statistical Data Analysis Dashboard
### Live Application Link
Access a running instance of the Shiny app using the link above.

## Description
This Shiny app, Statistical Data Analysis Dashboard, provides users with tools to interactively analyze their datasets. It includes the following features:

#### 1. Upload Data: 
    - Upload a CSV file and preview the first 10 rows of your dataset.

#### 2. Data Summary:
    - Select a variable from the uploaded dataset to view key summary statistics, including the minimum, maximum, mean, and median.
    - If the selected variable is non-numeric, the app will inform you.

#### 3. Visualizations:
    - Generate a histogram for a chosen variable to explore its distribution.
    - Create scatter plots between two variables with a computed correlation coefficient, including a linear trend line for better interpretation.


This app simplifies data exploration by providing user-friendly visualizations and statistics for uploaded datasets.

## Dataset Source
This app requires users to upload their own dataset in **CSV** format. Users can interact with any dataset structured in tabular form with appropriate column headers.

#### Example Dataset:
For testing, users can use publicly available datasets such as the Gapminder dataset or their own project data.
    - If you use Gapminder, please acknowledge it as follows: Gapminder data, licensed under Creative Commons Attribution 4.0 International (CC BY 4.0).

## Getting Started
To run this app locally, follow these steps:

1. Clone the repository:
2. Install dependencies: Make sure R and the required libraries (shiny, shinydashboard, ggplot2, dplyr, `