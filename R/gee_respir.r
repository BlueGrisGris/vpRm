## Mahadevan et al 2008
gee <- function(lambda, Tscalar, Pscalar, Wscalar, EVI, PAR, PAR0){

	gee <- (lambda * Tscalar * Pscalar * Wscalar * EVI * PAR )/ ( 1+(PAR/PAR0) )

	if(methods::is(gee ,"SpatRaster")){
		names(gee) <- "gee"
		terra::units(gee) <- rep("micromol CO2 m-2 s-1" , terra::nlyr(gee))
	}#end if class

	return(gee)
}#end func gee

### Winbourne et al 2021
respir <- function(tair, ALPHA, BETA, lc, ISA, evi, tlow){

	### soil respiration persists into cold winter when soils are insulated
	### Mahadevan 2008
	if(tair < tlow){tair <- tlow}

	respir_naive <- ALPHA * tair + BETA 

	respir_het <- .5 * respir_naive * (1-ISA)
	respir_aut <- .5 * respir_naive * evi  
	
	respir <- respir_het + respir_aut

	if(methods::is(respir, "SpatRaster")){
		names(respir) <- rep("respir", terra::nlyr(respir))
		terra::units(respir) <- rep("micromol CO2 m-2 s-1" , terra::nlyr(respir))
	}#end if class
	
	return(respir)
}#end func respir
