
### Mahadevan et al 2008
gee <- function(lambda, Tscalar, Pscalar, Wscalar, EVI, PAR, PAR0){

	gee <- (lambda * Tscalar * Pscalar * Wscalar * EVI * PAR )/ ( 1+(PAR/PAR0) )

	if(class(respir) == "SpatRaster"){
		names(gee) <- rep("gee", terra::nlyr(gee))
		terra::units(gee) <- rep("micromol CO2 m-2 s-1" , terra::nlyr(gee))
	}#end if class

	return(gee)
}#end func gee

### Winbourne et al 2021
respir <- function(tair, alpha, beta, lc, isa, evi){

	respir_naive <- alpha * tair + beta 

	### TODO: ask Ian whats up with this madness
	respir_het <- .5 * respir_naive * (1-isa)
	respir_aut <- .5 * respir_naive * evi  
	
	respir <- respir_het + respir_aut

	if(class(respir) == "SpatRaster"){
		names(respir) <- rep("respir", terra::nlyr(respir))
		terra::units(respir) <- rep("micromol CO2 m-2 s-1" , terra::nlyr(respir))
	}#end if class
	
	return(respir)
}#end func respir
