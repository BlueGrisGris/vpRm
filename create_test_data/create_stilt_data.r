library(terra)
library(vpRm)

stilt_filenames <- list.files("~/storage/STILT_slantfoot", full.names = T)
stilt_times <- parse_stilt_times(stilt_filenames)

my_stilt_times <- stilt_times[paste0(lubridate::year(stilt_times),lubridate::month(stilt_times), lubridate::day(stilt_times)) == 2020131]

stilt_filenames <- stilt_filenames[stilt_times %in% my_stilt_times]
stilt <- rast(stilt_filenames)[[1:2]]
times <- time(stilt)

stilt <- terra::aggregate(stilt,fact = 20)
time(stilt) <- times

writeCDF(stilt, "~/vpRm/inst/test_data/stilt_test/by-id/01/01_foot.nc", zname = "time", overwrite = T)

rast("~/vpRm/inst/test_data/stilt_test/by-id/01/01_foot.nc")

