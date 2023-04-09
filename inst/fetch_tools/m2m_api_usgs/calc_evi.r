calc_evi <- function(scene, mission){
	if(!mission %in% c("etm", "oli")){stop("mission must be one of etm, oli")} 
	### apply landsat collection 2 surface reflectance scale factor
	### https://www.usgs.gov/faqs/how-do-i-use-scale-factor-landsat-level-2-science-products
	scene <- scene * 0.0000275  - .2
	if(mission == "etm"){
		evi <- 2.5*( (scene["sr_b4"] - scene["sr_b3"])/(scene["sr_b4"] + 6 * scene["sr_b3"] - 7.5*scene["sr_b1"] + 1) )
		evi[evi < -1] <- -1
	       	evi[evi > 1] <- 1
		names(evi) <- "EVI"
		return(evi)
	}#end if 
	if(mission == "oli"){
		evi <- 2.5*( (scene["sr_b5"] - scene["sr_b4"])/(scene["sr_b5"] + 6 * scene["sr_b4"] - 7.5*scene["sr_b2"] + 1) )
		evi[evi < -1] <- -1
	       	evi[evi > 1] <- 1
		names(evi) <- "EVI"
		return(evi)
	}#end if 
}#end func calc_evi
