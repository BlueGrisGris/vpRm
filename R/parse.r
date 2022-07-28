#' parse_modis_evi_times  
#'  
#' @param evi_filenames (chr): evi modis filenames to extract date times from 
#' 
#' @export
parse_modis_evi_times <- function(evi_filenames){

### someday maybe replace str_split w strsplit
yy <- stringr::str_extract(evi_filenames, "[0-9]{7}")

yr <- as.numeric( substr(yy, start = 1, stop = 4)) 
doy <- as.numeric( substr(yy, start = 5, stop = 7)) 
doy <- doy - 1

evi_times <- as.Date(paste0(yr, "-01-01")) + doy
evi_times <- as.POSIXct(evi_times, tz = "")

return(evi_times)

}#end func parse_modis_evi_times 

### TODO: TEST

#' parse_herbie_hrrr_times  
#'  
#' @param hrrr_filenames (chr): hrrr modis filenames to extract date times from 
#' 
#' @export
parse_herbie_hrrr_times <- function(hrrr_filenames){

### someday maybe replace str_split w strsplit
yy <- stringr::str_extract(hrrr_filenames, "[0-9]{8}")

yr <- as.numeric( substr(yy, start = 1, stop = 4)) 
month <- as.numeric( substr(yy, start = 5, stop = 6)) 
day <- as.numeric( substr(yy, start = 7, stop = 8)) 
hour <- as.numeric(substring( stringr::str_extract(hrrr_filenames, "t[0-9]{2}z") , 2, 3))

hrrr_times <- paste(yr, month, day, hour, sep = "_")

hrrr_times <- lubridate::ymd_h(hrrr_times)
return(hrrr_times)

}#end func parse_modis_hrrr_times 

#' parse_stilt_times  
#'  
#' @param hrrr_filenames (chr): hrrr modis filenames to extract date times from 
#' 
#' @export
parse_stilt_times <- function(stilt_filenames){
yy <- (stringr::str_extract_all(stilt_filenames,"[0-9]{12}", simplify = T)) 
### wtf cant lubridate parse 
stilt_times <- lubridate::ymd_hm(
	paste(
	substring(yy, 1,4)
	, substring(yy, 5,6)
	, substring(yy, 7,8)
	, substring(yy, 9,10)
	, substring(yy, 11,12)
	, sep = "_")
)#end ymd_hms
return(stilt_times)
}#end func parse stilt
