
# settings ----------------------------------------------------------------

## libraries
library(XML)
library(data.table)
library(logger)
library(glue)

## functions
check <- lapply(X = list.files("code/functions", full.names = TRUE), FUN =  source)

logger::log_threshold(Sys.getenv("log_level", "INFO"))

logger::log_info(" -------- starting parking -------- ")



# parking -----------------------------------------------------------------


## variables parking
url <- "https://offenedaten.frankfurt.de/dataset/912fe0ab-8976-4837-b591-57dbf163d6e5/resource/48378186-5732-41f3-9823-9d1938f2695e/download/parkdaten_dyn.xml"
path_area <- "data/area.csv"
path_facility <- "data/facility.csv"



## request parking data
parking_list <- get_parking_data(url = url)
area_data <- parking_list[[1]]
facility_data <- parking_list[[2]]

logger::log_info("write data")

data.table::fwrite(x = area_data, file = path_area, append = file.exists(path_area), sep = ";")
data.table::fwrite(x = facility_data, file = path_facility, append = file.exists(path_facility), sep = ";")


logger::log_info(" --------   done parking -------- ")


# events ------------------------------------------------------------------


# parking data is requested every time, but events only every 8 hours

logger::log_info(" -------- starting events -------- ")

## variables events
days_ahead <- 0:8
days <- format(Sys.Date()+days_ahead, "%Y/%m/%d")
base_url <- "https://stadtleben.de/frankfurt/kalender/"
url_all <- paste0(base_url, days)
path_events <- "data/events.csv"
event_freq <- 8*60*60 # every 8 hours

# get previous data
if (file.exists(path_events)) {
  event_data_prev <- fread(file = path_events, sep = ";")
  event_data_prev <- event_data_prev[!is.na(eventtitle) & eventtitle != "",]
  last_event_call <- max(event_data_prev$request, na.rm = TRUE)
} else {
  event_data_prev <- data.table()
  # to make sure, that events are triggerd, add 1
  last_event_call <- Sys.time() - (event_freq + 1)
}

logger::log_info("next event call at around {last_event_call + event_freq}")

if (last_event_call <= Sys.time() - event_freq) {
  logger::log_info("doning new event call")
  
  ## request event data
  event_data_list <- lapply(X = url_all, FUN = get_evet_data)
  logger::log_info("done reqeusting data")
  
  ## load previous data and combine results
  
  
  event_data_list <- data.table::rbindlist(event_data_list,
                                      use.names = TRUE,
                                      fill = TRUE)
  
  event_data <- data.table::rbindlist(list(event_data_prev,
                            event_data_list),
                          use.names = TRUE,
                          fill = TRUE)
  
  ## when there are multiple requests per day, take the maximum number of views
  col_order <- names(event_data)
  event_data[, request_date := as.IDate(request)]
  this_key <- setdiff(names(event_data), c("views", "request"))
  
  #event_data[, eventtitle := stringi::stri_trans_general(eventtitle, "latin-ascii")]
  
  event_data <- event_data[, list("views" = max(views, na.rm = TRUE),
                                  "request" = max(request, na.rm = TRUE)),
                           by = this_key
  ][, .SD, .SDcols = col_order]
  
  event_data[, request_date := NULL]
  event_data <- unique(event_data)
  logger::log_info(paste0("Adding new events: ",
                          sum(!unique(event_data$eventtitle) %in%
                                unique(event_data_prev$eventtitle))))
  
  
  logger::log_info("write data")
  data.table::fwrite(x = event_data,
                     file = path_events,
                     sep = ";",
                     append = FALSE)
}

logger::log_info(" --------   done events  -------- ")


# splitting data ----------------------------------------------------------

this_lable <- paste0(data.table::year(Sys.Date()), "_",
                     data.table::month(Sys.Date()))
# check if current month already exists
archiv_files <- list.files(path = "data/archiv/",
                           pattern = this_lable,
                           recursive = TRUE)

if (length(archiv_files) != 3) {
  split_data_monthly()
}

logger::log_info(" --------   done   -------- ")
