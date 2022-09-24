metro.packages <- function(metro.packages) {
  packages <- c('censusapi', 
                'data.table', 
                'devtools', 
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
                'markdown', 
                'metro.data', 
                'openxlsx', 
                'pacman', 
                'plotly',
                'RCurl',
                'readr', 
                'readxl', 
                'rJava',
                'rvest',
                'shiny', 
                'shinydashboard', 
                'sqldf', 
                'stringr', 
                'tidycensus', 
                'tidyr', 
                'tidyverse', 
                'writexl', 
                'xlsx', 
                'XML',
                'zoo')
  
  installed_packages <- packages %in% rownames(installed.packages())
  if (any(installed_packages == FALSE)) {
    install.packages(packages[!installed_packages])
  }
  invisible(lapply(packages, library, character.only = TRUE))
  
  rm(installed_packages)
  rm(packages)
}

metro.packages()
rm(metro.packages)