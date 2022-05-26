#' proc_simple_2d
#' Convert 2d data to match crs and extent to template

#' @param driver (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for  land cover data file to be processed
#' @param plate (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for vpRm template

#' @export 
proc_simple_2d <- function(driver, plate){

print(length(which(!is.nan(terra::values(driver)))))
print("################")
print(class(driver))
print(class(plate))

### touch lc driver data 
if(!class(driver)[[1]] != "SpatRaster"){
	if(!class(driver)[[1]] != "character"){
		stop("data to be processed must be either a terra::rasted land cover or a filepath to such")
	}#end if(!class(driver)[[1]] != c){
	driver <- terra::rast(driver)
}#end if(class(driver)[[1]]{
### touch plate
if(!class(plate)[[1]] != "SpatRaster"){
	if(!class(plate)[[1]] != "character"){
		stop("plate must be either a terra::rasted vpRm template or a filepath to such")
	}#end if(!class(driver)[[1]] != c){
	plate <- terra::rast(plate)
}#end if(class(driver)[[1]]{

### TODO: right now domain will always be encompassed by LC, bc LC is CONUS.  This will not be the case forever.

print(length(which(!is.nan(terra::values(driver)))))
print("################")
### TODO: think about the performance of this processing as an excercise
### reproject then crop
### TODO: method = near is for land cover data. maybe make method an arg to proc_simple_2d?
processed <- terra::project(driver, plate, method = "near") 
### it seems that reproject makes cropping uneccesary
# processed <- terra::crop(driver_proj,terra::ext(plate))

print(length(which(!is.nan(terra::values(processed)))))
print("################")

return(processed)

}#end func proc_lc


proc_lc <- proc_simple_2d(driver,plate)
