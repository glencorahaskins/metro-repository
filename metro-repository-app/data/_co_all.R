setwd("C:/Users/ghask/The Brookings Institution/Metro Research - JParilla/Glencora/GitHub/metro-repository/metro-repository-app")

source("https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-functions/metro-packages.R")

credit_cty <- "https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-repository-app/data/credit_cty.R"
socialcapital_cty <- "https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-repository-app/data/socialcapital_cty.R"
jobloss_cty <- "https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-repository-app/data/jobloss_cty.R"
mealgap_cty <- "https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-repository-app/data/mealgap_cty.R"

source_url(credit_cty)
source_url(socialcapital_cty)
source_url(jobloss_cty)
source_url(mealgap_cty)

rm(credit_cty)
rm(socialcapital_cty)
rm(jobloss_cty)
rm(mealgap_cty)

dfs <- objects()
df_co_all <- mget(dfs[grep("list_",dfs)])

list_all_co <- df_co_all
rm(df_co_all)
rm(dfs)

list_all_co[order(names(list_all_co))]
names(list_all_co) <- c("Debt in America, share with alternative forms of credit (AFS)",
                        "Debt in America, delinquency on alternative forms of credit (AFS)",
                        "Debt in America, delinquency on auto/retail loans",
                        "Debt in America, delinquency on credit cards",
                        "Debt in America, credit card utilization",
                        "Debt in America, debt in collections",
                        "Debt in America, median credit score",
                        "Debt in America, share with subprime credit score",
                        "Debt in America, delinquency on mortage loans",
                        "Debt in America, delinquency on student loans", 
                        "Low income jobs lost due to COVID-19",
                        "Gap between meal costs and benefits provided by Supplemental Nutrition Assistance Program (SNAP)",
                        "Social capital atlas, childhood social capital",
                        "Social capital atlas, overall economic connectedness",
                        "Social capital atlas, friending bias",
                        "Social capital atlas, mutual friendships",
                        "Social capital atlas, volunteerism and civic participation",
                        "Social capital atlas, exposure to individuals across socioeconomic status")

co_all <- credit

common_col_names <- intersect(names(co_all), names(credit))
co_all <- merge(co_all, credit, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(co_all), names(socialcapital))
co_all <- merge(co_all, socialcapital, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(co_all), names(jobloss))
co_all <- merge(co_all, jobloss, by = common_col_names, all.x = TRUE)
rm(common_col_names)

common_col_names <- intersect(names(co_all), names(mealgap))
co_all <- merge(co_all, mealgap, by = common_col_names, all.x = TRUE)
rm(common_col_names)