#' run_vpRm
#' Run a VPRM model defined by a vpRm object
#' 
#' Execute the "model" calculations defined in Mahadevan et al 2008 and Winbourne et al 2021.  Processes the driver data attached to the vpRm object with a call to proc_drivers(). 
#' 
#' @param vpRm (vpRm): a vpRm S3 object with attached driver data 
#' @return vpRm (vpRm): the same vpRm object, now with attached gee, respiration and nee netcdf files. 
#' @export
run_vpRm <- function(vpRm){

if(class(vpRm) != "vpRm"){stop("must be an object of class vpRm")}



#############################################
### point to processed drivers
#############################################

### time invariant 
LC <- terra::rast(vpRm$dirs$lc_proc_dir)
ISA <- terra::rast(vpRm$dirs$isa_proc_dir)

### TODO: make it a function and add it to a checker function?
# if( any(dim(LC) != c(dim(plate)[1:2], 1) )){stop(paste("dim lc_proc =", dim(LC), " does not align dim plate =", dim(plate)))}
# if( any(dim(ISA) != c(dim(plate)[1:2], 1) )){stop(paste("dim isa_proc =", dim(ISA), " does not align dim plate =", dim(plate)))}

### per year
### TODO: grep by year(time)
EVIextrema <- terra::rast(vpRm$dirs$evi_extrema_proc_dir)
GREEN <- terra::rast(vpRm$dirs$green_proc_dir)
# if( any(dim(EVIextrema) != c(dim(plate)[1:2], 2) )){stop(paste("dim EVIextrema_proc =", dim(EVIextrema), " does not align dim plate =", dim(plate)))}
# if( any(dim(GREEN) != c(dim(plate)[1:2], 2) )){stop(paste("dim green_proc =", dim(GREEN), " does not align dim plate =", dim(plate)))}

### loop hourly
lapply(vpRm$domain$time, function(tt){
	if(vpRm$verbose){print(tt)}

	### TODO: correct filenames ttt

	### vary hourly or "interpolated" as such
	TEMP <- terra::rast(vpRm$dirs$temp_proc_dir)
	PAR <- terra::rast(vpRm$dirs$par_proc_dir)
	EVI <- terra::rast(vpRm$dirs$evi_proc_dir)
	# if( any(dim(TEMP) != dim(plate)) ){stop(paste("dim temp_proc =", dim(TEMP), " does not match dim plate =", dim(plate)))}
	# if( any(dim(PAR) != dim(plate)) ){stop(paste("dim par_proc =", dim(PAR), " does not match dim plate =", dim(plate)))}
	# if( any(dim(evi) != dim(plate)) ){stop(paste("dim evi_proc =", dim(evi), " does not match dim plate =", dim(plate)))}

	#############################################
	### collate vprm paramters
	#############################################

	### TODO: Check for LC codes not in params

	vprm_params <- vpRm$params

	lambda <- sum( (LC == vprm_params[,"lc"])*vprm_params[,"lambda"] )

	Tmin <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"Tmin"] )
	Tmax <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"Tmax"] )

	PAR0 <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"PAR0"] )

	ALPHA <- sum( (LC == vprm_params[,"lc"])*vprm_params[,"alpha"] )
	BETA <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"beta"] )

	### important landcodes for exclusion of processes
	water_lc <- 18
	evergreen_lc <- c(1,2,3)

	#############################################
	### calculate scalars
	#############################################

	### simplified Tscalar
	Tscalar <- Tscalar(TEMP, Tmin, Tmax)

	### calculate Pscalar
	EVImax <- EVIextrema[[1]]
	EVImin <- EVIextrema[[2]]

	Pscalar <- Pscalar(EVI, EVImax, EVImin) 
	### phenology of evergreens is always max
	Pscalar[sum(LC == evergreen_lc)] <- 1
	Pscalar[Pscalar < 0] <- 0 
	Pscalar[Pscalar > 1] <- 1 

	### simplified Wscalar
	Wscalar <- Wscalar("fake_lswi", "fake_lswi")  

	#############################################
	### calculate gee
	#############################################

	if(vpRm$verbose){print("start calculate gee")}

	GEE <- gee(
		   lambda
		   , Tscalar
		   , Pscalar
		   , Wscalar
		   , EVI
		   , PAR
		   , PAR0
	)#end gee

	### Set gee to zero outside of growing season
	doy <- lubridate::yday(terra::time(GEE)) 
	green_mask <- (GREEN[[1]] < doy) & (GREEN[[2]] > doy)
	### but not for evergreen?
	green_mask[sum(LC == evergreen_lc)] <- 1
	GEE <- GEE*green_mask 

	### gee = zero where there is water
	GEE <- GEE * (LC!=water_lc)

	#############################################
	### calculate respiration
	#############################################

	if(vpRm$verbose){print("start calculate respiration")}

	RESPIR <- respir(
		TEMP
		, ALPHA
		, BETA
		, LC
		, ISA
		, EVI
	)#end respir

	### respir = zero where there is water
	RESPIR <- RESPIR * (LC!=water_lc)

	#############################################
	### calculate nee and save outputs
	#############################################

	### net ecosystem exchange
	NEE <- RESPIR - GEE
	names(NEE) <- rep("nee", terra::nlyr(NEE))

	### save output CO2 flux fields
	lapply(list(NEE, GEE, RESPIR), save_co2_field())

})#end lapply times 

return(vpRm)

}#end func run_vpRm
