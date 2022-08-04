#' proc_3d 
#' Convert 3d data to match crs and extent to template
#'
#' @param driver (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for data file to be processed
#' @param plate (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for vpRm template
#' @param strict_times (bool): Must every time in the vpRm template exist in the driver data?
#' 
#' @export
proc_3d <- function(driver, plate, strict_times = F){
### touch driver data 
processed <- sanitize_raster(driver)
### touch plate
plate <- sanitize_raster(plate)

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

	if(is.null(terra::time(processed))){
		stop("driver must have times")
	}#end if

	### stepwise time interpolation
	### get the index to the driver day of year closest to each plate doy  
	### TODO: w yday, only works for missing data w less granularity the 24h switch to hour_year or smth
	idx <- findInterval(lubridate::yday(terra::time(plate)),vec = lubridate::yday(terra::time(processed)))
	### i think this is right? because otherwise you can get 0 which is no good
	idx <- idx + 1
	### changes the nlyr(driver) to match nlyr(plate), taking the correct index
	processed <- processed[[idx]]	
	### driver the same times as the plate, now that its "interpolate" 
	terra::time(processed) <- terra::time(plate)

}#end if(length(which( terra::time(plate) %in% terra::time(driver))) != 0){

### only take the times we need
### wont have an effect if we did the "interpolation" ^^^
processed <- processed[[terra::time(processed) %in% terra::time(plate)]]

### reproject
### TODO: for some reason this ___ w evi gives:
processed <- terra::project(processed, plate, method = "cubicspline")
### AdviseRead(): nBandCount cannot be greater than 1 (GDAL error 5)
### the change that caused this was swapping out "processed" for "driver" (used to have processed <- driver)
### this does not happen with 
# processed <- terra::project(processed, crs(plate), method = "cubicspline")
# processed <- terra::crop(processed, plate)
	
### TODO: for GOES, nan is hopefully only at night.  hopefully RAP/hrrr has no nans? 
terra::values(processed)[ is.nan(terra::values(processed)) ] <- 0

return(processed)

}#end func proc_par
