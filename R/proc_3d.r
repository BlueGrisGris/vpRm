#' proc_3d 
#' Convert 3d data to match crs and extent to template
#'
#' @param driver (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for data file to be processed
#' @param plate (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for vpRm template
#' @param strict_times (bool): Must every time in the vpRm template exist in the driver data?
#' @param times_driver (Date, chr): dates of driver if not parsable by terra::rast
#' 
#' @export
proc_3d <- function(driver, plate, strict_times = F, times_driver = NULL){
### touch driver data 
driver <- sanitize_raster(driver)
### touch plate
plate <- sanitize_raster(plate)

processed <- driver

### check that the driver covers the times we need
### TODO: test strict times behavior
### TODO: it is broken and zeroing drivers w missing times.
if(length(which(terra::time(plate) %in% terra::time(driver))) == 0){
	### but only if when we want to check
	if(strict_times){
		### TODO: error should spec which driver
		stop("There are times in plate that are not in driver")
	}#end if(strict_times){

	### otherwise, match to closest

	if(is.null(terra::time(driver))){
		if(is.null(times_driver)){
			stop("driver must have terra::rast parseable times, or times must be supplied")
		}#end if(is.null(times_driver)){
	}else{#end if(is.null(time(driver)) 
		times_driver <- terra::time(driver)
	}#end else

	### stepwise time interpolation
	idx <- findInterval(lubridate::yday(terra::time(plate)),vec = lubridate::yday(times_driver))
	driver <- driver[[idx]]	
	terra::time(driver) <- terra::time(plate)

}#end if(length(which( terra::time(plate) %in% terra::time(driver))) != 0){

# browser()
### only take the times we need
processed <- processed[[terra::time(driver) %in% terra::time(plate)]]


### TODO: this one is less likely to be always bigger than our domain
### reproject
processed <- terra::project(processed, plate, method = "cubicspline")
	
### TODO: for GOES, nan is hopefully only at night.  hopefully RAP/hrrr has no nans? 
terra::values(processed)[ is.nan(terra::values(processed)) ] <- 0

return(processed)

}#end func proc_par
