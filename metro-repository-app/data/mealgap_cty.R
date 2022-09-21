# Urban Institute Data Catalog, SNAP Meal Gap 2020

source("https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-functions/metro-packages.R")

mealgap.url <- "https://ui-spark-social-science-public.s3.amazonaws.com/data/SNAP+Meal+Gap+-+2020+data.csv"
download.file(mealgap.url, "SNAP+Meal+Gap+-+2020+data.csv", quiet = TRUE, mode = "wb")
mealgap <- read.csv("SNAP+Meal+Gap+-+2020+data.csv")
file.remove("SNAP+Meal+Gap+-+2020+data.csv")
rm(mealgap.url)

names(mealgap)[names(mealgap) == 'ï..fips'] <- 'county_fips'

mealgap$county_fips <- as.character(mealgap$county_fips)
for(i in 1:length(mealgap$county_fips)) {
  if(as.numeric(mealgap$county_fips[i]) < 10000) {
    mealgap$county_fips[i] <- paste0("0", mealgap$county_fips[i])
  }
}
rm(i)

remove <- names(mealgap) %in% c("state", "countystate", "snap_cost_plus15_s", "cost_gt_tfp_plus_25_percent", "totalpopulation1519acs")
mealgap <- mealgap[!remove]
rm(remove)

names(mealgap)[names(mealgap) == 'county_fips'] <- 'stco_code'
names(mealgap)[names(mealgap) == 'costpermeal_s'] <- 'Average localized estimated cost of food secure persons meal'
names(mealgap)[names(mealgap) == 'adjusted_costpermeal_s'] <- 'Average localized estimated cost of meal for low-income and food secure persons'
names(mealgap)[names(mealgap) == 'gap_cpm_snap_s'] <- 'Difference between adjusted average cost per meal and SNAP maximum cost per meal'
names(mealgap)[names(mealgap) == 'percent_gap_cpm_snap_s'] <- 'Percent difference between adjusted average cost per meal and SNAP maximum cost per meal'
names(mealgap)[names(mealgap) == 'cost_gt_tfp'] <- 'Indicator of gap between adjusted average cost per meal and SNAP maximum per meal cost, +15%'
names(mealgap)[names(mealgap) == 'gap_cpm_snap_plus15_s'] <- 'Difference between adjusted average cost per meal and SNAP maximum per meal cost with +15%'
names(mealgap)[names(mealgap) == 'percent_gap_cpm_snap_plus15_s'] <- 'Percent difference between adjusted average cost per meal and SNAP maximum per meal cost with +15%'
names(mealgap)[names(mealgap) == 'cost_gt_tfp_plus_15_percent'] <- 'Indicator of gap between adjusted average cost per meal and SNAP maximum per meal cost, +15%'
names(mealgap)[names(mealgap) == 'totalpopulation1519acs'] <- 'Total population, ACS 2019'
names(mealgap)[names(mealgap) == 'snap_costpermeal_s'] <- 'SNAP cost per meal'

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

common_col_names <- intersect(names(mealgap), names(fips_codes))
mealgap <- merge(mealgap, fips_codes, by = common_col_names, all.x = TRUE)
rm(common_col_names)

rm(fips_codes)

mealgap <- mealgap %>% relocate(stco_name, .after = stco_code)

# ------------------------------------------------------------------

list_mealgap <- names(mealgap)
