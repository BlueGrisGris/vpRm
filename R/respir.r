### TODO: should this be evi scales?
respir <- function(tair, alpha, beta, lc, isa, evi){
	# respir_naive <- function(alpha, tair, beta){
	respir_naive <- alpha * tair + beta 
	#         return(respir_naive)
	# }#end func respir
	### TODO: ask Ian whats up with this madness
	respir_het <- .5 * respir_naive * (1-isa)
	respir_aut <- .5 * respir_naive * evi  
	
# respir_scaled <- function(respir_het, respir_aut, lc){
	respir <- respir_het + respir_aut
	if(lc == "OTH"){
		respir <- 0
	}#end if(lc == "OTH"){
	#         return(respir_scaled)
	# }#end func total repsir
	return(respir)
}#end func respir
