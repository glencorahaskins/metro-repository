source("https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-functions/metro-packages.R")

apred.url <- "https://www.statsamerica.org/downloads/APRED.zip"
download.file(apred.url, "apred.zip", quiet = TRUE, mode = "wb")
unzip("apred.zip")
business <- read.csv("APRED - Business Sector Vulnerability.csv")
file.remove("APRED - Disaster Resilience - Counties.csv")
file.remove("APRED - Business Sector Vulnerability.csv")
file.remove("APRED - NOAA Storm History - Counties.csv")
file.remove("APRED - FEMA Disaster Declarations - Counties.csv")
file.remove("APRED - Metadata.csv")
file.remove("apred.zip")
rm(apred.url)


business <- business %>% 
  filter(grepl(max(business$Year), Year))

names(business)

business <- subset(business, select = -c(NAICS.Code, NAICS.Description, Vulnerable.Establishments.Percent, Vulnerable.Employment.Percent))

business$Statefips <- as.character(business$Statefips)
for(i in 1:length(business$Statefips)) {
  if(as.numeric(business$Statefips[i]) < 10) {
    business$Statefips[i] <- paste0("0", business$Statefips[i])
  }
}
rm(i)

business$Countyfips <- as.character(business$Countyfips)
for(i in 1:length(business$Countyfips)) {
  if(as.numeric(business$Countyfips[i]) < 100) {
    business$Countyfips[i] <- paste0("0", business$Countyfips[i])
  }
}
rm(i)

business$Countyfips <- as.character(business$Countyfips)
for(i in 1:length(business$Countyfips)) {
  if(as.numeric(business$Countyfips[i]) < 10) {
    business$Countyfips[i] <- paste0("0", business$Countyfips[i])
  }
}
rm(i)


business$stco_code <- paste(business$Statefips, business$Countyfips, sep = "")

business <- business %>% group_by(stco_code) %>% summarize(Total.Establishments = sum(Total.Establishments),
                                                           Vulnerable.Establishments.Total = sum(Vulnerable.Establishments.Total),
                                                           Total.Employment = sum(Total.Employment),
                                                           Vulnerable.Employment.Total = sum(Vulnerable.Employment.Total))

names(business)[names(business) == 'Total.Establishments'] <- 'Total establishments'
names(business)[names(business) == 'Vulnerable.Establishments.Total'] <- 'Total vulnerable establishments'
names(business)[names(business) == 'Total.Employment'] <- 'Total jobs'
names(business)[names(business) == 'Vulnerable.Employment.Total'] <- 'Total vulnerable jobs'

list_statsamerica_business <- names(business)




