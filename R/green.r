green <- function(evi
		  , up_func = function(evi){return( evi>(.85*max(evi)) )}
		  , down_func = function(evi){return( evi<(.85*max(evi)) )}
		  ){
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
