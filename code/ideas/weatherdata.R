
# used libraries
library(rdwd)
library(bit64)
library(data.table)
library(logger)
library(ggplot2)

locations <- rdwd::findID("Frankfurt/Main",
                          exactmatch = FALSE,
                          quiet = TRUE)
#locations <- c(1424)

# select a dataset (e.g. last year's daily climate data from Potsdam city):
#debugonce(rdwd::selectDWD)
link <- rdwd::selectDWD(id = locations,#[c(3,2)],
                        res = "10_minutes",
                        var = "precipitation",
                        per = "recent",
                        outvec = TRUE)
link <- unique(link)

# remove old data to get new data
unlink(x = "DWDdata", recursive = TRUE)
# Actually download that dataset, returning the local storage file name:
file <- rdwd::dataDWD(link, read = FALSE)
file <- grep(".zip", file, value = TRUE)

# Read the file from the zip folder:
tmp <- rdwd::readDWD(file, varnames = TRUE)
clim <- data.table::rbindlist(tmp, use.names = TRUE, fill = TRUE)

# Inspect the data.frame:

clim[!is.na(RWS_10.Niederschlagshoehe), range(MESS_DATUM, na.rm = TRUE)]
ggplot(data = clim[as.Date(MESS_DATUM) > as.Date("2020-08-03") &
                     RWS_10.Niederschlagshoehe > 0,],
       aes(x = MESS_DATUM, y = RWS_10.Niederschlagshoehe, color = STATIONS_ID)) +
  geom_point() +
  facet_wrap(~STATIONS_ID)
