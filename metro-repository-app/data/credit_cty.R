# Urban Institute Data Catalog, Credit Health during the COVID-19 Pandemic

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

credit.url <- "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2022/02/08/covidcredithealth_county.xlsx"
download.file(credit.url, "covidcredithealth_county.xlsx", quiet = TRUE, mode = "wb")
credit <- read_excel("covidcredithealth_county.xlsx")
file.remove("covidcredithealth_county.xlsx")
rm(credit.url)

names(credit)[names(credit) == 'county'] <- 'stco_code'

oldw <- getOption("warn")
options(warn = -1)
credit[,-1] <- lapply(credit[,-1], as.numeric)
options(warn = oldw)
rm(oldw)

# Encode county names ------------------------

library(tidycensus)
data(fips_codes)

fips_codes$stco_name <- NA
fips_codes$stco_name <- as.character(fips_codes$stco_name)

fips_codes$stco_name <- paste(fips_codes$county, ", ", fips_codes$state_name)
fips_codes$stco_name <- gsub('  ', ' ',fips_codes$stco_name)
fips_codes$stco_name <- gsub(' ,', ',',fips_codes$stco_name)

fips_codes$stco_code <- NA
fips_codes$stco_code <- as.character(fips_codes$stco_code)

fips_codes$stco_code <- paste(fips_codes$state_code, fips_codes$county_code)
fips_codes$stco_code <- gsub(' ','',fips_codes$stco_code)

stco <- names(fips_codes) %in% c("stco_code", "stco_name")
fips_codes <- fips_codes[stco]
rm(stco)

common_col_names <- intersect(names(credit), names(fips_codes))
credit <- merge(credit, fips_codes, by = common_col_names, all.x = TRUE)
rm(common_col_names)

rm(fips_codes)

credit <- credit %>% relocate(stco_name, .after = stco_code)

# ------------------------------------------------------------------

collections <- c("stco_code", "stco_name", "Share with Any Debt in Collections, All", "Median Debt in Collections, All", "Share with Any Debt in Collections, Majority White Communities", "Median Debt in Collections, Majority White Communities", "Share with Any Debt in Collections, Communities of Color", "Median Debt in Collections, Communities of Color")
collections <- credit[collections]

ccu <- c("stco_code", "stco_name", "Average Credit Card Utilization, All", "Average Credit Card Utilization, Majority White Communities", "Average Credit Card Utilization, Communities of Color")
ccu <- credit[ccu]

cc_delinquency <- c("stco_code", "stco_name", "Credit Card Delinquency Rate (30+), All", "Credit Card Delinquency Rate (30+), Majority White Communities", "Credit Card Delinquency Rate (30+), Communities of Color")
cc_delinquency <- credit[cc_delinquency]

sl_delinquency <- c("stco_code", "stco_name", "Student Loan Delinquency Rate (60+), All", "Student Loan Delinquency Rate (60+), Majority White Communities", "Student Loan Delinquency Rate (60+), Communities of Color")
sl_delinquency <- credit[sl_delinquency]

ar_delinquency <- c("stco_code", "stco_name", "Auto/Retail Loan Delinquency Rate (60+), All", "Auto/Retail Loan Delinquency Rate (60+), Majority White Communities", "Auto/Retail Loan Delinquency Rate (60+), Communities of Color")
ar_delinquency <- credit[ar_delinquency]

mort_delinquency <- c("stco_code", "stco_name", "Mortgage Delinquency Rate (30+), All", "Mortgage Delinquency Rate (30+), Majority White Communities", "Mortgage Delinquency Rate (30+), Communities of Color")
mort_delinquency <- credit[mort_delinquency]

afs_credit <- c("stco_code", "stco_name", "Share with AFS Credit, All", "Share with AFS Credit, Majority White Communities", "Share with AFS Credit, Communities of Color")
afs_credit<- credit[afs_credit]

afs_delinquency <- c("stco_code", "stco_name", "AFS Credit Delinquency Rate (30+), All", "AFS Credit Delinquency Rate (30+), Majority White Communities", "AFS Credit Delinquency Rate (30+), Communities of Color")
afs_delinquency <- credit[afs_delinquency]

credit_score <- c("stco_code", "stco_name", "Median Credit Score, All", "Median Credit Score, Majority White Communities", "Median Credit Score, Communities of Color")
credit_score <- credit[credit_score]

credit_score_subprime <- c("stco_code", "stco_name", "Share with Subprime Credit Score, All", "Share with Subprime Credit Score, Majority White Communities", "Share with Subprime Credit Score, Communities of Color")
credit_score_subprime <- credit[credit_score_subprime]

rm(credit)

list_debtinamerica_afs_credit <- names(afs_credit)
list_debtinamerica_afs_delinquency <- names(afs_delinquency)
list_debtinamerica_ar_delinquency <- names(ar_delinquency)
list_debtinamerica_cc_delinquency <- names(cc_delinquency)
list_debtinamerica_ccu <- names(ccu)
list_debtinamerica_collections <- names(collections)
list_debtinamerica_credit_score <- names(credit_score)
list_debtinamerica_credit_score_subprime <- names(credit_score_subprime)
list_debtinamerica_mort_delinquency <- names(mort_delinquency)
list_debtinamerica_sl_delinquency <- names(sl_delinquency)

credit <- afs_credit

common_col_names <- intersect(names(credit), names(afs_credit))
credit <- merge(credit, afs_credit, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(credit), names(afs_delinquency))
credit <- merge(credit, afs_delinquency, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(credit), names(ar_delinquency))
credit <- merge(credit, ar_delinquency, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(credit), names(cc_delinquency))
credit <- merge(credit, cc_delinquency, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(credit), names(ccu))
credit <- merge(credit, ccu, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(credit), names(collections))
credit <- merge(credit, collections, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(credit), names(credit_score))
credit <- merge(credit, credit_score, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(credit), names(mort_delinquency))
credit <- merge(credit, mort_delinquency, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(credit), names(sl_delinquency))
credit <- merge(credit, sl_delinquency, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(credit), names(credit_score_subprime))
credit <- merge(credit, credit_score_subprime, by = common_col_names, all.x = TRUE)
rm(common_col_names)


