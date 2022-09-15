library(censusapi)
library(data.table)
library(dplyr)
library(DT)
library(ggplot2)
library(markdown)
library(plotly)
library(readr)
library(rJava)
library(shiny)
library(stringr)
library(sqldf)
library(tidycensus)
library(tidyverse)
library(writexl)
library(readxl)
library(xlsx)

link_auto <- "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2022/06/16/county_dia_auto_%207%20Jun%202022.xlsx"
download.file(link_auto, "county_dia_auto_7 June 2022.xlsx", quiet = TRUE, mode = "wb")
debt_auto <- read_excel("county_dia_auto_7 June 2022.xlsx")
file.remove("county_dia_auto_7 June 2022.xlsx")
rm("link_auto")

link_med <- "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2022/06/16/county_dia_medical_%207%20Jun%202022.xlsx"
download.file(link_med, "county_dia_medical_7 June 2022.xlsx", quiet = TRUE, mode = "wb")
debt_med <- read_excel("county_dia_medical_7 June 2022.xlsx")
file.remove("county_dia_medical_7 June 2022.xlsx")
rm("link_med")

link_student <- "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2022/06/16/county_dia_student_%207%20Jun%202022.xlsx"
download.file(link_student, "county_dia_student_7 June 2022.xlsx", quiet = TRUE, mode = "wb")
debt_student <- read_excel("county_dia_student_7 June 2022.xlsx")
file.remove("county_dia_student_7 June 2022.xlsx")
rm("link_student")

link_overall <- "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2022/06/16/county_dia_delinquency_%207%20Jun%202022.xlsx"
download.file(link_overall, "county_dia_delinquency_7 June 2022.xlsx", quiet = TRUE, mode = "wb")
debt_overall <- read_excel("county_dia_delinquency_7 June 2022.xlsx")
file.remove("county_dia_delinquency_7 June 2022.xlsx")
rm("link_overall")

debt_auto <- debt_auto %>%
  rename(stco_code = GEOID) %>%
  rename(stco_name = NAME)

debt_med <- debt_med %>%
  rename(stco_code = GEOID) %>%
  rename(stco_name = NAME)

debt_student <- debt_student %>%
  rename(stco_code = GEOID) %>%
  rename(stco_name = NAME)

debt_overall <- debt_overall %>%
  rename(stco_code = GEOID) %>%
  rename(stco_name = NAME)

oldw <- getOption("warn")

options(warn=-1)
debt_auto[ ,-c(1:3)] <- sapply(debt_auto[ ,-c(1:3)], as.numeric)
debt_med[ ,-c(1:3)] <- sapply(debt_med[ ,-c(1:3)], as.numeric)
debt_student[ ,-c(1:3)] <- sapply(debt_student[ ,-c(1:3)], as.numeric)
debt_overall[ ,-c(1:3)] <- sapply(debt_overall[ ,-c(1:3)], as.numeric)
options(warn = oldw)

rm(oldw)

list_auto <- names(debt_auto)
list_med <- names(debt_med)
list_student <- names(debt_student)
list_overall <- names(debt_overall)

debt_cty <- debt_overall

common <- intersect(names(debt_cty), names(debt_overall))
debt_cty <- merge(debt_cty, debt_overall, by=common, all.x=TRUE)
rm(common)

common <- intersect(names(debt_cty), names(debt_auto))
debt_cty <- merge(debt_cty, debt_auto, by=common, all.x=TRUE)
rm(common)


common <- intersect(names(debt_cty), names(debt_med))
debt_cty <- merge(debt_cty, debt_med, by=common, all.x=TRUE)
rm(common)

common <- intersect(names(debt_cty), names(debt_student))
debt_cty <- merge(debt_cty, debt_student, by=common, all.x=TRUE)
rm(common)








