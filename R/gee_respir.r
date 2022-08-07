### Mahadevan et 2008
gee <- function(lambda, Tscalar, Pscalar, Wscalar, EVI, PAR, PAR0){

	GEE <- (lambda * Tscalar * Pscalar * Wscalar * EVI * PAR )/ ( (1+PAR)/PAR0 )

	return(GEE)
}#end func gee

### TODO: should this be evi scales?
respir <- function(tair, alpha, beta, lc, isa, evi){
	# respir_naive <- function(alpha, tair, beta){
	respir_naive <- alpha * tair + beta 
	#         return(respir_naive)
	# }#end func respir
	### TODO: ask Ian whats up with this madness
	respir_het <- .5 * respir_naive * (1-isa)
	respir_aut <- .5 * respir_naive * evi  
	
	respir <- respir_het + respir_aut

	return(respir)
}#end func respir
