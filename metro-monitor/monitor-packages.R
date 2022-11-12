monitor.packages <- function(monitor.packages) {
  packages <- c('censusapi',
                'educationdata',
                'data.table', 
                'dplyr', 
                'DT', 
                'formattable', 
                'ggplot2', 
                'httr',
                'janitor',
                'jsonlite', 
                'librarian', 
                'lubridate', 
                'magrittr',
                'maps',
                'maptools',
                'markdown', 
                'openxlsx', 
                'pacman', 
                'pdftools',
                'plotly',
                'RCurl',
                'readr', 
                'readxl', 
                'rJava',
                'rvest',
                'shiny', 
                'shinydashboard', 
                'sqldf',
                'sp',
                'stringr', 
                'tidycensus',
                'tidyqwi',
                'tidyr', 
                'tidyverse', 
                'writexl', 
                'xlsx', 
                'XML',
                'zipcodeR',
                'zoo')
  
  installed_packages <- packages %in% rownames(installed.packages())
  if (any(installed_packages == FALSE)) {
    install.packages(packages[!installed_packages])
  }
  invisible(lapply(packages, library, character.only = TRUE))
  
  rm(installed_packages)
  rm(packages)
}

monitor.packages()
rm(monitor.packages)