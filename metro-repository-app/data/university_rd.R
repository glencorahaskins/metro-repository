source("https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-functions/metro-packages.R")
gc()

# Import and clean rankings file from NCSES ---------------------------------------------------------

ncses <- "https://ncsesdata.nsf.gov/profiles/site?method=downloadRankings&src=HERD&s=&o="
download.file(ncses, "ncses.xlsx", quiet = TRUE, mode = "wb")
ncses <- read_excel("ncses.xlsx")

st <- which(ncses[1] == "Institution")
st <- gsub('L', '', st)
st <- as.numeric(st)

ncses <- read_excel("ncses.xlsx", skip = st)
file.remove("ncses.xlsx")
rm(st)

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

rm(yrs)
rm(data_names)

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

ncses[-1] <- lapply(ncses[-1], as.numeric)

# Read in html.ncses source code from NCSES rankings page ---------------------------------------------------------

html.ncses <- readLines('https://ncsesdata.nsf.gov/profiles/site?method=rankingbysource&ds=herd')
html.ncses <- gsub("\"", "", html.ncses)
html.ncses <- gsub("\\&", "", html.ncses)
html.ncses <- gsub("\\=", "", html.ncses)
html.ncses <- gsub("\\?", "", html.ncses)
html.ncses <- gsub("\\;", "", html.ncses)
html.ncses <- gsub("\\<", "", html.ncses)
html.ncses <- data.frame(html.ncses)
html.ncses <- data.frame(html.ncses[html.ncses$html.ncses %like% " <a hrefsitemethodviewamptin", ])
names(html.ncses) <- c("html.ncses")
html.ncses$html.ncses <- gsub("^.{0,37}", "", html.ncses$html.ncses)
html.ncses$univ_id <- substr(html.ncses$html.ncses,1,8)
html.ncses$html.ncses <- gsub("^.{0,14}", "", html.ncses$html.ncses)
html.ncses$univ_name <- gsub(">.*$", "", html.ncses$html.ncses)
html.ncses$univ_name <- trimws(html.ncses$univ_name)
html.ncses <- subset(html.ncses, select = -c(html.ncses))

html.ncses$univ_name <- gsub(" amp ", " & ", html.ncses$univ_name)
html.ncses$univ_name <- gsub(" AampM ", " A&M ", html.ncses$univ_name)
html.ncses$univ_name <- gsub("#039s", "'", html.ncses$univ_name)
html.ncses$univ_name <- gsub("#039", "'", html.ncses$univ_name)
html.ncses$univ_name <- gsub("' U", "'s U", html.ncses$univ_name)
html.ncses$univ_name <- gsub("' C", "'s C", html.ncses$univ_name)

names(html.ncses)[names(html.ncses) == 'univ_name'] <- 'Institution'

common_col_names <- intersect(names(ncses), names(html.ncses))
ncses <- merge(ncses, html.ncses, by = common_col_names, all = TRUE)
rm(common_col_names)
ncses <- ncses %>% relocate(univ_id)
rm(html.ncses)

names(ncses)[names(ncses) == 'univ_id'] <- 'ncses_inst_id'
names(ncses)[names(ncses) == 'Institution'] <- 'inst_name_short'

# Import and clean rankings file from HERD public use files ---------------------------------------------------------

oldw <- getOption("warn")
options(warn = -1)
html.herd <- readLines('https://www.nsf.gov/statistics/herd/pub_data.cfm')
options(warn = oldw)
rm(oldw)

html.herd <- gsub("\"", "", html.herd)
html.herd <- gsub("\\&", "", html.herd)
html.herd <- gsub("\\=", "", html.herd)
html.herd <- gsub("\\?", "", html.herd)
html.herd <- gsub("\\;", "", html.herd)
html.herd <- gsub("\\<", "", html.herd)
html.herd <- data.frame(html.herd)

html.herd <- data.frame(html.herd[html.herd$html.herd %like% "data/csv/herd_", ])
names(html.herd) <- c("html")
html.herd <- html.herd %>% filter(!str_detect(html, 'short'))
html.herd$html <- gsub(">", "", html.herd$html)
html.herd$html <- gsub("<a hrefdata/csv/", "", html.herd$html)

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
  
recent <- head(html.herd$html, 1)
zip <- substrRight(recent, 17)
file <- gsub(".zip","",zip)
link <- paste("https://www.nsf.gov/statistics/herd/data/csv/", zip, sep = "")

download.file(link, zip, quiet = TRUE, mode = "wb")
unzip(zip)
herd <- fread(file)

file.remove(file)
file.remove(zip)
rm(html.herd)
rm(substrRight)
rm(recent)
rm(zip)
rm(file)
rm(link)

names_herd <- c("inst_id", "ncses_inst_id", "ipeds_unitid", "inst_name_long", "inst_zip")
herd <- subset(herd, select = names_herd)
rm(names_herd)

herd <- herd[!duplicated(herd), ]
herd$ipeds_unitid <- as.numeric(herd$ipeds_unitid)

herd$inst_zip <- substr(herd$inst_zip,1,5)

# Merge HERD data into NCSES ---------------------------------------------------------

common_col_names <- intersect(names(ncses), names(herd))
ncses <- merge(ncses, herd, by = common_col_names, all = TRUE)
rm(common_col_names)

ncses <- ncses %>% relocate(inst_id)
ncses <- ncses %>% relocate(ipeds_unitid, .after = ncses_inst_id)

rm(herd)
ncses <- ncses[!(is.na(ncses$ncses_inst_id) | ncses$ncses_inst_id==""), ]
gc()

# Recode NCSES Institution ID into IPEDS Unit ID ---------------------------------------------------------

ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0047001')] <- 100654
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3249001')] <- 100663
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3250001')] <- 100706
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0049001')] <- 100724
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3248002')] <- 100751
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0323004')] <- 100830
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0323002')] <- 100858
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1533001')] <- 101480
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3453001')] <- 101587
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3365001')] <- 101879
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2370001')] <- 101912
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3414001')] <- 102094
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3189001')] <- 102368
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3203001')] <- 102377
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3251001')] <- 102553
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3252001')] <- 102614
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3253001')] <- 102632
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0061001')] <- 102669
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3147001')] <- 103778
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0258001')] <- 104151
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3256001')] <- 104179
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0934001')] <- 105297
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2321001')] <- 105330
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2559001')] <- 105589
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3260001')] <- 106245
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3262001')] <- 106263
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1754001')] <- 106342
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3257001')] <- 106397
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3258001')] <- 106412
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0263004')] <- 106458
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0264001')] <- 106467
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3261001')] <- 106485
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3268001')] <- 106704
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1288001')] <- 107044
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1338001')] <- 107080
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1550001')] <- 107141
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2434001')] <- 107512
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2510001')] <- 107600
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2918001')] <- 107983
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'O0268005')] <- 109651
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0342001')] <- 109785
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0422001')] <- 110097
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266007')] <- 110398
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0508001')] <- 110404
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0510001')] <- 110413
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0513001')] <- 110422
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0089001')] <- 110468
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516001')] <- 110486
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516015')] <- 110495
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516013')] <- 110510
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0515001')] <- 110529
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516003')] <- 110538
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516004')] <- 110547
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516006')] <- 110556
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516007')] <- 110565
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516005')] <- 110574
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516008')] <- 110583
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516009')] <- 110592
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516011')] <- 110608
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516012')] <- 110617
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266001')] <- 110635
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266004')] <- 110644
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266008')] <- 110653
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266011')] <- 110662
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266015')] <- 110671
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266016')] <- 110680
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266019')] <- 110699
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266020')] <- 110705
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266021')] <- 110714
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0511001')] <- 111188
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0625001')] <- 111948
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0626001')] <- 111966
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4728003')] <- 112251
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4728002')] <- 112260
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3633001')] <- 112525
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0943001')] <- 113698
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1089001')] <- 114549
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1163001')] <- 114840
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4728004')] <- 115409
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1392001')] <- 115755
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1624001')] <- 117627
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1708001')] <- 117636
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2922001')] <- 117672
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1735001')] <- 117946
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1930001')] <- 118888
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2030001')] <- 119173
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2178001')] <- 119605
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2196001')] <- 119678
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2372001')] <- 120254
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2462001')] <- 120698
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3478001')] <- 120883
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2499001')] <- 121150
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4728007')] <- 121257
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2533001')] <- 121309
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4728006')] <- 121345
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3401001')] <- 121691
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2738001')] <- 122409
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3409001')] <- 122436
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2740001')] <- 122597
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3410001')] <- 122612
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2744001')] <- 122755
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2754001')] <- 122931
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4728008')] <- 123165
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2884001')] <- 123572
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3501001')] <- 123651
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2920001')] <- 123943
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3422001')] <- 123961
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0695001')] <- 124283
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3267001')] <- 124557
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3639001')] <- 125727
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3650001')] <- 125763
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3271000')] <- 126562
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3277001')] <- 126580
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3276001')] <- 126614
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0773001')] <- 126678
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0776001')] <- 126775
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0777004')] <- 126818
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3285001')] <- 127060
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1126001')] <- 127185
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1877005')] <- 127556
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1888001')] <- 127565
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3377001')] <- 127741
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2617001')] <- 127918
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0777003')] <- 128106
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3219001')] <- 128328
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3629001')] <- 128391
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3265001')] <- 128744
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0597001')] <- 128771
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0824001')] <- 128902
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3280001')] <- 129020
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0975001')] <- 129215
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1064001')] <- 129242
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B2042001')] <- 129491
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3295001')] <- 129525
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3363001')] <- 129941
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2594001')] <- 130226
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2689001')] <- 130253
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2924001')] <- 130493
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3181002')] <- 130590
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3221001')] <- 130624
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3588001')] <- 130697
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3613001')] <- 130776
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3715001')] <- 130794
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0914001')] <- 130934
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3284001')] <- 130943
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0219001')] <- 131159
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0562001')] <- 131283
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3475001')] <- 131399
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1170001')] <- 131450
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1194001')] <- 131469
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1197001')] <- 131496
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1382001')] <- 131520
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0366001')] <- 132471
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0413001')] <- 132602
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3269001')] <- 132903
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0992001')] <- 133492
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0999001')] <- 133508
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1023001')] <- 133553
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1099001')] <- 133650
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1102001')] <- 133669
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1107001')] <- 133881
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1108001')] <- 133951
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1113001')] <- 134097
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3290001')] <- 134130
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1534001')] <- 134945
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B2497002')] <- 135081
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3344001')] <- 135726
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3375001')] <- 136172
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2362001')] <- 136215
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2668001')] <- 136950
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3418001')] <- 137351
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3020001')] <- 137476
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3062001')] <- 137546
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3429001')] <- 137847
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3454001')] <- 138354
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0040001')] <- 138600
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0066001')] <- 138716
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0265001')] <- 138789
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0699001')] <- 138947
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0408001')] <- 139144
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0707001')] <- 139311
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0789001')] <- 139366
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1030001')] <- 139658
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1128001')] <- 139719
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1201001')] <- 139755
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1198001')] <- 139861
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1203001')] <- 139931
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1205001')] <- 139940
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3292001')] <- 139959
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B2680001')] <- 140252
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1870001')] <- 140447
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2007001')] <- 140553
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2008001')] <- 140562
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2453001')] <- 140720
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2764001')] <- 140960
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2971001')] <- 141060
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2931001')] <- 141097
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3495001')] <- 141264
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3455001')] <- 141334
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3298001')] <- 141565
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3299001')] <- 141574
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1309001')] <- 141644
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3296002')] <- 141839
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3297001')] <- 141963
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3300001')] <- 141981
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0445001')] <- 142115
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1403001')] <- 142276
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3306001')] <- 142285
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1685001')] <- 142328
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2343001')] <- 142461
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0328001')] <- 143084
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0460001')] <- 143358
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1921001')] <- 143853
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0642001')] <- 143978
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0643001')] <- 144005
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3273001')] <- 144050
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0780003')] <- 144281
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0904001')] <- 144740
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0977001')] <- 144892
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1019001')] <- 144962
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1233001')] <- 145336
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2670001')] <- 145558
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3308001')] <- 145600
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0398001')] <- 145619
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1405001')] <- 145628
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3310001')] <- 145637
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1410001')] <- 145646
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1406001')] <- 145725
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1408001')] <- 145813
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1634001')] <- 146481
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1736001')] <- 146719
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2179001')] <- 147590
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2282001')] <- 147660
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2324001')] <- 147703
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2352001')] <- 147767
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2314001')] <- 147776
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2407001')] <- 147828
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2669001')] <- 148487
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0942001')] <- 148496
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2682001')] <- 148511
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3309001')] <- 148654
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2925001')] <- 149222
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2925002')] <- 149231
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3615001')] <- 149772
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3642002')] <- 149781
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0348001')] <- 150136
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0497001')] <- 150163
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0905001')] <- 150400
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0958001')] <- 150455
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3288001')] <- 150534
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1427001')] <- 151102
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1427002')] <- 151111
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3423001')] <- 151306
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1424001')] <- 151324
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1425006')] <- 151333
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1425011')] <- 151342
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1425002')] <- 151351
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1425005')] <- 151360
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1425007')] <- 151379
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1425008')] <- 151388
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1772001')] <- 151777
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1428001')] <- 151801
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3380001')] <- 152080
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2673001')] <- 152318
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3095003')] <- 152530
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3498001')] <- 152600
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3538001')] <- 152673
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0727001')] <- 153144
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0851001')] <- 153162
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0947001')] <- 153250
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0949001')] <- 153269
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1255001')] <- 153384
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1516001')] <- 153603
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3312001')] <- 153658
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1744001')] <- 153834
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1767001')] <- 153861
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3378001')] <- 154095
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0926001')] <- 154156
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2459002')] <- 154174
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2459003')] <- 154174
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1031001')] <- 155025
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1125001')] <- 155061
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1302001')] <- 155140
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3313001')] <- 155317
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1588001')] <- 155399
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2527001')] <- 155681
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3556001')] <- 156082
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3653001')] <- 156125
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0387001')] <- 156286
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0403001')] <- 156295
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0614001')] <- 156408
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0979001')] <- 156620
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1600001')] <- 157058
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3314001')] <- 157085
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3319001')] <- 157289
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2006001')] <- 157386
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2046001')] <- 157401
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2325001')] <- 157447
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3619001')] <- 157951
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0933001')] <- 158802
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1238001')] <- 159009
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1725006')] <- 159373
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1725003')] <- 159391
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1725008')] <- 159416
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1727001')] <- 159647
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1738001')] <- 159656
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1852001')] <- 159717
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1725010')] <- 159939
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2267001')] <- 159966
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3318001')] <- 159993
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2351001')] <- 160038
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2914001')] <- 160612
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'R2936005')] <- 160621
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2936002')] <- 160621
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2936003')] <- 160630
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3317001')] <- 160658
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3198001')] <- 160755
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3712001')] <- 160904
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0371001')] <- 160977
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0453001')] <- 161004
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0729001')] <- 161086
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3321001')] <- 161226
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3325001')] <- 161244
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3320001')] <- 161253
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1768001')] <- 161299
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3361001')] <- 161457
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3424001')] <- 161554
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3233001')] <- 161572
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3264001')] <- 161873
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0454001')] <- 162007
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0536001')] <- 162061
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0849001')] <- 162283
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1162001')] <- 162584
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1232001')] <- 162654
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1558001')] <- 162928
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1737001')] <- 163046
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3331001')] <- 163259
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3330001')] <- 163268
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3330004')] <- 163286
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4758001')] <- 163286
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1804001')] <- 163295
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3334001')] <- 163338
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2009001')] <- 163453
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2721001')] <- 163851
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3008001')] <- 163912
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2883001')] <- 163921
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3162001')] <- 164076
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B4592001')] <- 164085
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3209001')] <- 164137
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3227001')] <- 164155
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B2177001')] <- 164368
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0225001')] <- 164465
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0343001')] <- 164580
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0402001')] <- 164739
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0447001')] <- 164924
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0450001')] <- 164988
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0461001')] <- 165015
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0471001')] <- 165024
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0702001')] <- 165334
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1026001')] <- 165662
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1139001')] <- 165866
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B1927001')] <- 165936
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1281001')] <- 166018
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1300001')] <- 166027
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0765001')] <- 166124
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1656001')] <- 166391
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1680001')] <- 166452
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3340001')] <- 166513
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'R3700001')] <- 166610
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3336001')] <- 166629
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3337001')] <- 166638
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1821001')] <- 166656
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3338001')] <- 166665
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1824001')] <- 166683
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3341001')] <- 166708
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1875001')] <- 166850
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1755001')] <- 166869
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2020001')] <- 166939
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2220001')] <- 167093
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2225001')] <- 167181
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2320001')] <- 167358
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2830001')] <- 167783
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2844001')] <- 167835
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3339001')] <- 167987
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3067001')] <- 167996
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3074001')] <- 168005
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3197001')] <- 168148
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3582001')] <- 168218
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3623001')] <- 168254
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3642001')] <- 168281
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4733001')] <- 168342
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3702001')] <- 168421
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0069001')] <- 168546
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0231001')] <- 168740
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0520001')] <- 169080
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0602001')] <- 169248
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3286001')] <- 169716
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0981001')] <- 169798
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1086001')] <- 169910
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1604001')] <- 169983
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1241001')] <- 170082
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1367001')] <- 170301
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1582001')] <- 170532
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1638001')] <- 170639
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1662001')] <- 170675
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3345002')] <- 170976
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1901001')] <- 171100
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1903001')] <- 171128
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3345005')] <- 171137
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3345007')] <- 171146
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2327001')] <- 171456
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2368001')] <- 171571
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2694001')] <- 172051
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3574001')] <- 172644
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3620001')] <- 172699
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0326001')] <- 173045
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0394001')] <- 173124
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0543001')] <- 173258
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0807001')] <- 173300
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1269001')] <- 173647
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1278001')] <- 173665
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1758001')] <- 173902
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1946002')] <- 173920
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1889001')] <- 174020
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3346001')] <- 174066
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3346006')] <- 174066
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3346002')] <- 174075
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3346003')] <- 174233
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3346010')] <- 174251
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1946003')] <- 174358
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2348001')] <- 174507
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0750001')] <- 174747
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2985001')] <- 174783
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2699001')] <- 174792
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2710001')] <- 174817
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3015001')] <- 174844
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3428001')] <- 174914
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2983001')] <- 175005
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3681001')] <- 175272
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0071001')] <- 175342
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0919001')] <- 175616
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1532001')] <- 175856
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1931001')] <- 175980
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3347001')] <- 176017
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1960001')] <- 176035
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1961001')] <- 176044
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1954001')] <- 176053
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1958001')] <- 176080
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3425001')] <- 176372
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3158001')] <- 176406
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3667001')] <- 176479
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3270001')] <- 176965
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0363001')] <- 177719
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0002001')] <- 177834
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1692001')] <- 177940
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1706001')] <- 177986
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1973001')] <- 178387
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3348001')] <- 178396
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3348004')] <- 178402
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1970001')] <- 178411
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3348005')] <- 178420
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3192001')] <- 178615
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2342001')] <- 178624
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2706001')] <- 179159
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B4460001')] <- 179265
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2911001')] <- 179557
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1969001')] <- 179566
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1587001')] <- 179812
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3564001')] <- 179867
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1989002')] <- 180179
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1990001')] <- 180416
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1989003')] <- 180461
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3351001')] <- 180489
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1989005')] <- 180522
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2722001')] <- 180647
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3352001')] <- 180692
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0867001')] <- 181002
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0936001')] <- 181020
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3357001')] <- 181215
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3358001')] <- 181394
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3356001')] <- 181428
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2200001')] <- 181446
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3359001')] <- 181464
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2503001')] <- 181534
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3355001')] <- 181747
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0757001')] <- 182005
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3360001')] <- 182281
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3360004')] <- 182290
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0731001')] <- 182634
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0895001')] <- 182670
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3362001')] <- 183044
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1594001')] <- 183062
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2532001')] <- 183080
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0951001')] <- 184348
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1065001')] <- 184603
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2679001')] <- 184782
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2228001')] <- 185129
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1592001')] <- 185262
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1984001')] <- 185572
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1992001')] <- 185590
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2229001')] <- 185828
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2566001')] <- 186131
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2601001')] <- 186201
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2639002')] <- 186283
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2684002')] <- 186371
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2684004')] <- 186380
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2684006')] <- 186399
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2801001')] <- 186584
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3063001')] <- 186867
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3132001')] <- 186876
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0748001')] <- 187134
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3342001')] <- 187222
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3671001')] <- 187444
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0983001')] <- 187648
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2234001')] <- 187897
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2235001')] <- 187967
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3364001')] <- 187985
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2239001')] <- 188030
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2328001')] <- 188058
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3624001')] <- 188304
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0026001')] <- 188429
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0062001')] <- 188526
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0065001')] <- 188580
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0076001')] <- 188641
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0352001')] <- 189015
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0360001')] <- 189088
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0362001')] <- 189097
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0530001')] <- 189705
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S0686018')] <- 190035
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4736001')] <- 190035
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4738001')] <- 190035
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0705001')] <- 190044
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0735001')] <- 190099
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0785001')] <- 190150
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0847001')] <- 190372
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0852001')] <- 190415
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686001')] <- 190512
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686004')] <- 190549
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686005')] <- 190558
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686006')] <- 190567
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686020')] <- 190576
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686009')] <- 190594
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686010')] <- 190600
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686013')] <- 190637
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686014')] <- 190646
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686015')] <- 190655
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686016')] <- 190664
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0686019')] <- 190691
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0881001')] <- 190716
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0883001')] <- 190725
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0948001')] <- 190770
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3047001')] <- 191126
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1118001')] <- 191241
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1277001')] <- 191515
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1356001')] <- 191630
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1358001')] <- 191649
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1509001')] <- 191931
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1522001')] <- 191968
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1665001')] <- 192323
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1713001')] <- 192448
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1773001')] <- 192703
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1789001')] <- 192819
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B2941001')] <- 193016
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2029001')] <- 193405
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2242001')] <- 193654
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2247001')] <- 193751
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2251001')] <- 193821
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2252001')] <- 193830
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2257001')] <- 193900
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2266001')] <- 193973
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2250001')] <- 194091
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2438001')] <- 194310
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2621001')] <- 194824
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2655001')] <- 195003
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3405001')] <- 195030
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2657001')] <- 195049
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2693001')] <- 195128
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2981001')] <- 195164
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3001001')] <- 195216
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2761001')] <- 195304
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2824001')] <- 195474
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2841001')] <- 195526
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2994001')] <- 195809
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3027031')] <- 195827
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3052004')] <- 195827
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B4513001')] <- 196015
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B4513002')] <- 196024
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3039001')] <- 196033
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3046001')] <- 196042
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3040001')] <- 196051
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3052001')] <- 196060
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3027001')] <- 196079
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3054001')] <- 196088
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3056001')] <- 196097
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3041001')] <- 196103
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3049001')] <- 196112
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3029001')] <- 196121
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3030001')] <- 196130
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3031001')] <- 196149
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3032001')] <- 196158
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3033001')] <- 196167
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3055001')] <- 196176
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3035001')] <- 196185
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3036001')] <- 196194
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3038001')] <- 196200
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3051001')] <- 196219
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3042001')] <- 196228
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3034001')] <- 196237
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3037001')] <- 196246
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3048001')] <- 196255
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3050001')] <- 196291
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3053001')] <- 196307
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3084001')] <- 196413
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S0784001')] <- 196468
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3160001')] <- 196592
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3210003')] <- 196866
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3226001')] <- 197036
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3493001')] <- 197045
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3503001')] <- 197133
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3717001')] <- 197708
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0245001')] <- 197869
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0898001')] <- 198385
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0954001')] <- 198419
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0965001')] <- 198464
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1016001')] <- 198507
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1022001')] <- 198516
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1075001')] <- 198543
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1561001')] <- 198756
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2274001')] <- 199102
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3368001')] <- 199111
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3369001')] <- 199120
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3370001')] <- 199139
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3371001')] <- 199148
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2276001')] <- 199157
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3366001')] <- 199175
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2279001')] <- 199193
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3373001')] <- 199218
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3372001')] <- 199281
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2807001')] <- 199643
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3540001')] <- 199847
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3683001')] <- 199999
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3612001')] <- 200004
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0932001')] <- 200059
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1842001')] <- 200226
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1949001')] <- 200253
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3374001')] <- 200280
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2290001')] <- 200332
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2838001')] <- 200466
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3201001')] <- 200527
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3230001')] <- 200554
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3497001')] <- 200572
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0044001')] <- 200697
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3247001')] <- 200800
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0273001')] <- 201104
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0347001')] <- 201195
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0455001')] <- 201441
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0554001')] <- 201645
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0606001')] <- 201690
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3274001')] <- 201885
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0716001')] <- 202134
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3283001')] <- 202480
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0920001')] <- 202523
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1330001')] <- 203085
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1551001')] <- 203368
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1598001')] <- 203517
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1602001')] <- 203535
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1896001')] <- 204024
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2307001')] <- 204477
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2371001')] <- 204501
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2387001')] <- 204635
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2388001')] <- 204796
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2389001')] <- 204857
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2391001')] <- 204909
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3446001')] <- 206084
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3656001')] <- 206491
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3689001')] <- 206525
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0760001')] <- 206589
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3709001')] <- 206604
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3722001')] <- 206695
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3271001')] <- 206941
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0966001')] <- 207041
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1650001')] <- 207209
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2318001')] <- 207263
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S2401002')] <- 207315
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2401006')] <- 207388
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3381001')] <- 207500
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2915001')] <- 207847
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2960001')] <- 207865
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3447001')] <- 207971
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0985001')] <- 208646
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1682001')] <- 209056
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1695001')] <- 209065
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2105001')] <- 209296
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2418001')] <- 209490
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2419001')] <- 209506
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2425001')] <- 209542
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3382001')] <- 209551
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2452001')] <- 209612
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2552001')] <- 209807
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3387001')] <- 209825
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2611001')] <- 209922
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2930001')] <- 210146
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3665001')] <- 210401
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3626001')] <- 210429
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3456001')] <- 210438
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0488001')] <- 210492
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0080001')] <- 210669
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0251001')] <- 211088
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0437001')] <- 211158
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0489001')] <- 211273
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0491001')] <- 211291
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0517001')] <- 211361
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0548001')] <- 211440
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0639001')] <- 211608
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0698001')] <- 211644
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0931001')] <- 212009
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0952001')] <- 212054
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0955001')] <- 212106
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0970001')] <- 212115
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0997001')] <- 212160
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1018001')] <- 212197
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1143001')] <- 212577
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1173001')] <- 212601
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1209001')] <- 212674
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1307001')] <- 212911
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1426001')] <- 213020
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1574001')] <- 213251
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1618001')] <- 213349
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1623001')] <- 213367
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1629001')] <- 213385
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1676001')] <- 213543
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1693001')] <- 213598
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1749001')] <- 213668
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1815001')] <- 213826
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1873001')] <- 213987
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1879001')] <- 213996
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1927001')] <- 214041
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2005001')] <- 214157
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2041001')] <- 214175
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2726001')] <- 214564
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2498009')] <- 214591
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2498015')] <- 214607
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2498006')] <- 214670
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2498003')] <- 214689
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2498004')] <- 214698
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2498005')] <- 214704
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2498011')] <- 214713
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2498017')] <- 214731
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2498024')] <- 214777
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3383001')] <- 215062
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2509001')] <- 215099
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2506001')] <- 215123
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3479001')] <- 215132
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3386002')] <- 215266
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3386006')] <- 215293
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2697001')] <- 215743
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2703001')] <- 215770
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2704001')] <- 215770
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3412001')] <- 215929
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2819001')] <- 216010
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2843001')] <- 216038
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3079001')] <- 216278
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3080001')] <- 216287
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3099001')] <- 216339
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3139001')] <- 216366
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3488001')] <- 216524
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3518001')] <- 216597
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3557001')] <- 216667
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3590001')] <- 216764
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3654001')] <- 216852
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3663001')] <- 216931
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0485001')] <- 217156
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0487001')] <- 217165
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2573001')] <- 217402
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2634001')] <- 217420
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3402001')] <- 217484
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2636001')] <- 217493
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2665001')] <- 217518
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2727001')] <- 217536
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0396001')] <- 217721
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0739001')] <- 217819
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0682001')] <- 217864
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0692001')] <- 217873
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0710001')] <- 217882
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0728001')] <- 217907
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0843001')] <- 217961
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1140001')] <- 218061
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1166001')] <- 218070
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1860001')] <- 218335
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3415002')] <- 218645
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3415004')] <- 218654
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3415001')] <- 218663
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3415006')] <- 218663
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0723001')] <- 218724
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2892001')] <- 218733
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B4245001')] <- 218751
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3684001')] <- 218964
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0328002')] <- 219000
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0431001')] <- 219046
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0885001')] <- 219082
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0886001')] <- 219091
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2329001')] <- 219259
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2382001')] <- 219277
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2894001')] <- 219347
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2895001')] <- 219356
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2835001')] <- 219374
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3413001')] <- 219383
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3416001')] <- 219471
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0333001')] <- 219602
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0674001')] <- 219833
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1697001')] <- 219976
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0971001')] <- 220075
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1093001')] <- 220181
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1666001')] <- 220604
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1862001')] <- 220792
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3343001')] <- 220862
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1911001')] <- 220978
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B3952001')] <- 221351
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2804001')] <- 221519
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2923001')] <- 221670
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3430002')] <- 221740
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3430001')] <- 221759
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3430004')] <- 221759
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3430006')] <- 221768
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3100001')] <- 221838
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3101001')] <- 221847
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3500001')] <- 221999
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0007001')] <- 222178
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0233001')] <- 222831
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0331001')] <- 222983
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0379001')] <- 223223
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0381001')] <- 223232
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3109001')] <- 224147
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3282001')] <- 224323
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3111001')] <- 224545
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3108001')] <- 224554
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3303001')] <- 225414
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3304001')] <- 225432
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3305001')] <- 225502
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3302001')] <- 225511
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3301001')] <- 225511
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3476001')] <- 225627
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1538001')] <- 225885
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1642001')] <- 226091
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3105001')] <- 226152
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1667001')] <- 226231
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1920001')] <- 226833
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3376003')] <- 227216
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B4834003')] <- 227368
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4735001')] <- 227368
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3439001')] <- 227377
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2555001')] <- 227526
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2638001')] <- 227757
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2986001')] <- 227845
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2728001')] <- 227881
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3010001')] <- 228149
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2926001')] <- 228246
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2962001')] <- 228343
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3059001')] <- 228431
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3123001')] <- 228459
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3076001')] <- 228501
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3093001')] <- 228529
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3435001')] <- 228635
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3432001')] <- 228644
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3434001')] <- 228653
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3110099')] <- 228705
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3106003')] <- 228714
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3104001')] <- 228723
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3730002')] <- 228723
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3437001')] <- 228769
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3438001')] <- 228778
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3440001')] <- 228787
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3441001')] <- 228796
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3444001')] <- 228802
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3114001')] <- 228866
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3115001')] <- 228875
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3376001')] <- 228909
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3119001')] <- 228981
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3442001')] <- 229018
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3443001')] <- 229027
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3121001')] <- 229063
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3124001')] <- 229115
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3127001')] <- 229179
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3185001')] <- 229267
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3431001')] <- 229300
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3125001')] <- 229337
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3600001')] <- 229814
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3661001')] <- 229887
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0472003')] <- 230038
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2937001')] <- 230603
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3491001')] <- 230728
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3492001')] <- 230737
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3448001')] <- 230764
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3578001')] <- 230782
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0556001')] <- 230834
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1247001')] <- 230898
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1563001')] <- 230913
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1912001')] <- 230959
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2358001')] <- 230995
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2711001')] <- 231059
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3449001')] <- 231174
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0759001')] <- 231624
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2613001')] <- 231651
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0676001')] <- 231712
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0988001')] <- 231970
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0980001')] <- 232043
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1087001')] <- 232089
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1193001')] <- 232186
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1282001')] <- 232265
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1536001')] <- 232423
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1686001')] <- 232557
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1714001')] <- 232566
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3329001')] <- 232681
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2269001')] <- 232937
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2403001')] <- 232982
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2598001')] <- 233277
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3403001')] <- 233374
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2649001')] <- 233426
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3082001')] <- 233718
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3451001')] <- 233897
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3525001')] <- 233921
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3520001')] <- 234030
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3450002')] <- 234076
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3524001')] <- 234085
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3526001')] <- 234155
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3565001')] <- 234207
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0610001')] <- 234827
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0989001')] <- 235097
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1061001')] <- 235167
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1227001')] <- 235316
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0369001')] <- 235547
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2445001')] <- 236230
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3400001')] <- 236328
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2707001')] <- 236452
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2792001')] <- 236577
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2793001')] <- 236595
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3563001')] <- 236939
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3452006')] <- 236948
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3634001')] <- 237011
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3647001')] <- 237057
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3651001')] <- 237066
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0072001')] <- 237118
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0441001')] <- 237215
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3272001')] <- 237312
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0806001')] <- 237330
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1793001')] <- 237525
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2816001')] <- 237792
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3605001')] <- 237880
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3606001')] <- 237899
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3595001')] <- 237932
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3607005')] <- 237950
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3609001')] <- 237969
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3607001')] <- 238032
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3643001')] <- 238078
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0094001')] <- 238193
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0393001')] <- 238333
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0553001')] <- 238476
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0817001')] <- 238616
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1663001')] <- 239017
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1791001')] <- 239105
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1857001')] <- 239169
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1935001')] <- 239318
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2332001')] <- 239512
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3014001')] <- 239716
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3471001')] <- 240189
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3459001')] <- 240268
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3460001')] <- 240277
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3461001')] <- 240329
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3464001')] <- 240365
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3465001')] <- 240374
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3469001')] <- 240417
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3470001')] <- 240426
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3462001')] <- 240444
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3463001')] <- 240453
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3466001')] <- 240462
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3467001')] <- 240471
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3468001')] <- 240480
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3472001')] <- 240727
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0190001')] <- 240736
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3294001')] <- 240754
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0544001')] <- 241331
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2545001')] <- 241410
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3236001')] <- 241739
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2544001')] <- 243081
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3390001')] <- 243106
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3394001')] <- 243151
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3395001')] <- 243179
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3396001')] <- 243197
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3388001')] <- 243203
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3397001')] <- 243212
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3398001')] <- 243221
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3237001')] <- 243346
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3235001')] <- 243568
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2542001')] <- 243577
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3238001')] <- 243601
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3480001')] <- 243665
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B4493001')] <- 243744
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2590001')] <- 243780
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2590004')] <- 243780
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2470002')] <- 243823
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2217001')] <- 262129
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516014')] <- 366711
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3452002')] <- 377555
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3452007')] <- 377564
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2340001')] <- 380377
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3717002')] <- 385415
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1633001')] <- 407629
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1049001')] <- 409254
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516010')] <- 409698
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0744001')] <- 413617
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3433001')] <- 416801
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B4382001')] <- 420246
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2118001')] <- 423494
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B4146001')] <- 430670
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2197001')] <- 432320
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1105001')] <- 433660
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S1726001')] <- 435000
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'R0732001')] <- 436377
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1787001')] <- 438513
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4728005')] <- 440031
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B3276001')] <- 441900
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0516002')] <- 441937
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1147001')] <- 441982
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1009001')] <- 442806
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3732001')] <- 443128
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3163001')] <- 445054
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3266014')] <- 445188
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2674001')] <- 445735
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3212001')] <- 446932
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1199001')] <- 447689
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3421001')] <- 448840
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3420001')] <- 451671
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3419001')] <- 451680
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'B3629001')] <- 455406
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U0793001')] <- 456542
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S1866001')] <- 458511
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3161001')] <- 459736
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4741001')] <- 459949
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4757001')] <- 475033
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1167001')] <- 481030
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1200001')] <- 482149
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3750001')] <- 482149
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4730001')] <- 482158
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4745001')] <- 482680
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4743001')] <- 482936
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3107001')] <- 483036
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4762001')] <- 483975
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4761001')] <- 485403
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3432002')] <- 485537
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4764001')] <- 486284
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U1597001')] <- 486840
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'S3430003')] <- 487010
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4765001')] <- 488527
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U4763001')] <- 488554
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U2590006')] <- 490805
ncses$ipeds_unitid[which(ncses$ncses_inst_id == 'U3125005')] <- 492689

# Manual code-in of missing ZIP Codes --------------------------------------------------------------------------

ncses$inst_zip[which(ncses$ncses_inst_id == 'U4759001')] <- '17013'
ncses$inst_zip[which(ncses$ncses_inst_id == 'N2840001')] <- '31411'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2541001')] <- '11201'
ncses$inst_zip[which(ncses$ncses_inst_id == 'N2127001')] <- '93501'
ncses$inst_zip[which(ncses$ncses_inst_id == 'R3068001')] <- '64110'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U3147001')] <- '85004'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U0265001')] <- '31419'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2931001')] <- '30060'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2883001')] <- '21202'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2225001')] <- '1608'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U3342001')] <- '8103'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U0948001')] <- '1769'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2498015')] <- '19355'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2498006')] <- '18034'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2498003')] <- '16601'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2498004')] <- '15061'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2498005')] <- '19610'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2498017')] <- '19063'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U2509001')] <- '19104'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U3106003')] <- '77554'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U1247001')] <- '05764'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U1787001')] <- '22134'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U3212001')] <- '12308'
ncses$inst_zip[which(ncses$ncses_inst_id == 'U3419001')] <- '33805'

# Read in html.ncses source code from IPEDS Data Center ---------------------------------------------------------

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

# NCSES x IPEDS merge and data cleaning  ---------------------------------------------------------

ipeds <- subset(ipeds, select = c('UNITID','INSTNM','ZIP','EIN','DUNS','OPEID','HBCU','TRIBAL','COUNTYCD','LONGITUD','LATITUDE'))

names(ipeds)[names(ipeds) == 'UNITID'] <- 'ipeds_unitid'

common_col_names <- intersect(names(ncses), names(ipeds))
ncses <- merge(ncses, ipeds, by = common_col_names, all = TRUE)
rm(common_col_names)
rm(ipeds)

ncses <-  ncses[!(is.na(ncses$ncses_inst_id) | ncses$ncses_inst_id==""), ]

ncses$ZIP <- coalesce(ncses$ZIP, ncses$inst_zip)
ncses <- subset(ncses, select = -c(inst_zip))

ncses$INSTNM <- coalesce(ncses$INSTNM, ncses$inst_name_short)
ncses <- subset(ncses, select = -c(inst_name_short, inst_name_long, inst_id))

names(ncses)[names(ncses) == 'ipeds_unitid'] <- 'IPEDS_ID'
names(ncses)[names(ncses) == 'ncses_inst_id'] <- 'NCSES_ID'

ncses$ZIP <- substring(ncses$ZIP, 1, 5)

# Encode and merge ZIP Codes from HUD crosswalk (static on GitHub) ---------------------------------------------------------

gc()
zip2cty <- "https://github.com/glencorahaskins/metro-repository/blob/main/metro-repository-app/data/static%20frames/hud_zip2cty.zip?raw=true"
download.file(zip2cty, "zip2cty.zip", quiet = TRUE, mode = "wb")
unzip("zip2cty.zip")
load(file = "hud_zip2cty.Rda")
file.remove("zip2cty.zip")
file.remove("hud_zip2cty.Rda")

names(zip2cty)[names(zip2cty) == 'zip'] <- 'ZIP'

zip2cty <- zip2cty[!duplicated(zip2cty$ZIP),]
zip2cty$county <- as.numeric(zip2cty$county)

common_col_names <- intersect(names(ncses), names(zip2cty))
ncses <- merge(ncses, zip2cty, by = common_col_names, all = TRUE)
rm(common_col_names)
rm(zip2cty)

ncses <-  ncses[!(is.na(ncses$NCSES_ID) | ncses$NCSES_ID ==""), ]
ncses$COUNTYCD <- coalesce(ncses$COUNTYCD, ncses$county)

ncses <- subset(ncses, select = -c(county, usps_zip_pref_city, usps_zip_pref_state, res_ratio, bus_ratio, oth_ratio, tot_ratio))

ncses <- ncses %>% relocate(NCSES_ID) 
ncses <- ncses %>% relocate(IPEDS_ID, .after = NCSES_ID)
ncses <- ncses %>% relocate(EIN, .after = IPEDS_ID)
ncses <- ncses %>% relocate(DUNS, .after = EIN)
ncses <- ncses %>% relocate(OPEID, .after = DUNS)
ncses <- ncses %>% relocate(INSTNM, .after = OPEID)
ncses <- ncses %>% relocate(ZIP, .after = last_col())

# Aggregate to county ---------------------------------------------------------

univ_rd_cty <- ncses
univ_rd_cty <- subset(univ_rd_cty, select = -c(NCSES_ID, IPEDS_ID, EIN, DUNS, OPEID, INSTNM, HBCU, TRIBAL, LONGITUD, LATITUDE, ZIP))

univ_rd_cty <- univ_rd_cty %>% relocate(COUNTYCD) 

current_names <- names(univ_rd_cty)
names(univ_rd_cty) <- c("COUNTYCD", "y1", "y2", "y3", "y4", "y5", "y6", "y7", "y8", "y9", "y10")

univ_rd_cty <- univ_rd_cty %>% group_by(COUNTYCD) %>% summarize(y1 = sum(y1),
                                                                 y2 = sum(y2),
                                                                 y3 = sum(y3),
                                                                 y4 = sum(y4),
                                                                 y5 = sum(y5),
                                                                 y6 = sum(y6),
                                                                 y7 = sum(y7),
                                                                 y8 = sum(y8),
                                                                 y9 = sum(y9),
                                                                 y10 = sum(y10))

names(univ_rd_cty) <- current_names
rm(current_names)

univ_rd_cty <-  univ_rd_cty[!(is.na(univ_rd_cty$COUNTYCD) | univ_rd_cty$COUNTYCD ==""), ]

univ_rd_cty$COUNTYCD <- as.character(univ_rd_cty$COUNTYCD)
for(i in 1:length(univ_rd_cty$COUNTYCD)) {
  if(as.numeric(univ_rd_cty$COUNTYCD[i]) < 10000) {
    univ_rd_cty$COUNTYCD[i] <- paste0("0", univ_rd_cty$COUNTYCD[i])
  }
}
rm(i)









