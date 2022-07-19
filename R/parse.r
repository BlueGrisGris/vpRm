#' parse_modis_evi_times  
#'  
#' @param evi_filenames (chr): evi modis filenames to extract date times from 
#' 
#' @export
parse_modis_evi_times <- function(evi_filenames){

### someday maybe replace str_split w strsplit
yy <- stringr::str_split(evi_filenames, "_", simplify = T)[,7]

yr <- as.numeric( substr(yy, start = 4, stop = 7)) 
doy <- as.numeric( substr(yy, start = 8, stop = 11)) 
doy <- doy - 1

evi_times <- as.Date(paste0(yr, "-01-01")) + doy
evi_times <- as.POSIXct(evi_times, tz = "")

return(evi_times)

}#end func parse_modis_evi_times 
