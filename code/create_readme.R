
# settings ----------------------------------------------------------------

## libraries
library(data.table)
library(logger)

## functions
check <- lapply(X = list.files("code/functions", full.names = TRUE), FUN =  source)

logger::log_threshold(Sys.getenv("log_level", "INFO"))

logger::log_info(" -------- updating readme file")

## variables
path_area <- "data/area.csv"
path_facility <- "data/facility.csv"

## load data
logger::log_info("load data")
area_data <- fread(path_area)
facility_data <- fread(path_facility)


## get variables
logger::log_info("calculate KPIs")
last_call <- max(c(area_data$TIME, facility_data$TIME), na.rm = TRUE)
num_calls <- uniqueN(c(area_data$TIME, facility_data$TIME))
num_carparks <- uniqueN(facility_data$id)
num_areas <- uniqueN(area_data$id)

num_format <- max(nchar(c(num_calls, num_areas, num_carparks)))

## write readme file
logger::log_info("write readme file")
readme_text <- c(
  "# An example for data gathering",
  "",
  "This repo uses the GitHub Actions to access parking and event data in Frankfurt.",
  "",
  "## Parking data",
  "The data is provided by the [open data collection of the city](https://www.offenedaten.frankfurt.de/).",
  "",
  paste0("The last call was at ", last_call, " CEST"), "",
  paste0("Number of calls   : ", sprintf(paste0("%", num_format, "d"), num_calls)), "",
  paste0("Number of stations: ", sprintf(paste0("%", num_format, "d"), num_carparks)), "",
  paste0("Number of areas   : ", sprintf(paste0("%", num_format, "d"), num_areas)),
  ""
)

writeLines(text = readme_text, con = "README.md", sep = "\n")



logger::log_info(" --------   done   -------- ")
