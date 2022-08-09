
### Mahadevan et al 2008
gee <- function(lambda, Tscalar, Pscalar, Wscalar, EVI, PAR, PAR0){

	gee <- (lambda * Tscalar * Pscalar * Wscalar * EVI * PAR )/ ( 1+(PAR/PAR0) )

	names(gee) <- "gee"
	terra::units(gee) <- "micromol CO2 m-2 s-1" 

	return(gee)
}#end func gee

### Winbourne et al 2021
respir <- function(tair, alpha, beta, lc, isa, evi){

	respir_naive <- alpha * tair + beta 

	### TODO: ask Ian whats up with this madness
	respir_het <- .5 * respir_naive * (1-isa)
	respir_aut <- .5 * respir_naive * evi  
	
	respir <- respir_het + respir_aut

	names(respir) <- "respir"
	terra::units(respir) <- "micromol CO2 m-2 s-1" 
	
	return(respir)
}#end func respir
