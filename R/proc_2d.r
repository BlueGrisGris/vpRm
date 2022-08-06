#' proc_2d
#' Convert 2d data to match crs and extent to template

#' @param driver (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for  land cover data file to be processed
#' @param plate (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for vpRm template

#' @export 
proc_2d <- function(driver, plate){
### touch driver data 
driver <- sanitize_raster(driver)
### touch plate
plate <- sanitize_raster(plate)

### TODO: right now domain will always be encompassed by LC, bc LC is CONUS.  This will not be the case forever.

### reproject then crop
### TODO: method = near is for land cover data. maybe make method an arg to proc_2d?

processed <- terra::project(driver, plate[[1]], method = "near") 
### it seems that reproject makes cropping uneccesary
# processed <- terra::crop(driver_proj,terra::ext(plate))

return(processed)

}#end func proc_lc
