
# settings ----------------------------------------------------------------

## libraries
library(data.table)
library(logger)
library(helfRlein)

## functions
check <- lapply(X = list.files("code/functions", full.names = TRUE), FUN =  source)

logger::log_threshold(Sys.getenv("log_level", "INFO"))

logger::log_info(" -------- updating readme file")

## variables
files_area <- list.files(path = "data/", pattern = "area", recursive = TRUE, full.names = TRUE)
files_facility <- list.files(path = "data/", pattern = "facility", recursive = TRUE, full.names = TRUE)
files_events <- list.files(path = "data/", pattern = "events", recursive = TRUE, full.names = TRUE)

## load data
logger::log_info("load data")
area_data <- helfRlein::read_files(files = files_area, fun = fread, fill = TRUE, sep = ";")
facility_data <- helfRlein::read_files(files = files_facility, fun = fread, fill = TRUE, sep = ";")
event_data <- helfRlein::read_files(files = files_events, fun = fread, fill = TRUE, sep = ";")

## get variables
logger::log_info("calculate KPIs")
# parking
parking_last_call <- max(c(area_data$TIME, facility_data$TIME), na.rm = TRUE)
parking_num_calls <- uniqueN(c(area_data$TIME, facility_data$TIME))

parking_num_carparks <- uniqueN(facility_data$id)
parking_num_areas <- uniqueN(area_data$id)

parking_time_range <- floor(as.numeric(range(
  diff(unique(area_data$TIME)),
  diff(unique(area_data$TIME)),
  na.rm = TRUE)))

parking_num_format <- max(nchar(c(parking_num_calls,
                                  parking_num_areas,
                                  parking_num_carparks,
                                  parking_time_range)))

# events
event_last_call <- max(event_data$request, na.rm = TRUE)
event_num_calls <- uniqueN(event_data$request)
event_num_events <- uniqueN(event_data$eventtitle)

# in hours
event_time_range <- floor(range(diff(unique(round(as.integer(sort(unique(
  event_data$request))), digits = -3)))) / (60*60))
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
  paste0("The last call was at ", parking_last_call, " UTC"), "",
  paste0("Number of calls   : ",
         sprintf(paste0("%", parking_num_format, "d"), parking_num_calls)), "",
  paste0("Number of stations: ",
         sprintf(paste0("%", parking_num_format, "d"), parking_num_carparks)), "",
  paste0("Number of areas   : ",
         sprintf(paste0("%", parking_num_format, "d"), parking_num_areas)), "",
  paste0("Time step range   : ",
         paste0(sprintf(paste0("%", parking_num_format, "d"), parking_time_range), collapse = " - "),
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
  "",
  "",
  "----",
  "",
  paste0("Last updated at ", as.character(Sys.time()), " UTC")
)

writeLines(text = readme_text, con = "README.md", sep = "\n")


logger::log_info(" --------   done   -------- ")
