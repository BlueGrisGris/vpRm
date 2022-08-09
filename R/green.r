#' green
#' Create a green up/down pair of rasters for use in masking gee to the growing season
#'
#' @param evi (SpatRaster): A full year's worth of EVI data
#' @param up_func (function): a function that takes an evi time series over a year and returns a boolean: is this pixel on this day past the greenup day? 
#' @param down_func (function): a function that takes an evi time series over a year and returns a boolean: is this pixel on this day before the greendown day? 
#'
#' @export
green <- function(evi
		  , up_func = function(evi){return( evi>(.5*max(evi)) )}
		  , down_func = function(evi){return( evi<(.65*max(evi)) )}
		  ){

	### TODO: error if not full year
	
	doy <- lubridate::yday(terra::time(evi))

	greenup <- up_func(evi)*doy
	greenup <- terra::mask(greenup, greenup, maskvalues = 0) 
	greenup <- min(greenup, na.rm = T)

	greendown <- down_func(evi)*doy
	greendown <- terra::mask(greendown, greendown, maskvalues = 0) 
	greendown <- max(greendown, na.rm = T)

	greenupdown <- c(greenup, greendown)
	names(greenupdown) <- c("greenup", "greendown")

	return(greenupdown)
}#end func green
