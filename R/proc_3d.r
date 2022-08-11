#' proc_3d 
#' Convert 3d data to match crs and extent to template
#'
#' @param driver (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for data file to be processed
#' @param plate (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for vpRm template
#' @param strict_times (bool): Must every time in the vpRm template exist in the driver data?
#' 
#' @export
proc_3d <- function(driver, plate, strict_times = T){
### touch driver data 
processed <- sanitize_raster(driver)
### touch plate
plate <- sanitize_raster(plate)
# browser()
### check that the driver covers the times we need
### "number of times in plate that arent in driver is not zero
### TODO: test strict times behavior
if( length(which(!terra::time(plate) %in% terra::time(processed))) != 0 ){
	### but only if when we want to check
	if(strict_times){
		### TODO: error should spec which driver
		stop("There are times in plate that are not in driver")
	}#end if(strict_times){

	### otherwise, match to closest
	if(is.null(terra::time(processed))){
		stop("driver must have times")
	}#end if

	### for an inexplicable reason, upgrading to terra 1.6.3 makes this projecting multiple layers of evi   
	### not work (sloooow and GDAL error about bands>1.  also even like this doesnt work if it has been indexed
	processed <- terra::rast(lapply(processed, function(pp){
		return( terra::project(pp, plate, method = "cubicspline") )
	})#end lapply
	)#end rast

	### stepwise time interpolation
	### get the index to the driver day of year closest to each plate doy  
	### TODO: w yday, only works for missing data w less granularity the 24h switch to hour_year or smth
	idx <- findInterval(lubridate::yday(terra::time(plate)),vec = lubridate::yday(terra::time(processed)))
	### i think this is right? because otherwise you can get 0 which is no good
	idx <- idx + 1
	### a terra update to 1.6.3  made indexing with the class num idx ^^^ produce an esoteric 
	idx <- as.integer(idx)
	### changes the nlyr(driver) to match nlyr(plate), taking the correct index
	processed <- processed[[idx]]	
	#         idx <-sapply(1:terra::nlyr(processed), function(ii){return(length(idx[idx==pp]))})
	### driver the same times as the plate, now that its "interpolate" 
	terra::time(processed) <- terra::time(plate)


	### TODO: for GOES, nan is hopefully only at night.  hopefully RAP/hrrr has no nans? 
	terra::values(processed)[ is.nan(terra::values(processed)) ] <- 0

	return(processed)

}#end if(length(which( terra::time(plate) %in% terra::time(driver))) != 0){

### only take the times we need
### wont have an effect if we did the "interpolation" ^^^
processed <- processed[[terra::time(processed) %in% terra::time(plate)]]

### reproject
### TODO: for some reason this ___ w evi gives:
# processed <- terra::project(processed, plate, method = "cubicspline")
### AdviseRead(): nBandCount cannot be greater than 1 (GDAL error 5)
### it wasn't the class of the index either? any project() of multi layer? but only EVI?
### is it the driver data? or is it the "interpolation"? Who knows?
processed <- terra::rast(lapply(processed, function(pp){
	return( terra::project(pp, plate, method = "cubicspline") )
})#end lapply
)#end rast
	
### TODO: for GOES, nan is hopefully only at night.  hopefully RAP/hrrr has no nans? 
terra::values(processed)[ is.nan(terra::values(processed)) ] <- 0

return(processed)

}#end func proc_par
