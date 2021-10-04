

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
area_data <- fread(path_area, fill = TRUE)
facility_data <- fread(path_facility, fill = TRUE)

## plot sample
plot_data <- area_data[id == "1[Anlagenring]",
                       list(parkingAreaStatusTime, parkingAreaOccupancy)]
plot(plot_data)

ggplot(data = area_data, aes(x = parkingAreaStatusTime, y = parkingAreaOccupancy, color = id)) +
  geom_smooth()

ggplot(data = facility_data[
  #parkingFacilityStatusTime %between% c(as.Date("2021-07-15"),
  #                                                                as.Date("2021-08-01"))
],
aes(x = parkingFacilityStatusTime,
    y = parkingFacilityOccupancy,
    color = id)) +
  geom_line() +
  geom_smooth() +
  facet_wrap(~id, scales = "free_y")

logger::log_info(" --------   desc area ----- ")

cat("timepoints:", area_data[, uniqueN(TIME)], "\n")
cat("areas:", area_data[, uniqueN(id)], "\n")
cat("open:", area_data[, uniqueN(TIME)], "\n")

logger::log_info(" --------   desc facility - ")
cat("timepoints:", facility_data[, uniqueN(parkingFacilityStatusTime)], "\n")
cat("car parks:", facility_data[, uniqueN(id)], "\n")
cat("open:", facility_data[, round(mean(parkingFacilityStatus == "open", na.rm = TRUE), 2)], "\n")


logger::log_info(" --------   done   -------- ")

