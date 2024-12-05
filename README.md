# Statistical Data Analysis Dashboard
### [Live Application Link](https://ajung02.shinyapps.io/assignment-b3/)
Access a running instance of the Shiny app using the link above.

## Description
This Shiny app, Statistical Data Analysis Dashboard, provides users with tools to interactively analyze their datasets. It includes the following features:

#### 1. Upload Data: 
- Upload a CSV file and preview the first 10 rows of your dataset.
- No file larger than 5 MB may be uploaded. This will prompt an error dictating "Maximum upload size exceeded".

##### Filtering & Downloading data
- Dynamic filters are available to allow users to select specific categories or numeric ranges to view only the relevant subset of data. Filters update based on the uploaded dataset's columns.
- After applying filters, users can download the filtered dataset for further analysis.
- The filtered data can be downloaded by clicking the "Download Filtered Data" button. The file will be saved in CSV format, with the name including the current date.

#### 2. Data Summary:
- Select a variable from the uploaded dataset to view key summary statistics, including the minimum, maximum, mean, and median.
- If the selected variable is non-numeric, the app will inform you.

#### 3. Visualizations:
- Generate a histogram for a chosen numeric variable to explore its distribution.
- Generate a bar plot for a chosen non-numeric variable to explore its properties.
- Create scatter plots between two numeric variables with a computed correlation coefficient, including a linear trend line for better interpretation.

#### 4. Help:
- The "Help" tab provides steps in how to utilize the app.

This app simplifies data exploration by providing user-friendly visualizations and statistics for uploaded datasets.

## Dataset Source
This app requires users to upload their own dataset in **CSV** format. Users can interact with any dataset structured in tabular form with appropriate column headers.

To demonstrate its functionality, the app has been tested using the following dataset:

[Apartment Building Registration Data](https://open.toronto.ca/dataset/apartment-building-registration/)

Source: Acquired courtesy of The City of Toronto’s Open Data Portal.

Users are encouraged to use their own datasets for customized analysis. For reproducibility, include a link to any publicly sourced dataset.

## Instructions
1. Visit the Shiny app at the provided link.
2. Upload your dataset in CSV format.
3. Explore summary statistics and visualizations for the uploaded data.
