
# settings ----------------------------------------------------------------

## libraries
library(XML)
library(data.table)
library(logger)

## functions
check <- lapply(X = list.files("code/functions", full.names = TRUE), FUN =  source)

logger::log_threshold(Sys.getenv("log_level", "INFO"))

logger::log_info(" -------- starting -------- ")

## variables
url <- "https://offenedaten.frankfurt.de/dataset/912fe0ab-8976-4837-b591-57dbf163d6e5/resource/48378186-5732-41f3-9823-9d1938f2695e/download/parkdaten_dyn.xml"
path_area <- "data/area.csv"
path_facility <- "data/facility.csv"

parking_list <- get_parking_data(url = url)
area_data <- parking_list[[1]]
facility_data <- parking_list[[2]]

logger::log_info("write data")

data.table::fwrite(x = area_data, file = path_area, append = file.exists(path_area))


logger::log_info(" --------   done   -------- ")
