source("https://raw.githubusercontent.com/glencorahaskins/metro-repository/main/metro-functions/metro-packages.R")
gc()

# IMPORT PATENTS ------------------------------------------------------------------- 

url <- "https://www.uspto.gov/web/offices/ac/ido/oeip/taf/countyall/usa_county_gd.htm"
df <- url %>%
  read_html() %>%
  html_nodes("table") %>%
  html_table(fill = T)%>%
  lapply(., function(x) setNames(x, c("FIPS Code", "Mail Code", "State or Territory", "Regional Area Component", 
                                      "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009",
                                      "2010", "2011", "2012", "2013", "2014", "2015", "Total")))

df <- data.frame(df)
rm(url)
gc()

patents <- df
rm(df)

names(patents) <- c("stco_code", "mail_code", "state", "stco_name", "2000", "2001", "2002", "2003", "2004", "2005", "2006",
                  "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "total")

patents <- patents[patents$stco_code != "ALL", ]
patents <- subset(patents, select = -c(mail_code, state, stco_name))

# IMPORT INVENTORS ------------------------------------------------------------------- 

url <- "https://www.uspto.gov/web/offices/ac/ido/oeip/taf/inv_countyall/usa_invcounty_gd.htm"
df <- url %>%
  read_html() %>%
  html_nodes("table") %>%
  html_table(fill = T)%>%
  lapply(., function(x) setNames(x, c("FIPS Code", "Mail Code", "State or Territory", "Regional Area Component", 
                                      "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009",
                                      "2010", "2011", "2012", "2013", "2014", "2015", "Total")))

df <- data.frame(df)
rm(url)
gc()

inventors <- df
rm(df)

names(inventors) <- c("stco_code", "mail_code", "state", "stco_name", "2000", "2001", "2002", "2003", "2004", "2005", "2006",
                  "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "total")

inventors <- inventors[inventors$stco_code != "ALL", ]
inventors <- subset(inventors, select = -c(mail_code, state, stco_name))