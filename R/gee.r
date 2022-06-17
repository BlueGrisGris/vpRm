### Mahadevan et 2008
gee <- function(lambda, Tscalar, Pscalar, Wscalar, EVI, PAR, PAR0, lc){
	### TODO: scale PAR appropriately
	GEE <-  (lambda * Tscalar * Pscalar * Wscalar * EVI * PAR )/( (1+PAR)/PAR0 )
	if(lc == "OTH"){
		GEE  <- 0
	}#end if(lc == "OTH"){
	return(GEE)
}#end func gee
