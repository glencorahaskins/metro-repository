# install.packages("tidyverse")
# install.packages("tidycensus")
# install.packages("censusapi")
# install.packages("dplyr")
# install.packages("shiny")
# install.packages("markdown")
# install.packages("ggplot2")
# install.packages("plotly")
# install.packages("DT")

library(tidyverse)
library(tidycensus)
library(censusapi)
library(dplyr)
library(shiny)
library(markdown)
library(ggplot2)
library(plotly)
library(DT)

Sys.setenv(CENSUS_KEY="0ccc9ebd9112a7ca28c9d900f8aac70dedc4ffbc")

all_apis <- listCensusApis()
head(all_apis)

age <- getCensus(name = "acs/acs5/profile", vintage = 2020, vars = c("NAME", "DP05_0001E", "DP05_0005E", "DP05_0006E", "DP05_0007E", "DP05_0008E", "DP05_0009E", "DP05_0010E", "DP05_0011E", "DP05_0012E", "DP05_0013E", "DP05_0014E", "DP05_0015E", "DP05_0016E", "DP05_0017E", "DP05_0019E", "DP05_0020E", "DP05_0021E", "DP05_0022E", "DP05_0023E", "DP05_0024E"),
                  region = "county:*",
                  regionin = "state:*")

sex <- getCensus(name = "acs/acs5/profile", vintage = 2020, vars = c("NAME", "DP05_0001E", "DP05_0002E", "DP05_0003E"),
                  region = "county:*",
                  regionin = "state:*")

race <- getCensus(name = "acs/acs5/profile", vintage = 2020, vars = c("NAME", "DP05_0001E", "DP05_0077E", "DP05_0078E", "DP05_0079E", "DP05_0080E", "DP05_0081E", "DP05_0082E", "DP05_0083E", "DP05_0071E"),
                  region = "county:*",
                  regionin = "state:*")

age$stco_code <- paste(age$state, age$county)
age$stco_code <- gsub(' ','',age$stco_code)

sex$stco_code <- paste(sex$state, sex$county)
sex$stco_code <- gsub(' ','',sex$stco_code)

race$stco_code <- paste(race$state, race$county)
race$stco_code <- gsub(' ','',race$stco_code)

age <- age %>% relocate(stco_code, .before = state)
sex <- sex %>% relocate(stco_code, .before = state)
race <- race %>% relocate(stco_code, .before = state)

names(age) <- c('stco_code', 'state', 'county', 'stco_name', 'Total population', 'Population, under 5 years', 'Population, 5 to 9 years', 'Population, 10 to 14 years', 'Population, 15 to 19 years', 'Population, 20 to 24 years', 'Population, 25 to 34 years', 'Population, 35 to 44 years', 'Population, 45 to 54 years', 'Population, 55 to 59 years', 'Population, 60 to 64 years', 'Population, 65 to 74 years', 'Population, 75 to 84 years', 'Population, 85 years and older', 'Population, under 18 years', 'Population, 16 years and over', 'Population, 18 years and older', 'Population, 21 years and older', 'Population, 62 years and older', 'Population, 65 years and older')
names(sex) <- c('stco_code', 'state', 'county', 'stco_name', 'Total population', 'Population, male', 'Population, female')
names(race) <- c('stco_code', 'state', 'county', 'stco_name', 'Total population', 'Population, White', 'Population, Black or African American', 'Population, American Indian and Alaska Native', 'Population, Asian', 'Population, Native Hawaiian and Pacific Islander', 'Population, Other race', 'Population, Two or more races', 'Population, Hispanic or Latino')

`Demographic and housing estimates, age` <- names(age)
`Demographic and housing estimates, sex` <- names(sex)
`Demographic and housing estimates, race` <- names(race)

dfs <- objects()
df_co_all <- mget(dfs[grep("list_",dfs)])

co_all <- age

co_all <- co_all %>%
          left_join(sex, by='stco_code', all.x=TRUE) %>%  left_join(race, by='stco_code', all.x=TRUE)

common <- co_all %>% select(ends_with(c(".x", ".y")))
list_common <- names(common)
co_all <- co_all[,-which(names(co_all) %in% list_common)]

co_all <- co_all %>% relocate(state, .after = stco_code)
co_all <- co_all %>% relocate(county, .after = state)
co_all <- co_all %>% relocate(stco_name, .after = county)
co_all <- co_all %>% relocate(`Total population`, .after = stco_name)

list_all_co <- df_co_all




