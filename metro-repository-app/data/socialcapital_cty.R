# Opportunity Atlas Social Capital

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

socialcapital.url <- "https://data.humdata.org/dataset/85ee8e10-0c66-4635-b997-79b6fad44c71/resource/ec896b64-c922-4737-b759-e4bd7f73b8cc/download/social_capital_county.csv"
download.file(socialcapital.url, "social_capital_county.csv", quiet = TRUE, mode = "wb")
socialcapital <- read.csv("social_capital_county.csv")
file.remove("social_capital_county.csv")
rm(socialcapital.url)

names(socialcapital)[names(socialcapital) == 'county'] <- 'county_fips'

socialcapital$county_fips <- as.character(socialcapital$county_fips)
for(i in 1:length(socialcapital$county_fips)) {
  if(as.numeric(socialcapital$county_fips[i]) < 10000) {
    socialcapital$county_fips[i] <- paste0("0", socialcapital$county_fips[i])
  }
}
rm(i)

remove <- names(socialcapital) %in% c("county_name", "pop2018", "child_bias_county", "bias_grp_mem_high_county", "ec_grp_mem_high_county", "ec_se_county", "child_ec_se_county", "ec_grp_mem_county", "ec_high_se_county", "child_high_ec_se_county")
socialcapital <- socialcapital[!remove]
rm(remove)

names(socialcapital)[names(socialcapital) == 'county_fips'] <- 'stco_code'
names(socialcapital)[names(socialcapital) == 'num_below_p50'] <- 'Number of children with below-national-median parental household income'
names(socialcapital)[names(socialcapital) == 'ec_county'] <- 'Baseline economic connectedness'
names(socialcapital)[names(socialcapital) == 'child_ec_county'] <- 'Childhood economic connectedness'
names(socialcapital)[names(socialcapital) == 'ec_high_county'] <- 'Economic connectedness for high-SES individuals'
names(socialcapital)[names(socialcapital) == 'child_high_ec_county'] <- 'Childhood economic connectedness for high-SES individuals'
names(socialcapital)[names(socialcapital) == 'exposure_grp_mem_county'] <- 'Mean exposure to high-SES individuals for low-SES individuals'
names(socialcapital)[names(socialcapital) == 'exposure_grp_mem_high_county'] <- 'Mean exposure to high-SES individuals for high-SES individuals'
names(socialcapital)[names(socialcapital) == 'child_exposure_county'] <- 'Mean exposure to high-parental-SES peers in high school (averaged over low-parental-SES)'
names(socialcapital)[names(socialcapital) == 'child_high_exposure_county'] <- 'Mean exposure to high-parental-SES peers in high school (averaged over high-parental-SES)'
names(socialcapital)[names(socialcapital) == 'bias_grp_mem_county'] <- 'Friending bias, all'
names(socialcapital)[names(socialcapital) == 'bias_Grp_mem_high_county'] <- 'Friending bias, high-SES'
names(socialcapital)[names(socialcapital) == 'child_high_bias_county'] <- 'Childhood friending bias, high-SES'
names(socialcapital)[names(socialcapital) == 'clustering_county'] <- 'Fraction of individual friend pairs who are also friends with each other'
names(socialcapital)[names(socialcapital) == 'support_ratio_county'] <- 'Proportion of within-county-friendships where pair of friends share a third mutual friend in the same county'
names(socialcapital)[names(socialcapital) == 'volunteering_rate_county'] <- 'Percentage of Facebook users who are members of a group about volunteering or activism'
names(socialcapital)[names(socialcapital) == 'civic_organizations_county'] <- 'Number of Facebook Pages predicted to be Public Good pages'

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

common_col_names <- intersect(names(socialcapital), names(fips_codes))
socialcapital <- merge(socialcapital, fips_codes, by = common_col_names, all.x = TRUE)
rm(common_col_names)

rm(fips_codes)

socialcapital <- socialcapital %>% relocate(stco_name, .after = stco_code)

# ------------------------------------------------------------------

childhood_sc <- c("stco_code", "stco_name", "Number of children with below-national-median parental household income", "Childhood economic connectedness", "Childhood economic connectedness for high-SES individuals",
                  "Mean exposure to high-parental-SES peers in high school (averaged over low-parental-SES)", "Mean exposure to high-parental-SES peers in high school (averaged over high-parental-SES)",
                  "Childhood friending bias, high-SES")
childhood_sc <- socialcapital[childhood_sc]

economic_connectedness <- c("stco_code", "stco_name", "Baseline economic connectedness", "Childhood economic connectedness", "Economic connectedness for high-SES individuals", "Childhood economic connectedness for high-SES individuals")
economic_connectedness <- socialcapital[economic_connectedness]

SES_exposure <- c("stco_code", "stco_name", "Mean exposure to high-SES individuals for low-SES individuals", "Mean exposure to high-SES individuals for high-SES individuals",
                  "Mean exposure to high-parental-SES peers in high school (averaged over low-parental-SES)", "Mean exposure to high-parental-SES peers in high school (averaged over high-parental-SES)")
SES_exposure <- socialcapital[SES_exposure]

friending_bias <- c("stco_code", "stco_name", "Friending bias, all", "Childhood friending bias, high-SES")
friending_bias <- socialcapital[friending_bias]

mutual_friends <- c("stco_code", "stco_name", "Fraction of individual friend pairs who are also friends with each other", "Proportion of within-county-friendships where pair of friends share a third mutual friend in the same county")
mutual_friends <- socialcapital[mutual_friends]

public_good <- c("stco_code", "stco_name", "Percentage of Facebook users who are members of a group about volunteering or activism", "Number of Facebook Pages predicted to be Public Good pages")
public_good <- socialcapital[public_good]

list_socialcapitalatlas_childhood_sc <- names(childhood_sc)
list_socialcapitalatlas_economic_connectedness <- names(economic_connectedness)
list_socialcapitalatlas_friending_bias <- names(friending_bias)
list_socialcapitalatlas_mutual_friends <- names(mutual_friends)
list_socialcapitalatlas_public_good <- names(public_good)
list_socialcapitalatlas_SES_exposure <- names(SES_exposure)
