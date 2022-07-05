#' proc_simple_3d 
#' Convert 3d data to match crs and extent to template
#'
#' @param driver (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for  land cover data file to be processed
#' @param plate (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for vpRm template
#' 
#' @export
proc_simple_3d <- function(driver, plate){
	### TODO: just make this piece proc_simple_2d()
### touch driver data 
driver <- sanitize_raster(driver)
### touch plate
plate <- sanitize_raster(plate)

### TODO: this one is less likely to be always bigger than our domain
### TODO: when we think about performance, these new SpatRaster that we make are stored in memory.....
### reproject
processed <- terra::project(driver, plate, method = "cubicspline") 
### check that the driver covers the times we need
if(length(which(terra::time(plate) %in% terra::time(driver))) == 0){
	stop("There are times in plate that are not in driver")
}#end if(length(which( terra::time(plate) %in% terra::time(driver))) != 0){

### only take the times we need
processed <- processed[[terra::time(driver) %in% terra::time(plate)]]
	
### TODO: for GOES, nan is hopefully only at night.  hopefully RAP/hrrr has no nans? 
terra::values(processed)[ is.nan(terra::values(processed)) ] <- 0

return(processed)

}#end func proc_par