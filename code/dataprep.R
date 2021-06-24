

# settings ----------------------------------------------------------------

## libraries
library(XML)
library(data.table)
library(logger)
library(ggplot2)

## functions
check <- lapply(X = list.files("code/functions", full.names = TRUE), FUN =  source)

logger::log_threshold(Sys.getenv("log_level", "INFO"))

logger::log_info(" -------- starting -------- ")

## variables
path_area <- "data/area.csv"
path_facility <- "data/facility.csv"

## load data
area_data <- fread(path_area)
facility_data <- fread(path_facility)

## plot sample
plot_data <- area_data[id == "1[Anlagenring]",
                       list(parkingAreaStatusTime, parkingAreaOccupancy)]
plot(plot_data)

ggplot(data = area_data, aes(x = parkingAreaStatusTime, y = parkingAreaOccupancy, color = id)) +
  geom_line()

logger::log_info(" --------   done   -------- ")

