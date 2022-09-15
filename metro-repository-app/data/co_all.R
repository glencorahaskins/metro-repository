setwd("C:/Users/ghask/The Brookings Institution/Metro Research - JParilla/Glencora/GitHub/metro-repository/metro-repository-app")

library(devtools)
acs_cty.url <- "https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-repository-app/data/acs_cty_test2.R"
urbaninstitute_cty.url <- "https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-repository-app/data/urbaninstitute_cty.R"

source_url(acs_cty.url)
source_url(urbaninstitute_cty.url)

co_all <- acs_cty

common_cty <- intersect(names(co_all), names(acs_cty))
co_all <- merge(co_all, acs_cty, by=common_cty, all.x=TRUE)
rm(common_cty)

common_cty <- intersect(names(co_all), names(debt_cty))
co_all <- merge(co_all, debt_cty, by=common_cty, all.x=TRUE)
rm(common_cty)

rm(list_common)

dfs <- objects()
df_co_all <- mget(dfs[grep("list_",dfs)])

list_all_co <- df_co_all

list_all_co[order(names(list_all_co))]

names(list_all_co) <- c('Demographic and housing estimates, population by age', 
                        'Debt in America, county-level automobile debt',
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
                        'Debt in America, county-level medical debt',
                        'Median earnings in the past 12 months (categorized)', 
                        'Median earnings in the past 12 months by race (in dollars)', 
                        'Debt in America, county-level debt overview',
                        'Poverty status in the past 12 months, by race', 
                        'Demographic and housing estimates, population by race', 
                        'Gross rent as a percentage of household income', 
                        'Demographic and housing estimates, population by sex', 
                        'Households enrolled in SNAP, by race',
                        'Debt in America, county-level automobile debt')




