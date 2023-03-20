calc_evi <- function(scene, mission){
	if(!mission %in% c("etm", "oli")){stop("mission must be one of etm, oli")} 
	if(mission == "etm"){
		evi <- 2.5*( (1e-4*scene["sr_b4"] - 1e-4*scene["sr_b3"])/(1e-4*scene["sr_b4"] + 6 * 1e-4*scene["sr_b3"] - 7.5*1e-4*scene["sr_b1"] + 1) )
		evi[evi < -1 | evi > 1] <- NA
		names(evi) <- "EVI"
		return(evi)
	}#end if 
	if(mission == "oli"){
		evi <- 2.5*( (1e-4*scene["sr_b5"] - 1e-4*scene["sr_b4"])/(1e-4*scene["sr_b5"] + 6 * 1e-4*scene["sr_b4"] - 7.5*1e-4*scene["sr_b2"] + 1) )
		evi[evi < -1 | evi > 1] <- NA
		names(evi) <- "EVI"
		return(evi)
	}#end if 
}#end func calc_evi
