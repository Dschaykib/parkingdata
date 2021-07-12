#' Retrieves parking data
#'
#' @param url an url to the park data
#'
#' @return
#' @export
#'
#' @examples
#'
get_parking_data <- function(url) {
  # Give the input file name to the function.
  logger::log_debug("read parking data")
  result <- tryCatch(XML::xmlParse(file = readLines(con = url, warn = FALSE)),
                     error = function(e) e)

  if ("simpleError" %in% class(result)) {
    logger::log_error(paste0("url does not lead to data: ", url))
    # check this site if the url is correct:
    # url <- https://www.offenedaten.frankfurt.de/dataset/parkdaten-dynamisch/resource/48378186-5732-41f3-9823-9d1938f2695e
    stop()
  }

  logger::log_info("convert parking data from XML format")
  rootnode <- XML::xmlRoot(result)

  # publication Time
  this_time <- XML::xmlToDataFrame(rootnode[[2]][1], stringsAsFactors = FALSE)[1,]

  # publication Town
  #this_town <- XML::xmlToDataFrame(rootnode[[2]][[2]], stringsAsFactors = FALSE)[2,]

  # data
  data_names <- names(rootnode[[2]][[4]][[1]])

  area_index <- grep("parkingAreaStatus", data_names)
  facility_index <- grep("parkingFacilityStatus", data_names)

  # area
  area_data <- XML::xmlToDataFrame(rootnode[[2]][[4]][[1]][area_index])

  area_station <- data.table::rbindlist(lapply(area_index, function(x) {
    data.table::data.table(t(XML::xmlToList(rootnode[[2]][[4]][[1]][x]$parkingAreaStatus[[2]])))}
  ), use.names = TRUE, fill = TRUE)

  area_data$parkingAreaReference <- NULL
  area_data <- cbind(area_data, area_station)
  area_data$TIME <- this_time
  #area_data$TOWN <- this_town

  # facility
  facility_data <- XML::xmlToDataFrame(rootnode[[2]][[4]][[1]][facility_index])
  facility_station <- data.table::rbindlist(lapply(facility_index, function(x) {
    # x <- facility_index[1]
    data.table::data.table(t(XML::xmlToList(rootnode[[2]][[4]][[1]][x]$parkingFacilityStatus[[2]])))}
  ), use.names = TRUE, fill = TRUE)

  facility_data$parkingFacilityReference <- NULL
  facility_data <- cbind(facility_data, facility_station)
  facility_data$TIME <- this_time
  #facility_data$TOWN <- this_town


  # remove columns
  area_data$version <- NULL
  area_data$targetClass <- NULL

  facility_data$version <- NULL
  facility_data$targetClass <- NULL

  #out <- rbindlist(list(area_data, facility_data), use.names = TRUE, fill = TRUE)
  out <- list(area_data, facility_data)
  logger::log_debug("return parking data")
  return(out)
}

