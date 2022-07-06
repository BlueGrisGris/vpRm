green <- function(evi
		  , up_func = function(evi){evi>.85}  
		  , down_func = function(evi){evi<.60}  
		  ){

	greenup <- ((up_func(evi)*max(evi))*doy)
	greenup[greenup <= 0] <- NA
	greenup <- min(greenup, na.rm = T)

	greendown <- ((down_func(evi)*max(evi))*doy)
	greendown[greendown <= 0] <- NA
	greendown <- max(greendown, na.rm = T)

	greenupdown <- c(greenup, greendown)

	return(greenupdown)
}#end func green
