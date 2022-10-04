source("https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-functions/metro-packages.R")
gc()

# Read in directory information from IPEDS Data Center ---------------------------------------------------------

html.ipeds <- readLines('https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx?year=-1')
html.ipeds <- gsub("\"", "", html.ipeds)
html.ipeds <- gsub("\\&", "", html.ipeds)
html.ipeds <- gsub("\\=", "", html.ipeds)
html.ipeds <- gsub("\\?", "", html.ipeds)
html.ipeds <- gsub("\\;", "", html.ipeds)
html.ipeds <- gsub("<", "", html.ipeds)
html.ipeds <- gsub(">", "", html.ipeds)
html.ipeds <- data.frame(html.ipeds)
html.ipeds <- data.frame(html.ipeds[html.ipeds$html.ipeds %like% "Institutional Characteristics", ])
names(html.ipeds) <- c("html.ipeds")
html.ipeds <- data.frame(html.ipeds[html.ipeds$html.ipeds %like% "Directory information", ])
names(html.ipeds) <- c("html.ipeds")
html.ipeds <- data.frame(html.ipeds[!grepl("Directory information, ", html.ipeds$html.ipeds),])
names(html.ipeds) <- c("html.ipeds")

recent <- head(html.ipeds$html.ipeds, 1)
position <- str_locate_all(pattern = "HD20", recent)
position <- unlist(position)
zip <- substring(recent, position[1])
position <- str_locate_all(pattern = "HD20", zip)
position <- unlist(position)
position <- position[2] - 1
zip <- substring(zip, 1, position)
file <- gsub(".zip","",zip)
file <- paste(file, ".csv", sep = "")
link <- paste("https://nces.ed.gov/ipeds/datacenter/data/", zip, sep = "")

download.file(link, zip, quiet = TRUE, mode = "wb")
unzip(zip)
ipeds <- fread(file)

file.remove(file)
file.remove(zip)
rm(html.ipeds)
rm(recent)
rm(zip)
rm(file)
rm(link)
rm(position)
gc()

directory <- ipeds
rm(ipeds)

source("https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-functions/metro-packages.R")
gc()

# Read in enrollment information from IPEDS Data Center ---------------------------------------------------------

html.ipeds <- readLines('https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx?year=-1')
html.ipeds <- gsub("\"", "", html.ipeds)
html.ipeds <- gsub("\\&", "", html.ipeds)
html.ipeds <- gsub("\\=", "", html.ipeds)
html.ipeds <- gsub("\\?", "", html.ipeds)
html.ipeds <- gsub("\\;", "", html.ipeds)
html.ipeds <- gsub("<", "", html.ipeds)
html.ipeds <- gsub(">", "", html.ipeds)
html.ipeds <- data.frame(html.ipeds)
html.ipeds <- data.frame(html.ipeds[html.ipeds$html.ipeds %like% "12-Month Enrollment", ])
names(html.ipeds) <- c("html.ipeds")
html.ipeds <- data.frame(html.ipeds[html.ipeds$html.ipeds %like% "12-month instructional activity", ])
names(html.ipeds) <- c("html.ipeds")
html.ipeds <- data.frame(html.ipeds[html.ipeds$html.ipeds %like% "EFIA", ])
names(html.ipeds) <- c("html.ipeds")

recent <- head(html.ipeds$html.ipeds, 1)
position <- str_locate_all(pattern = "EFIA", recent)
position <- unlist(position)
zip <- substring(recent, position[1])
position <- str_locate_all(pattern = "EFIA", zip)
position <- unlist(position)
position <- position[2] - 1
zip <- substring(zip, 1, position)
file <- gsub(".zip","",zip)
file <- paste(file, ".csv", sep = "")
link <- paste("https://nces.ed.gov/ipeds/datacenter/data/", zip, sep = "")

download.file(link, zip, quiet = TRUE, mode = "wb")
unzip(zip)
ipeds <- fread(file)

file.remove(file)
file.remove(zip)
rm(html.ipeds)
rm(recent)
rm(zip)
rm(file)
rm(link)
rm(position)
gc()

enrollment <- ipeds
rm(ipeds)

# Clean and merge IPEDS data ---------------------------------------------------------

directory <- subset(directory, select = c("UNITID", "ZIP", "COUNTYCD"))
enrollment <- subset(enrollment, select = c("UNITID", "FTEUG", "FTEGD", "FTEDPP"))

common_col_names <- intersect(names(directory), names(enrollment))
ipeds <- merge(directory, enrollment, by = common_col_names, all = TRUE)
rm(common_col_names)
rm(directory)
rm(enrollment)

ipeds[is.na(ipeds)] = 0

ipeds$TOTAL <- NA

ipeds <- ipeds %>% relocate(UNITID)
ipeds <- ipeds %>% relocate(COUNTYCD, .after = UNITID)
ipeds <- ipeds %>% relocate(ZIP, .after = COUNTYCD)
ipeds <- ipeds %>% relocate(FTEUG, .after = ZIP)
ipeds <- ipeds %>% relocate(FTEGD, .after = FTEUG)
ipeds <- ipeds %>% relocate(FTEDPP, .after = FTEGD)
ipeds <- ipeds %>% relocate(TOTAL, .after = FTEDPP)

ipeds$FTEUG <- as.numeric(ipeds$FTEUG)
ipeds$FTEGD <- as.numeric(ipeds$FTEGD)
ipeds$FTEDPP <- as.numeric(ipeds$FTEDPP)
ipeds$TOTAL <- as.numeric(ipeds$TOTAL)

ipeds$TOTAL <- rowSums(ipeds[, c(4,5,6)], na.rm = TRUE)
ipeds <- filter(ipeds, TOTAL > 0)

ipeds$ZIP <- substring(ipeds$ZIP, 1, 5)

ipeds$COUNTYCD <- replace(ipeds$COUNTYCD, which(ipeds$COUNTYCD < 0), NA)
ipeds <-  ipeds[!(is.na(ipeds$COUNTYCD) | ipeds$COUNTYCD ==""), ]

# Aggregate to county ---------------------------------------------------------

ipeds <- subset(ipeds, select = -c(ZIP))

ipeds <- ipeds %>% group_by(COUNTYCD) %>% summarize(FTEUG = sum(FTEUG),
                                                    FTEGD = sum(FTEGD),
                                                    FTEDPP = sum(FTEDPP),
                                                    TOTAL = sum(TOTAL))

ipeds$COUNTYCD <- as.character(ipeds$COUNTYCD)
for(i in 1:length(ipeds$COUNTYCD)) {
  if(as.numeric(ipeds$COUNTYCD[i]) < 10000) {
    ipeds$COUNTYCD[i] <- paste0("0", ipeds$COUNTYCD[i])
  }
}
rm(i)
