
### Mahadevan et al 2008
gee <- function(lambda, Tscalar, Pscalar, Wscalar, EVI, PAR, PAR0){

	GEE <- (lambda * Tscalar * Pscalar * Wscalar * EVI * PAR )/ ( 1+(PAR/PAR0) )

	return(GEE)
}#end func gee

### Winbourne et al 2021
respir <- function(tair, alpha, beta, lc, isa, evi){

	respir_naive <- alpha * tair + beta 

	### TODO: ask Ian whats up with this madness
	respir_het <- .5 * respir_naive * (1-isa)
	respir_aut <- .5 * respir_naive * evi  
	
	respir <- respir_het + respir_aut

	terra::names(respir) <- "respir"
	return(respir)
}#end func respir
