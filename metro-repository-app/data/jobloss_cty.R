# Urban Institute Data Catalog, Estimated Low Income Jobs Lost to COVID-19

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
library(readxl)
library(openxlsx)
library(writexl)

jobloss.url <- "https://ui-lodes-job-change-public.s3.amazonaws.com/sum_job_loss_county.csv"
download.file(jobloss.url, "sum_job_loss_county.csv", quiet = TRUE, mode = "wb")
jobloss <- read.csv("sum_job_loss_county.csv")
file.remove("sum_job_loss_county.csv")
rm(jobloss.url)

jobloss$county_fips <- as.character(jobloss$county_fips)
for(i in 1:length(jobloss$county_fips)) {
  if(as.numeric(jobloss$county_fips[i]) < 10000) {
    jobloss$county_fips[i] <- paste0("0", jobloss$county_fips[i])
  }
}
rm(i)

X <- c("county_fips", "total_li_workers_employed", "X000", "low_income_worker_job_loss_rate")
jobloss <- jobloss[X]
rm(X)

names(jobloss)[names(jobloss) == 'county_fips'] <- 'stco_code'
names(jobloss)[names(jobloss) == 'total_li_workers_employed'] <- 'Total low-income workers employed'
names(jobloss)[names(jobloss) == 'X000'] <- 'Total low-income jobs lost'
names(jobloss)[names(jobloss) == 'low_income_worker_job_loss_rate'] <- 'Low-income worker job loss rate'

list_jobloss <- names(jobloss)
