# install.packages('censusapi')
# install.packages('data.table')
# install.packages('dplyr')
# install.packages('DT')
# install.packages('ggplot2')
# install.packages('markdown')
# install.packages('plotly')
# install.packages('readr')
# install.packages('rJava')
# install.packages('shiny')
# install.packages('stringr')
# install.packages('sqldf')
# install.packages('tidycensus')
# install.packages('tidyverse')
# install.packages('writexl')
# install.packages('xlsx')

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
library(xlsx)

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

marriage <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S1201_C01_001E', 'S1201_C02_001E', 'S1201_C03_001E', 'S1201_C04_001E', 'S1201_C05_001E', 'S1201_C06_001E'), 
                      region = 'county:*', 
                      regionin = 'state:*')

geo_mobility <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S0701_C01_001E', 'S0701_C02_001E', 'S0701_C03_001E', 'S0701_C04_001E', 'S0701_C05_001E'), 
                          region = 'county:*', 
                          regionin = 'state:*')

commutes <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S0802_C01_001E', 'S0802_C02_001E', 'S0802_C03_001E', 'S0802_C04_001E'), 
                      region = 'county:*', 
                      regionin = 'state:*')

births <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S1301_C01_001E', 'S1301_C02_001E', 'S1301_C01_002E', 'S1301_C02_002E', 'S1301_C01_003E', 'S1301_C02_003E', 'S1301_C01_004E', 'S1301_C02_004E'), 
                    region = 'county:*', 
                    regionin = 'state:*')

med_earnings_race <- getCensus(name = 'acs/acs5', vintage = 2020, vars = c('NAME', 'B20017_001E', 'B20017B_001E', 'B20017C_001E', 'B20017D_001E', 'B20017E_001E', 'B20017F_001E', 'B20017G_001E', 'B20017H_001E', 'B20017I_001E'), 
                               region = 'county:*', 
                               regionin = 'state:*')

med_earnings_cat <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S2001_C01_001E', 'S2001_C01_003E', 'S2001_C01_004E', 'S2001_C01_005E', 'S2001_C01_006E', 'S2001_C01_007E', 'S2001_C01_008E', 'S2001_C01_009E', 'S2001_C01_010E', 'S2001_C01_011E', 'S2001_C01_012E'), 
                              region = 'county:*', 
                              regionin = 'state:*')

lfpr <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S2301_C02_001E', 'S2301_C02_013E', 'S2301_C02_014E', 'S2301_C02_015E', 'S2301_C02_016E', 'S2301_C02_017E', 'S2301_C02_018E', 'S2301_C02_020E', 'S2301_C02_019E'), 
                  region = 'county:*', 
                  regionin = 'state:*')

epr <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S2301_C03_001E', 'S2301_C03_013E', 'S2301_C03_014E', 'S2301_C03_015E', 'S2301_C03_016E', 'S2301_C03_017E', 'S2301_C03_018E', 'S2301_C03_020E', 'S2301_C03_019E'), 
                 region = 'county:*', 
                 regionin = 'state:*')

educ <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S1501_C01_006E', 'S1501_C01_007E', 'S1501_C01_008E', 'S1501_C01_009E', 'S1501_C01_010E', 'S1501_C01_011E', 'S1501_C01_012E', 'S1501_C01_013E', 'S1501_C01_014E', 'S1501_C01_015E'), 
                  region = 'county:*', 
                  regionin = 'state:*')

hs_diploma <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S1501_C01_034E', 'S1501_C01_037E', 'S1501_C01_040E', 'S1501_C01_043E', 'S1501_C01_046E', 'S1501_C01_049E', 'S1501_C01_031E', 'S1501_C01_052E', 'S1501_C01_035E', 'S1501_C01_038E', 'S1501_C01_041E', 'S1501_C01_044E', 'S1501_C01_047E', 'S1501_C01_050E', 'S1501_C01_032E', 'S1501_C01_053E'), 
                        region = 'county:*', 
                        regionin = 'state:*')

bach_degree <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S1501_C01_034E', 'S1501_C01_037E', 'S1501_C01_040E', 'S1501_C01_043E', 'S1501_C01_046E', 'S1501_C01_049E', 'S1501_C01_031E', 'S1501_C01_052E', 'S1501_C01_036E', 'S1501_C01_039E', 'S1501_C01_042E', 'S1501_C01_045E', 'S1501_C01_048E', 'S1501_C01_051E', 'S1501_C01_033E', 'S1501_C01_054E'), 
                         region = 'county:*', 
                         regionin = 'state:*')

poverty <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S1701_C01_001E', 'S1701_C01_014E', 'S1701_C01_015E', 'S1701_C01_016E', 'S1701_C01_017E', 'S1701_C01_018E', 'S1701_C01_019E', 'S1701_C01_021E', 'S1701_C01_020E', 'S1701_C02_001E', 'S1701_C02_014E', 'S1701_C02_015E', 'S1701_C02_016E', 'S1701_C02_017E', 'S1701_C02_018E', 'S1701_C02_019E', 'S1701_C02_021E', 'S1701_C02_020E'), 
                     region = 'county:*', 
                     regionin = 'state:*')

rent <- getCensus(name = 'acs/acs5', vintage = 2020, vars = c('NAME', 'B25070_001E', 'B25070_002E', 'B25070_003E', 'B25070_004E', 'B25070_005E', 'B25070_006E', 'B25070_007E', 'B25070_008E', 'B25070_009E', 'B25070_010E', 'B25070_011E'), 
                  region = 'county:*', 
                  regionin = 'state:*')

internet <- getCensus(name = 'acs/acs5', vintage = 2020, vars = c('NAME', 'B28002_001E', 'B28002_002E', 'B28002_012E', 'B28002_013E'), 
                      region = 'county:*', 
                      regionin = 'state:*')

insurance <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S2701_C01_001E', 'S2701_C01_017E', 'S2701_C01_018E', 'S2701_C01_019E', 'S2701_C01_020E', 'S2701_C01_021E', 'S2701_C01_022E', 'S2701_C01_024E', 'S2701_C01_023E', 'S2701_C02_001E', 'S2701_C02_017E', 'S2701_C02_018E', 'S2701_C02_019E', 'S2701_C02_020E', 'S2701_C02_021E', 'S2701_C02_022E', 'S2701_C02_024E', 'S2701_C02_023E'), 
                       region = 'county:*', 
                       regionin = 'state:*')

snap <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S2201_C01_001E', 'S2201_C01_026E', 'S2201_C01_027E', 'S2201_C01_028E', 'S2201_C01_029E', 'S2201_C01_030E', 'S2201_C01_031E', 'S2201_C01_033E', 'S2201_C01_032E', 'S2201_C03_001E', 'S2201_C03_026E', 'S2201_C03_027E', 'S2201_C03_028E', 'S2201_C03_029E', 'S2201_C03_030E', 'S2201_C03_031E', 'S2201_C03_033E', 'S2201_C03_032E'), 
                  region = 'county:*', 
                  regionin = 'state:*')

language <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S1601_C01_001E', 'S1601_C01_002E', 'S1601_C01_003E'), 
                      region = 'county:*', 
                      regionin = 'state:*')

disability <- getCensus(name = 'acs/acs5/subject', vintage = 2020, vars = c('NAME', 'S1810_C01_001E', 'S1810_C02_001E'), 
                        region = 'county:*', 
                        regionin = 'state:*')

age$stco_code <- paste(age$state, age$county)
age$stco_code <- gsub(' ','',age$stco_code)

sex$stco_code <- paste(sex$state, sex$county)
sex$stco_code <- gsub(' ','',sex$stco_code)

race$stco_code <- paste(race$state, race$county)
race$stco_code <- gsub(' ','',race$stco_code)

marriage$stco_code <- paste(marriage$state, marriage$county)
marriage$stco_code <- gsub(' ','',marriage$stco_code)

geo_mobility$stco_code <- paste(geo_mobility$state, geo_mobility$county)
geo_mobility$stco_code <- gsub(' ','',geo_mobility$stco_code)

commutes$stco_code <- paste(commutes$state, commutes$county)
commutes$stco_code <- gsub(' ','',commutes$stco_code)

births$stco_code <- paste(births$state, births$county)
births$stco_code <- gsub(' ','',births$stco_code)

med_earnings_race$stco_code <- paste(med_earnings_race$state, med_earnings_race$county)
med_earnings_race$stco_code <- gsub(' ','',med_earnings_race$stco_code)

med_earnings_cat$stco_code <- paste(med_earnings_cat$state, med_earnings_cat$county)
med_earnings_cat$stco_code <- gsub(' ','',med_earnings_cat$stco_code)

lfpr$stco_code <- paste(lfpr$state, lfpr$county)
lfpr$stco_code <- gsub(' ','',lfpr$stco_code)

epr$stco_code <- paste(epr$state, epr$county)
epr$stco_code <- gsub(' ','',epr$stco_code)

educ$stco_code <- paste(educ$state, educ$county)
educ$stco_code <- gsub(' ','',educ$stco_code)

hs_diploma$stco_code <- paste(hs_diploma$state, hs_diploma$county)
hs_diploma$stco_code <- gsub(' ','',hs_diploma$stco_code)

bach_degree$stco_code <- paste(bach_degree$state, bach_degree$county)
bach_degree$stco_code <- gsub(' ','',bach_degree$stco_code)

poverty$stco_code <- paste(poverty$state, poverty$county)
poverty$stco_code <- gsub(' ','',poverty$stco_code)

rent$stco_code <- paste(rent$state, rent$county)
rent$stco_code <- gsub(' ','',rent$stco_code)

internet$stco_code <- paste(internet$state, internet$county)
internet$stco_code <- gsub(' ','',internet$stco_code)

insurance$stco_code <- paste(insurance$state, insurance$county)
insurance$stco_code <- gsub(' ','',insurance$stco_code)

snap$stco_code <- paste(snap$state, snap$county)
snap$stco_code <- gsub(' ','',snap$stco_code)

language$stco_code <- paste(language$state, language$county)
language$stco_code <- gsub(' ','',language$stco_code)

disability$stco_code <- paste(disability$state, disability$county)
disability$stco_code <- gsub(' ','',disability$stco_code)

age <- age %>% relocate(stco_code, .before = state)
sex <- sex %>% relocate(stco_code, .before = state)
race <- race %>% relocate(stco_code, .before = state)
marriage <- marriage %>% relocate(stco_code, .before = state)
geo_mobility <- geo_mobility %>% relocate(stco_code, .before = state)
commutes <- commutes %>% relocate(stco_code, .before = state)
births <- births %>% relocate(stco_code, .before = state)
med_earnings_race <- med_earnings_race %>% relocate(stco_code, .before = state)
med_earnings_cat <- med_earnings_cat %>% relocate(stco_code, .before = state)
lfpr <- lfpr %>% relocate(stco_code, .before = state)
epr <- epr %>% relocate(stco_code, .before = state)
educ <- educ %>% relocate(stco_code, .before = state)
hs_diploma <- hs_diploma %>% relocate(stco_code, .before = state)
bach_degree <- bach_degree %>% relocate(stco_code, .before = state)
poverty <- poverty %>% relocate(stco_code, .before = state)
rent <- rent %>% relocate(stco_code, .before = state)
internet <- internet %>% relocate(stco_code, .before = state)
insurance <- insurance %>% relocate(stco_code, .before = state)
snap <- snap %>% relocate(stco_code, .before = state)
language <- language %>% relocate(stco_code, .before = state)
disability <- disability %>% relocate(stco_code, .before = state)

names(age) <- c('stco_code', 'state', 'county', 'stco_name', 'Total population', 'Population, under 5 years', 'Population, 5 to 9 years', 'Population, 10 to 14 years', 'Population, 15 to 19 years', 'Population, 20 to 24 years', 'Population, 25 to 34 years', 'Population, 35 to 44 years', 'Population, 45 to 54 years', 'Population, 55 to 59 years', 'Population, 60 to 64 years', 'Population, 65 to 74 years', 'Population, 75 to 84 years', 'Population, 85 years and older', 'Population, under 18 years', 'Population, 16 years and over', 'Population, 18 years and older', 'Population, 21 years and older', 'Population, 62 years and older', 'Population, 65 years and older')
names(sex) <- c('stco_code', 'state', 'county', 'stco_name', 'Total population', 'Population, male', 'Population, female')
names(race) <- c('stco_code', 'state', 'county', 'stco_name', 'Total population', 'Population, White', 'Population, Black or African American', 'Population, American Indian and Alaska Native', 'Population, Asian', 'Population, Native Hawaiian and Pacific Islander', 'Population, Other race', 'Population, Two or more races', 'Population, Hispanic or Latino')
names(marriage) <- c('stco_code', 'state', 'county', 'stco_name', 'Population 15 years and over, total', 'Population 15 years and over, now married (except separated)', 'Population 15 years and over, widowed', 'Population 15 years and over, divorced', 'Population 15 years and over, separated', 'Population 15 years and over, never married')
names(geo_mobility) <- c('stco_code', 'state', 'county', 'stco_name', 'Population 1 year and over, total', 'Population 1 year and over, moved within same county', 'Population 1 year and over, moved from different county (same state)', 'Population 1 year and over, moved from different state', 'Population 1 year and over, moved from abroad')
names(commutes) <- c('stco_code', 'state', 'county', 'stco_name', 'Workers 16 years and over, total', 'Workers 16 years and over, drove alone', 'Workers 16 years and over, carpooled', 'Workers 16 years and over, public transit')
names(births) <- c('stco_code', 'state', 'county', 'stco_name', 'Women 15 to 50 years, total', 'Women 15 to 50 years, births in the past 12 months', 'Women 15 to 19 years, total', 'Women 15 to 19 years, births in the past 12 months', 'Women 20 to 34 years, total', 'Women 20 to 34 years, births in the past 12 months', 'Women 35 to 50 years, total', 'Women 35 to 50 years, births in the past 12 months')
names(med_earnings_race) <- c('stco_code', 'state', 'county', 'stco_name', 'Median earnings in the past 12 months, total ', 'Median earnings in the past 12 months, Black or African American ', 'Median earnings in the past 12 months, America Indian and Alaska Native ', 'Median earnings in the past 12 months, Asian ', 'Median earnings in the past 12 months, Native Hawaiian and Pacific Islander ', 'Median earnings in the past 12 months, Some other race ', 'Median earnings in the past 12 months, Two or more races ', 'Median earnings in the past 12 months, White (not Hispanic or Latino) ', 'Median earnings in the past 12 months, Hispanic or Latino ')
names(med_earnings_cat) <- c('stco_code', 'state', 'county', 'stco_name', 'Median earnings in the past 12 months, total population with earnings', 'Median earnings in the past 12 months, full-time workers with earnings', 'Median earnings in the past 12 months, $1 to $9,999 or loss', 'Median earnings in the past 12 months, $10,000 to $14,999', 'Median earnings in the past 12 months, $15,000 to $24,999', 'Median earnings in the past 12 months, $25,000 to $34,999', 'Median earnings in the past 12 months, $35,000 to $49,999', 'Median earnings in the past 12 months, $50,000 to $64,999', 'Median earnings in the past 12 months, $65,000 to $74,999', 'Median earnings in the past 12 months, $75,000 to $99,999', 'Median earnings in the past 12 months, $100,000 or more')
names(lfpr) <- c('stco_code', 'state', 'county', 'stco_name', 'Labor force participation rate, total ', 'Labor force participation rate, Black or African American ', 'Labor force participation rate, America Indian and Alaska Native ', 'Labor force participation rate, Asian ', 'Labor force participation rate, Native Hawaiian and Pacific Islander ', 'Labor force participation rate, Some other race ', 'Labor force participation rate, Two or more races ', 'Labor force participation rate, White (not Hispanic or Latino) ', 'Labor force participation rate, Hispanic or Latino ')
names(epr) <- c('stco_code', 'state', 'county', 'stco_name', 'Employment-to-population ratio, total ', 'Employment-to-population ratio, Black or African American ', 'Employment-to-population ratio, America Indian and Alaska Native ', 'Employment-to-population ratio, Asian ', 'Employment-to-population ratio, Native Hawaiian and Pacific Islander ', 'Employment-to-population ratio, Some other race ', 'Employment-to-population ratio, Two or more races ', 'Employment-to-population ratio, White (not Hispanic or Latino) ', 'Employment-to-population ratio, Hispanic or Latino ')
names(educ) <- c('stco_code', 'state', 'county', 'stco_name', 'Population 25 years and older, total', 'Population 25 years and older, less than 9th grade', 'Population 25 years and older, 9th to 12th grade, no diploma', 'Population 25 years and older, high school graduate', 'Population 25 years and older, some college, no degree', 'Population 25 years and older, associates degree', 'Population 25 years and older, bachelors degree', 'Population 25 years and older, graduate or professional degree', 'Population 25 years and older, high school graduate or higher', 'Population 25 years and older, bachelors degree or higher')
names(hs_diploma) <- c('stco_code', 'state', 'county', 'stco_name', 'Population with known educational attainment, Black or African American ', 'Population with known educational attainment, America Indian and Alaska Native ', 'Population with known educational attainment, Asian ', 'Population with known educational attainment, Native Hawaiian and Pacific Islander ', 'Population with known educational attainment, Some other race ', 'Population with known educational attainment, Two or more races ', 'Population with known educational attainment, White (not Hispanic or Latino) ', 'Population with known educational attainment, Hispanic or Latino ', 'Population with a high school diploma or higher, Black or African American ', 'Population with a high school diploma or higher, America Indian and Alaska Native ', 'Population with a high school diploma or higher, Asian ', 'Population with a high school diploma or higher, Native Hawaiian and Pacific Islander ', 'Population with a high school diploma or higher, Some other race ', 'Population with a high school diploma or higher, Two or more races ', 'Population with a high school diploma or higher, White (not Hispanic or Latino) ', 'Population with a high school diploma or higher, Hispanic or Latino ')
names(bach_degree) <- c('stco_code', 'state', 'county', 'stco_name', 'Population with known educational attainment, Black or African American ', 'Population with known educational attainment, America Indian and Alaska Native ', 'Population with known educational attainment, Asian ', 'Population with known educational attainment, Native Hawaiian and Pacific Islander ', 'Population with known educational attainment, Some other race ', 'Population with known educational attainment, Two or more races ', 'Population with known educational attainment, White (not Hispanic or Latino) ', 'Population with known educational attainment, Hispanic or Latino ', 'Population with a bachelors degree or higher, Black or African American ', 'Population with a bachelors degree or higher, America Indian and Alaska Native ', 'Population with a bachelors degree or higher, Asian ', 'Population with a bachelors degree or higher, Native Hawaiian and Pacific Islander ', 'Population with a bachelors degree or higher, Some other race ', 'Population with a bachelors degree or higher, Two or more races ', 'Population with a bachelors degree or higher, White (not Hispanic or Latino) ', 'Population with a bachelors degree or higher, Hispanic or Latino ')
names(poverty) <- c('stco_code', 'state', 'county', 'stco_name', 'Population with known poverty status, total ', 'Population with known poverty status, Black or African American ', 'Population with known poverty status, America Indian and Alaska Native ', 'Population with known poverty status, Asian ', 'Population with known poverty status, Native Hawaiian and Pacific Islander ', 'Population with known poverty status, Some other race ', 'Population with known poverty status, Two or more races ', 'Population with known poverty status, White (not Hispanic or Latino) ', 'Population with known poverty status, Hispanic or Latino ', 'Population below poverty level, total ', 'Population below poverty level, Black or African American ', 'Population below poverty level, America Indian and Alaska Native ', 'Population below poverty level, Asian ', 'Population below poverty level, Native Hawaiian and Pacific Islander ', 'Population below poverty level, Some other race ', 'Population below poverty level, Two or more races ', 'Population below poverty level, White (not Hispanic or Latino) ', 'Population below poverty level, Hispanic or Latino ')
names(rent) <- c('stco_code', 'state', 'county', 'stco_name', 'Gross rent as a percentage of household income, total', 'Gross rent as a percentage of household income, less than 10.0 percent', 'Gross rent as a percentage of household income, 10.0 to 14.9 percent', 'Gross rent as a percentage of household income, 15.0 to 19.9 percent', 'Gross rent as a percentage of household income, 20.0 to 24.9 percent', 'Gross rent as a percentage of household income, 25.0 to 29.9 percent', 'Gross rent as a percentage of household income, 30.0 to 34.9 percent', 'Gross rent as a percentage of household income, 35.0 to 39.9 percent', 'Gross rent as a percentage of household income, 40.0 to 49.9 percent', 'Gross rent as a percentage of household income, 50.0 percent or more', 'Gross rent as a percentage of household income, not computed')
names(internet) <- c('stco_code', 'state', 'county', 'stco_name', 'Population of households, total', 'Population of households with an internet subscription', 'Population of households with internet access without a subscription', 'Population of households with no internet access')
names(insurance) <- c('stco_code', 'state', 'county', 'stco_name', 'Total civilian non-institutionalized population, all races', 'Total civilian non-institutionalized population, Black or African American ', 'Total civilian non-institutionalized population, America Indian and Alaska Native ', 'Total civilian non-institutionalized population, Asian ', 'Total civilian non-institutionalized population, Native Hawaiian and Pacific Islander ', 'Total civilian non-institutionalized population, Some other race ', 'Total civilian non-institutionalized population, Two or more races ', 'Total civilian non-institutionalized population, White (not Hispanic or Latino) ', 'Total civilian non-institutionalized population, Hispanic or Latino ', 'Insured civilian non-institutionalized population, all races', 'Insured civilian non-institutionalized population, Black or African American ', 'Insured civilian non-institutionalized population, America Indian and Alaska Native ', 'Insured civilian non-institutionalized population, Asian ', 'Insured civilian non-institutionalized population, Native Hawaiian and Pacific Islander ', 'Insured civilian non-institutionalized population, Some other race ', 'Insured civilian non-institutionalized population, Two or more races ', 'Insured civilian non-institutionalized population, White (not Hispanic or Latino) ', 'Insured civilian non-institutionalized population, Hispanic or Latino ')
names(snap) <- c('stco_code', 'state', 'county', 'stco_name', 'Population of households with known SNAP status, all races', 'Population of households with known SNAP status, Black or African American ', 'Population of households with known SNAP status, America Indian and Alaska Native ', 'Population of households with known SNAP status, Asian ', 'Population of households with known SNAP status, Native Hawaiian and Pacific Islander ', 'Population of households with known SNAP status, Some other race ', 'Population of households with known SNAP status, Two or more races ', 'Population of households with known SNAP status, White (not Hispanic or Latino) ', 'Population of households with known SNAP status, Hispanic or Latino ', 'Population of households enrolled in SNAP, all races', 'Population of households enrolled in SNAP, Black or African American ', 'Population of households enrolled in SNAP, America Indian and Alaska Native ', 'Population of households enrolled in SNAP, Asian ', 'Population of households enrolled in SNAP, Native Hawaiian and Pacific Islander ', 'Population of households enrolled in SNAP, Some other race ', 'Population of households enrolled in SNAP, Two or more races ', 'Population of households enrolled in SNAP, White (not Hispanic or Latino) ', 'Population of households enrolled in SNAP, Hispanic or Latino ')
names(language) <- c('stco_code', 'state', 'county', 'stco_name', 'Population 5 years and over, total', 'Population 5 years and over, speak only English', 'Population 5 years and over, speak a language other than English')
names(disability) <- c('stco_code', 'state', 'county', 'stco_name', 'Civilian non-institutionalized population, total', 'Civilian non-institutionalized population, with a disability')

list_age <- names(age)
list_sex <- names(sex)
list_race <- names(race)
list_marriage <- names(marriage)
list_geo_mobility <- names(geo_mobility)
list_commutes <- names(commutes)
list_births <- names(births)
list_med_earnings_race <- names(med_earnings_race)
list_med_earnings_cat <- names(med_earnings_cat)
list_lfpr <- names(lfpr)
list_epr <- names(epr)
list_educ <- names(educ)
list_hs_diploma <- names(hs_diploma)
list_bach_degree <- names(bach_degree)
list_poverty <- names(poverty)
list_rent <- names(rent)
list_internet <- names(internet)
list_insurance <- names(insurance)
list_snap <- names(snap)
list_language <- names(language)
list_disability <- names(disability)

dfs <- objects()
df_co_all <- mget(dfs[grep("list_",dfs)])

co_all <- age

co_all <- co_all %>%
  left_join(sex, by='stco_code', all.x=TRUE) %>%  
  left_join(race, by='stco_code', all.x=TRUE) %>%  
  left_join(marriage, by='stco_code', all.x=TRUE) %>% 
  left_join(geo_mobility, by='stco_code', all.x=TRUE) %>% 
  left_join(commutes, by='stco_code', all.x=TRUE) %>% 
  left_join(births, by='stco_code', all.x=TRUE) %>% 
  left_join(med_earnings_race, by='stco_code', all.x=TRUE) %>% 
  left_join(med_earnings_cat, by='stco_code', all.x=TRUE) %>% 
  left_join(lfpr, by='stco_code', all.x=TRUE) %>% 
  left_join(epr, by='stco_code', all.x=TRUE) %>% 
  left_join(educ, by='stco_code', all.x=TRUE) %>% 
  left_join(hs_diploma, by='stco_code', all.x=TRUE) %>% 
  left_join(bach_degree, by='stco_code', all.x=TRUE) %>% 
  left_join(poverty, by='stco_code', all.x=TRUE) %>% 
  left_join(rent, by='stco_code', all.x=TRUE) %>% 
  left_join(internet, by='stco_code', all.x=TRUE) %>% 
  left_join(insurance, by='stco_code', all.x=TRUE) %>% 
  left_join(snap, by='stco_code', all.x=TRUE) %>% 
  left_join(language, by='stco_code', all.x=TRUE) %>% 
  left_join(disability, by='stco_code', all.x=TRUE)

common <- co_all %>% select(ends_with(c(".x", ".y")))
list_common <- names(common)
co_all <- co_all[,-which(names(co_all) %in% list_common)]

co_all <- co_all %>% relocate(state, .after = stco_code)
co_all <- co_all %>% relocate(county, .after = state)
co_all <- co_all %>% relocate(stco_name, .after = county)
co_all <- co_all %>% relocate(`Total population`, .after = stco_name)

list_all_co <- df_co_all

list_all_co[order(names(list_all_co))]

names(list_all_co) <- c('Demographic and housing estimates, population by age', 
                        'Population with a bachelors degree or higher, by race',
                        'Births in the past 12 months, by age', 
                        'Means of transportation to work by selected characteristics', 
                        'Disability characteristics', 
                        'Educational attainment, population 25 years and older', 
                        'Employment-to-population ratio, by race', 
                        'Geographic mobility by selected characteristics', 
                        'Population with a high school diploma or higher, by race', 
                        'Selected characteristics of health insurance coverage, by race', 
                        'Presence and types of internet subscriptions', 
                        'Language spoken at home', 
                        'Labor force participation rate, by race', 
                        'Marital status', 
                        'Median earnings in the past 12 months (categorized)', 
                        'Median earnings in the past 12 months by race (in dollars)', 
                        'Poverty status in the past 12 months, by race', 
                        'Demographic and housing estimates, population by race', 
                        'Gross rent as a percentage of household income', 
                        'Demographic and housing estimates, population by sex', 
                        'Households enrolled in SNAP, by race')

