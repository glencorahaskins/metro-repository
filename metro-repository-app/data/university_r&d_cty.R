source("https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-functions/metro-packages.R")
gc()

ipeds <- "https://nces.ed.gov/ipeds/datacenter/data/HD2021.zip"
download.file(ipeds, "HD2021.zip", quiet = TRUE, mode = "wb")
unzip("HD2021.zip")
ipeds <- fread('HD2021.csv')

liasonedu.url <- "https://help.liaisonedu.com/WebAdMIT_Help_Center/Documents_and_Reference_Guides/Data_Dictionaries_and_Master_Code_Lists?mt-view=f1#Master_College_Code_List"
read_html(liasonedu.url) |>
  html_elements("p") |>
  html_elements("a") |>
  html_attr("href") |>
  (\(x) grep("\\.xlsx", x, value = TRUE))() |>
  (\(x) sprintf("https://help.liaisonedu.com%s", x))() -> liasonedu.html
mccl.url <- grep("Master_College_Code_List", liasonedu.html, value= TRUE)
mccl.url <- str_replace(mccl.url,"https://help.liaisonedu.comhttps://help.liaisonedu.com", "https://help.liaisonedu.com")
download.file(mccl.url, "Master_College_Code_List.xlsx", quiet = TRUE, mode = "wb")
mccl <- read_excel("Master_College_Code_List.xlsx")

herd2020 <- "https://www.nsf.gov/statistics/herd/data/csv/herd_2020.csv.zip"
download.file(herd2020, "herd_2020.csv.zip", quiet = TRUE, mode = "wb")
unzip("herd_2020.csv.zip")
herd2020 <- fread('herd_2020.csv')

sserf2019 <- "https://www.nsf.gov/statistics/srvyfacilities/data/facilities_2019_imputed.csv.zip"
download.file(sserf2019, "facilities_2019_imputed.csv.zip", quiet = TRUE, mode = "wb")
unzip("facilities_2019_imputed.csv.zip")
sserf2019 <- fread('facilities_2019_imputed.csv')

ncses <- "https://ncsesdata.nsf.gov/profiles/site?method=downloadRankings&src=HERD&s=&o="
download.file(ncses, "ncses.xlsx", quiet = TRUE, mode = "wb")
ncses <- read_excel("ncses.xlsx")

st <- which(ncses[1] == "Institution")
st <- gsub('L', '', st)
st <- as.numeric(st)

ncses <- read_excel("ncses.xlsx", skip = st)
ncses <- ncses[complete.cases(ncses[,c("Institution")]),]
ncses <- ncses[complete.cases(ncses[,2]),]
ncses <- ncses[ncses$Institution != "Total R&D expenditures", ]

yrs <- ncses %>% select(ends_with(c(".0", "Institution")))
yrs <- yrs %>% relocate(Institution) 

oldw <- getOption("warn")
options(warn = -1)
yrs <- yrs %>% rename_at(.vars = vars(ends_with(".0")),
                         .funs = funs(sub("[.]0$","",.)))
options(warn = oldw)
rm(oldw)

ncses <- ncses %>% relocate(Institution, .after = last_col())
ncses$blank <- NA
ncses <- ncses %>% relocate(blank)

data_names <- names(ncses[seq_len(ncol(ncses)) %% 4 == 0])
data_names <- append(data_names, "Institution")

ncses <- ncses[data_names]
ncses <- ncses %>% relocate(Institution)
names(ncses) <- names(yrs)

file.remove("HD2021.csv")
file.remove("HD2021.zip")
file.remove("Master_College_Code_List.xlsx")
rm(liasonedu.html)
rm(liasonedu.url)
rm(mccl.url)
file.remove("herd_2020.csv")
file.remove("herd_2020.csv.zip")
file.remove("facilities_2019_imputed.csv")
file.remove("facilities_2019_imputed.csv.zip")
file.remove("ncses.xlsx")
rm(data_names)
rm(st)
rm(yrs)
gc()


ncses$Institution <- gsub("\\[|\\]", "", ncses$Institution)
ncses$Institution <- gsub("0", "", ncses$Institution)
ncses$Institution <- gsub("1", "", ncses$Institution)
ncses$Institution <- gsub("2", "", ncses$Institution)
ncses$Institution <- gsub("3", "", ncses$Institution)
ncses$Institution <- gsub("4", "", ncses$Institution)
ncses$Institution <- gsub("5", "", ncses$Institution)
ncses$Institution <- gsub("6", "", ncses$Institution)
ncses$Institution <- gsub("7", "", ncses$Institution)
ncses$Institution <- gsub("8", "", ncses$Institution)
ncses$Institution <- gsub("9", "", ncses$Institution)
ncses$Institution <- trimws(ncses$Institution)










