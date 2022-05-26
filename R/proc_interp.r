#' proc_interp
#' process driver data that must be interpolated to fit to the time points of the vpRm template
#' 
#' @param driver (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for  land cover data file to be processed
#' @param plate (Spat Raster or terra::SpatRaster): SpatRaster or filepath that can be input to terra::Rast for vpRm template
#'
#' @export
proc_interp <- function(driver, plate){
### touch driver data 
driver <- sanitize_raster(driver)
### touch plate
plate <- sanitize_raster(plate)

}#end func proc_interp
