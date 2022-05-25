#' proc_simple_3d 
#' Convert 3d data to match crs and extent to template
#'
#' @param driver (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for  land cover data file to be processed
#' @param plate (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for vpRm template
#' 
#' @export
proc_simple_3d <- function(driver, plate){
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

### TODO: do the 3d processign

return(processed)

}#end func proc_par

