
# settings ----------------------------------------------------------------

## libraries
library(XML)
library(data.table)
library(logger)

## functions
check <- lapply(X = list.files("code/functions", full.names = TRUE), FUN =  source)

logger::log_threshold(Sys.getenv("log_level", "INFO"))

logger::log_info(" -------- starting -------- ")

## setup variables
days_ahead <- 0:8
days <- format(Sys.Date()+days_ahead, "%Y/%m/%d")
base_url <- "https://stadtleben.de/frankfurt/kalender/"
url_all <- paste0(base_url, days)
path_events <- "data/events.csv"


## request event data
event_data_list <- lapply(X = url_all, FUN = get_evet_data)

## load previous data and combine results

if (file.exists(path_events)) {
  event_data_prev <- fread(file = path_events, sep = ";")
} else {
  event_data_prev <- data.table()
}

event_data <- rbindlist(c(list(event_data_prev), event_data_list),
                        use.names = TRUE,
                        fill = TRUE)

## when there are multiple requests per day, take the maximum number of views
col_order <- names(event_data)
this_key <- setdiff(names(event_data), c("views", "request"))
event_data <- event_data[, list("views" = max(views),
                                "request" = max(request)),
                         by = this_key
                         ][, .SD, .SDcols = col_order]


event_data <- unique(event_data)
logger::log_info(paste0("Adding new events: ",
                        event_data[request == max(request), .N]))

logger::log_info("write data")
data.table::fwrite(x = event_data,
                   file = path_events,
                   sep = ";",
                   append = file.exists(path_events))

logger::log_info(" --------   done   -------- ")
