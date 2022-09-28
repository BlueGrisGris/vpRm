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
### TODO: ".nc" is a stop gap
LC <- terra::rast(vpRm$dirs$lc_proc_dir)
ISA <- terra::rast(vpRm$dirs$isa_proc_dir)

### TODO: make it a function and add it to a checker function?
# if( any(dim(LC) != c(dim(plate)[1:2], 1) )){stop(paste("dim lc_proc =", dim(LC), " does not align dim plate =", dim(plate)))}
# if( any(dim(ISA) != c(dim(plate)[1:2], 1) )){stop(paste("dim isa_proc =", dim(ISA), " does not align dim plate =", dim(plate)))}

#############################################
### collate vprm paramters
#############################################

### TODO: Check for LC codes not in params

vprm_params <- vpRm$vprm_params

lambda <- sum( (LC == vprm_params[,"lc"])*vprm_params[,"lambda"] )

Tmin <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"Tmin"] )
Tmax <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"Tmax"] )

PAR0 <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"PAR0"] )

ALPHA <- sum( (LC == vprm_params[,"lc"])*vprm_params[,"alpha"] )
BETA <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"beta"] )

### important landcodes for exclusion of processes
water_lc <- 18
evergreen_lc <- c(1,2,3)


### loop hourly
lapply(1:length(vpRm$domain$time), function(tt_idx){

	tt <- vpRm$domain$time[tt_idx]

	if(vpRm$verbose){print(tt)}

	### TODO: loading yearly data for each hour is 2 loads on top of 3 hourly loads inefficient 
	### To resolve, would have to save yearly data to a different environement.
	yy <- lubridate::year(tt)
	evi_extrema_dir_yy <- vpRm$dirs$evi_extrema_proc_files_dir[grep(yy, vpRm$dirs$evi_extrema_proc_files_dir)]

	vpRm$dirs$green_proc_files_dir
	green_dir_yy <- vpRm$dirs$green_proc_files_dir[grep(yy, vpRm$dirs$green_proc_files_dir)]

	EVIextrema <- terra::rast(evi_extrema_dir_yy)
	GREEN <- terra::rast(green_dir_yy)
	# if( any(dim(EVIextrema) != c(dim(plate)[1:2], 2) )){stop(paste("dim EVIextrema_proc =", dim(EVIextrema), " does not align dim plate =", dim(plate)))}
	# if( any(dim(GREEN) != c(dim(plate)[1:2], 2) )){stop(paste("dim green_proc =", dim(GREEN), " does not align dim plate =", dim(plate)))}

	TEMP <- terra::rast(vpRm$dirs$temp_proc_files_dir[tt_idx])
	PAR <- terra::rast(vpRm$dirs$par_proc_files_dir[tt_idx])
	EVI <- terra::rast(vpRm$dirs$evi_proc_files_dir[tt_idx])
	# if( any(dim(TEMP) != dim(plate)) ){stop(paste("dim temp_proc =", dim(TEMP), " does not match dim plate =", dim(plate)))}
	# if( any(dim(PAR) != dim(plate)) ){stop(paste("dim par_proc =", dim(PAR), " does not match dim plate =", dim(plate)))}
	# if( any(dim(evi) != dim(plate)) ){stop(paste("dim evi_proc =", dim(evi), " does not match dim plate =", dim(plate)))}


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

	### simplified Wscalar
	Wscalar <- Wscalar("fake_lswi", "fake_lswi")  

	#############################################
	### calculate gee
	#############################################
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

	terra::time(GEE) <- tt

	#############################################
	### calculate respiration
	#############################################

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

	terra::time(RESPIR) <- tt

	#############################################
	### calculate nee and save outputs
	#############################################

	### net ecosystem exchange
	NEE <- RESPIR - GEE
	names(NEE) <- "nee"
	terra::time(NEE) <- tt
	terra::units(NEE) <- "micromol CO2 m-2 s-1"

	### save output CO2 flux fields
	lapply(list(NEE, GEE, RESPIR), function(ff){
		
		       ### TODO: access +idx out files
		filename <- vpRm$dirs[[paste(names(ff), "files_dir", sep = "_")]][tt_idx]
		      	 
		terra::writeCDF(
				ff
				, filename = filename
				, varname = names(ff)
				, longname = paste(names(ff), "CO2 flux")
				, zname = "time"
				, unit = "micromol CO2 m-2 s-1"
				, overwrite = T
				, prec = "double"
		)#end writeCDF
		return(NULL)
	}) #end lapply

})#end lapply hours 

return(vpRm)

}#end func run_vpRm
