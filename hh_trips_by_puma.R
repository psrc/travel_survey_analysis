# Libraries ---------------------------------------------------------------

library(sf)
library(dplyr)
library(leaflet)
library(data.table)
library(tidyverse)
library(DT)
library(openxlsx)
library(odbc)
library(DBI)
library(psych)


# General Inputs ----------------------------------------------------------

# gegeographic data from ElmerGeo
geodatabase_server <- "AWS-PROD-SQL\\Sockeye"
geodatabase_name <- "ElmerGeo"
gdb_nm <- paste0("MSSQL:server=",geodatabase_server,";database=",geodatabase_name,";trusted_connection=yes")
tbl_nm <- "DBO.REG10PUMA"
wa_north <- 2285
wgs_84 <- 4326


# connecting to Elmer
db.connect <- function() {
  elmer_connection <- dbConnect(odbc(),
                                driver = "SQL Server",
                                server = "AWS-PROD-SQL\\Sockeye",
                                database = "Elmer",
                                trusted_connection = "yes"
  )
}

# a function to read tables and queries from Elmer
read.dt <- function(astring, type =c('table_name', 'sqlquery')) {
  elmer_connection <- db.connect()
  if (type == 'table_name') {
    dtelm <- dbReadTable(elmer_connection, SQL(astring))
  } else {
    dtelm <- dbGetQuery(elmer_connection, SQL(astring))
  }
  dbDisconnect(elmer_connection)
  dtelm
}

#get the travel survey data by puma
sql.household.query<-paste("SELECT count(hh_wt_combined) AS HHCount,final_home_puma10 
                           FROM HHSurvey.v_households_2017_2019
                           GROUP BY final_home_puma10 ")
households <- read.dt(sql.household.query, 'sqlquery')

#sql.trip.query <- paste("SELECT trip_wt_combined,d_puma10,mode_simple,mode_acc FROM HHSurvey.v_trips_2017_2019_in_house")
#trips <- read.dt(sql.trip.query, 'sqlquery')

#get the geo puma data
pumas<- st_read(gdb_nm, tbl_nm, crs=wa_north) %>%st_transform(wgs_84)
pumas$pumace10 <- as.numeric(as.character(pumas$pumace10))
hhs_pumas<-inner_join(pumas,households,by= c("pumace10" = "final_home_puma10"))

factpal <- colorNumeric( palette="Reds", domain=hhs_pumas$HHCount, na.color="transparent")

puma_count_map<-leaflet(data=hhs_pumas) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(stroke = TRUE, smoothFactor = 0.2, fillOpacity = .75,
              weight=1,
              fillColor = ~factpal(HHCount),
              color='Purple',
              dashArray=1.0,
              label=hhs_pumas$HHCount,
              labelOptions = (noHide=TRUE))%>%
  addLegend("bottomright", factpal, values = ~HHCount,
            title = "Households by PUMA in 2017 and 2019 HHTS",
            opacity = 1)  %>%
  addTiles()


transit_trip_map <-
