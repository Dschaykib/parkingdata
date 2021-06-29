#' Retrieves event data
#'
#' @param url an url to the event data listed on
#'   https://stadtleben.de/frankfurt/kalender/
#'
#' @return a data.table with the extracted event data
#'
#'
#' @export
#'
#' @examples
#'
get_evet_data <- function(url) {
  # url <- url_all[2]

  # scrape event site
  logger::log_info(paste0("Try to read data from ", url))
  event_site_raw <- tryCatch({
    htmlParse(file = readLines(con = url, warn = FALSE),
              trim = TRUE,
              asText = TRUE)},
    error = function(e) e)

  # error handling
  if ("simpleError" %in% class(event_site_raw)) {
    logger::log_error("event site could not be read")
    # check this site if the url is correct:
    # url <- https://www.offenedaten.frankfurt.de/dataset/parkdaten-dynamisch/resource/48378186-5732-41f3-9823-9d1938f2695e
    return(data.table())
  }


  # exclude entries
  logger::log_info("extract events and clean data")
  exclude_entry <- c("TIPP",
                     "Events eintragen",
                     "Ich komme auch ",
                     "Location als Favorit ",
                     "Tickets bestellen ")

  # get list of events
  event_tag <- "//div [@id='kalenderListe']//text()"
  event_list <- xpathSApply(event_site_raw, event_tag, xmlValue)
  event_list <- gsub("(\n)|(\t)", "", event_list)
  event_list <- event_list[event_list != "" & !event_list %in% exclude_entry]

  # extract date and day info
  event_date <- gsub("^.*, ", "", event_list[1])
  event_day <- gsub(", .*$", "", event_list[1])
  event_list <- event_list[-1]

  # combine list into data.table
  # removing empty first column
  out <- as.data.table(matrix(event_list, ncol = 5, byrow = TRUE))[, -c(1)]
  setnames(x = out, new = c("eventtitle", "views", "place", "address"))
  out[, views := as.integer(gsub("[[:punct:]|[:alpha:]]", "", views))]
  out[, eventday := event_day]
  out[, eventdate := as.IDate(event_date, format = "%d.%m.%Y")]
  out[, request := Sys.time()]
  return(out)
}