
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
path_events <- "data/events.csv"

## load data
logger::log_info("load data")
area_data <- fread(path_area)
facility_data <- fread(path_facility)
event_data <- fread(path_events)


## get variables
logger::log_info("calculate KPIs")
# parking
parking_last_call <- max(c(area_data$TIME, facility_data$TIME), na.rm = TRUE)
parking_num_calls <- uniqueN(c(area_data$TIME, facility_data$TIME))
parking_num_carparks <- uniqueN(facility_data$id)
parking_num_areas <- uniqueN(area_data$id)

parking_time_range <- floor(as.numeric(range(diff(unique(area_data$TIME)),
                                             diff(unique(area_data$TIME)))))
parking_num_format <- max(nchar(c(parking_num_calls,
                                  parking_num_areas,
                                  parking_num_carparks,
                                  parking_time_range)))

# events
event_last_call <- max(event_data$request, na.rm = TRUE)
event_num_calls <- uniqueN(event_data$request)
event_num_events <- uniqueN(event_data$eventtitle)

# in hours
event_time_range <- floor(range(diff(as.integer(unique(event_data$request)))) / (60*60))
event_num_format <- max(nchar(c(event_num_calls,
                                event_num_events,
                                event_time_range)))

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
  paste0("The last call was at ", last_call, " UTC"), "",
  paste0("Number of calls   : ",
         sprintf(paste0("%", num_format, "d"), num_calls)), "",
  paste0("Number of stations: ",
         sprintf(paste0("%", num_format, "d"), num_carparks)), "",
  paste0("Number of areas   : ",
         sprintf(paste0("%", num_format, "d"), num_areas)), "",
  paste0("Time step range   : ",
         paste0(sprintf(paste0("%", num_format, "d"), time_range), collapse = " - "),
         " minutes"),
  "",
  "",
  "## Event data",
  "The data is extracted from [stadtleben.de](https://stadtleben.de/frankfurt/).",
  "",
  paste0("The last call was at ", event_last_call, " UTC"), "",
  paste0("Number of calls   : ",
         sprintf(paste0("%", event_num_format, "d"), event_num_calls)), "",
  paste0("Number of events  : ",
         sprintf(paste0("%", event_num_format, "d"), event_num_events)), "",
  paste0("Time step range   : ",
         paste0(sprintf(paste0("%", event_num_format, "d"), event_time_range), collapse = " - "),
         " hours"),
  ""
)

writeLines(text = readme_text, con = "README.md", sep = "\n")


logger::log_info(" --------   done   -------- ")
