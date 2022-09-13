library(sp)
library(maps)
library(maptools)
library(ggmap)
library(tidygeocoder)
library(dplyr)
library(sf)
library(jsonlite)
library(httr)
library(curl)

inst_url <- "https://ed-public-download.app.cloud.gov/downloads/Most-Recent-Cohorts-Institution_04262022.zip"
download.file(inst_url, "college_scorecard.zip")
unzip("college_scorecard.zip")
college_scorecard <- read.csv("Most-Recent-Cohorts-Institution.csv")
file.remove("college_scorecard.zip")
file.remove("Most-Recent-Cohorts-Institution.csv")
rm(inst_url)

college_scorecard$LONGITUDE <- as.numeric(as.character(college_scorecard$LONGITUDE))
college_scorecard$LATITUDE <- as.numeric(as.character(college_scorecard$LATITUDE))

college_scorecard <- college_scorecard[ , c("UNITID", "OPEID", "OPEID6", "INSTNM", "CITY", "STABBR", "ZIP", "MAIN", "NUMBRANCH", "ST_FIPS", "REGION", "LOCALE", "LOCALE2", "LATITUDE", "LONGITUDE")]
pointsDF <- college_scorecard[ , c("UNITID", "OPEID", "LONGITUDE", "LATITUDE")]

geo2fips <- function(latitude, longitude) {
  url <- "https://geo.fcc.gov/api/census/block/find?format=json&latitude=%f&longitude=%f"
  url <- sprintf(url, latitude, longitude)
  json <- curl(url)
  json <- fromJSON(json)
  as.character(json$County['FIPS'])
}

college_scorecard$stco_code <- mapply(geo2fips, college_scorecard$LATITUDE, college_scorecard$LONGITUDE)



