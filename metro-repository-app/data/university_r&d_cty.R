source("https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-functions/metro-packages.R")


herd2020 <- "https://www.nsf.gov/statistics/herd/data/csv/herd_2020.csv.zip"
download.file(herd2020, "herd_2020.csv.zip", quiet = TRUE, mode = "wb")
unzip("herd_2020.csv.zip")
herd2020 <- fread('herd_2020.csv')
file.remove("herd_2020.csv")
file.remove("herd_2020.csv.zip")
gc()

herd2020 <- herd2020[herd2020$question == 'Source', ]
herd2020 <- herd2020[herd2020$row == 'Total', ]

herd2020 <- herd2020[!apply(is.na(herd2020) | herd2020 == '', 1, all),]

ipeds <- "https://nces.ed.gov/ipeds/datacenter/data/HD2021.zip"
download.file(ipeds, "HD2021.zip", quiet = TRUE, mode = "wb")
unzip("HD2021.zip")
ipeds <- fread('HD2021.csv')
file.remove("HD2021.csv")
file.remove("HD2021.zip")
gc()

sserf2019 <- "https://www.nsf.gov/statistics/srvyfacilities/data/facilities_2019_imputed.csv.zip"
download.file(sserf2019, "facilities_2019_imputed.csv.zip", quiet = TRUE, mode = "wb")
unzip("facilities_2019_imputed.csv.zip")
sserf2019 <- fread('facilities_2019_imputed.csv')
file.remove("facilities_2019_imputed.csv")
file.remove("facilities_2019_imputed.csv.zip")
gc()

ipeds <- select(ipeds, c("UNITID", "INSTNM", "IALIAS", "ADDR", "CITY", "STABBR", "ZIP", "FIPS", "EIN", "OPEID", "HBCU", "CBSA", "CBSATYPE", "CSA","NECTA","COUNTYCD", "COUNTYNM", "CNGDSTCD", "LONGITUD", "LATITUDE"))
herd2020 <- select(herd2020, c("inst_id", "ncses_inst_id", "ipeds_unitid", "inst_name_long", "inst_city", "inst_state_code", "inst_zip", "data"))

names(herd2020)

ipeds$COUNTYCD <- as.character(ipeds$COUNTYCD)
for(i in 1:length(ipeds$COUNTYCD)) {
  if(as.numeric(ipeds$COUNTYCD[i]) < 10000) {
    ipeds$COUNTYCD[i] <- paste0("0", ipeds$COUNTYCD[i])
  }
}
rm(i)

herd2020$inst_zip <- substr(herd2020$inst_zip,1,5)

names(sserf2019)[names(sserf2019) == 'INST_ID'] <- 'SSERF_ID'
names(sserf2019)[names(sserf2019) == 'FICE'] <- 'INST_ID'

sserf2019 = subset(sserf2019, select = -c(YEAR, SUBMISSION_FLAG, INST_TYPE, HDG_CODE, TOC_CODE, HBCU_FLAG, AAMC_FLAG, MED_SCHOOL_FLAG, EPSCOR_FLAG, IDEA_FLAG) )

sserf2019 <- sserf2019[ , 1:6]






