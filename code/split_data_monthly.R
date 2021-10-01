
# settings ----------------------------------------------------------------

## libraries
library(data.table)
library(logger)
library(glue)

## functions
check <- lapply(X = list.files("code/functions", full.names = TRUE), FUN =  source)

logger::log_threshold(Sys.getenv("log_level", "INFO"))

logger::log_info(" -------- splitting data into monthly files")

## variables
path_area <- "data/area.csv"
path_facility <- "data/facility.csv"
path_events <- "data/events.csv"


if (!dir.exists(target_folder)) {
  dir.create(target_folder)
}

## load data
logger::log_info("load data")
area_data <- fread(path_area, fill = TRUE)
facility_data <- fread(path_facility, fill = TRUE)
event_data <- fread(path_events)


split_data <- function(data, path, target_folder, splitvar) {
  
  # check target folder
  if (!dir.exists(target_folder)) {
    dir.create(target_folder, recursive = TRUE)
  }
  
  # split data by month and year
  this_dataname <- gsub("\\..*", "", basename(path))
  
  data_list <- split(
    x = data,
    f = paste0(
      year(data[[splitvar]]), "_",
      sprintf("%02d", month(data[[splitvar]]))
    )
  )
  
  ## saving data to archive
  i_data <- 1
  for (i_data in seq_along(data_list)) {
    
    this_name <- paste0(target_folder, "/",
                        this_dataname, "_",
                        names(data_list)[i_data], ".csv")
    
    if (file.exists(this_name)) {
      logger::log_info("rewriting {this_name}")
      prev_data <- data.table::fread(this_name)
      
      out_data <- unique(data.table::rbindlist(
        list(prev_data, data_list[[i_data]]),
        use.names = TRUE,
        fill = TRUE))
      
      logger::log_info("from {nrow(prev_data)} to {nrow(out_data)} rows")
      
    } else {
      logger::log_info("saving: {this_name}")
      out_data <- data_list[[i_data]]
    }
    
    
    data.table::fwrite(x = out_data, file = this_name)
    
  }
  
  # removing all but the last months
  logger::log_info("saving short {this_dataname} data")
  data_short <- data.table::last(data_list)
  data.table::fwrite(x = data_short, file = path)
  
  return(NULL)
}

# area data
split_data(data = area_data,
           path = path_area,
           target_folder = "data/archiv/area",
           splitvar = "TIME")

# facility data
split_data(data = facility_data,
           path = path_facility,
           target_folder = "data/archiv/facility",
           splitvar = "TIME")

# event data
split_data(data = event_data,
           path = path_events,
           target_folder = "data/archiv/events",
           splitvar = "request")



logger::log_info(" --------   done   -------- ")
