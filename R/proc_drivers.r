### TODO: make an actual generic/method

#' proc_drivers.vpRm()
#' Process the driver data for a VPRM model
#' calls functions proc*
#'
#' @param vpRm (vpRm) a vpRm object 
#' @export
proc_drivers <- function(vpRm){

	### TODO: nicer error
	### TODO: stopif
	if(length(which(is.null(c(
				    vpRm$dirs$lc_dir
				  , vpRm$dirs$isa_dir
				  , vpRm$dirs$temp_dir
				  , vpRm$dirs$dswrf_dir
				  , vpRm$dirs$evi_dir
				  , vpRm$dirs$evi_extrema_dir
				  , vpRm$dirs$green_dir
				  )))) != 0 ){
	       stop("all driver data directories must be provided")
	}#end if length which

	if(!file.exists(vpRm$dirs$plate)){
	stop(paste(deparse(substitute(vpRM)), "does not have an associated template. use gen_plate()"))
	}#end if(!file.exists(vpRm$dirs$plate)){

	plate <- terra::rast(vpRm$dirs$plate)
	if(vpRm$verbose){Print_Info(plate)}

	####### process landcover
	if(vpRm$verbose){print("start process landcover")}
	lc <- terra::rast(vpRm$dirs$lc_dir)
	lc_proc <- proc_2d(lc,plate)

	Save_Rast(lc_proc, vpRm$dirs$lc_proc_dir)

	####### process isa
	isa <- terra::rast(vpRm$dirs$isa_dir)
	isa_proc <- proc_2d(isa,plate)
	### isa should be a fraction, 125 is ocean NA code
	isa_proc <- isa_proc/100
	isa_proc <- terra::mask(isa_proc, isa_proc<1, maskvalues = 0)
	### rudimentary add canada imperviousness
	urban_lc <- 17
	urban_factor <- .25*(lc_proc==urban_lc)
	urban_factor_canada <- terra::mask(urban_factor, is.na(isa_proc),maskvalues = F)
	isa_proc <- sum(isa_proc, urban_factor_canada, na.rm = T)
	
	Save_Rast(isa_proc, vpRm$dirs$isa_proc_dir)
	rm(isa, isa_proc)

	####### process temp
	temp <- terra::rast(vpRm$dirs$temp_dir)
	if(any(is.na(terra::time(temp)))){
		if(any(is.na(vpRm$times$temp_time))){stop("either driver data:temp or vpRm must supply time")}
		terra::time(temp) <- vpRm$times$temp_time
	}#end if(any(is.na(terra::time(temp)))){
	temp_proc <- proc_3d(temp,plate)
	Save_Rast(temp_proc, vpRm$dirs$temp_proc_dir)
	rm(temp, temp_proc)

	####### process dswrf to par
	if(vpRm$verbose){print("start process PAR")}
	dswrf <- terra::rast(vpRm$dirs$dswrf_dir)
	if(any(is.na(terra::time(dswrf)))){
		if(any(is.na(vpRm$times$dswrf_time))){stop("either driver data:dswrf or vpRm must supply time")}
		terra::time(dswrf) <- vpRm$times$dswrf_time
	}#end if(any(is.na(terra::time(temp)))){
	if(vpRm$verbose){Print_Info(dswrf)}
	### Mahadevan 2008 factor to convert DSWRF to PAR
	par_proc <- proc_3d(dswrf,plate)/.505
	if(vpRm$verbose){Print_Info(par_proc)}
	Save_Rast(par_proc, vpRm$dirs$par_proc_dir)
	rm(dswrf, par_proc)

	####### process evi
	evi_scale_factor <- 1e-4

	if(vpRm$verbose){print("start process evi")}
	EVI <- terra::rast(vpRm$dirs$evi_dir)
	#         if(terra::time(EVI))
	if(any(is.na(terra::time(EVI)))){
		if(any(is.na(vpRm$times$evi_time))){stop("either driver data:evi or vpRm must supply time")}
		terra::time(EVI) <- vpRm$times$evi_time
	}#end if(any(is.na(terra::time(evi)))){
	EVI_proc <- proc_3d(EVI,plate, strict_times = F)
	EVI_proc <- EVI_proc*evi_scale_factor
	### mask out water which would ruin extrema
	EVI_proc <- terra::mask(EVI_proc, lc_proc, maskvalues = 11)
	Save_Rast(EVI_proc, vpRm$dirs$evi_proc_dir)

	####### process evi extrema
	### TODO: if it alrdy exists dont rerun?
	if(vpRm$verbose){print("start process evi extrema")}
	if(is.null(vpRm$dirs$evi_extrema_dir)){
		### TODO: if there are times in plate in any year, that whole year must be present or error
		### TODO: TODO: NOT HAVING THIS STOP() IMPLEMENTED RESULTED IN US HUNTING A BUG FOR HOURS>>>>
		#                 if{
		#                 }#end 
		evi_extrema_proc <- c(max(EVI_proc, na.rm = T), min(EVI_proc, na.rm = T))
	}else{
		evi_extrema <- terra::rast(vpRm$dirs$evi_extrema_dir)
		evi_extrema_proc <- proc_2d(evi_extrema,plate)
		evi_extrema_proc <- evi_extrema_proc*evi_scale_factor
	} #end else
	if(vpRm$verbose){Print_Info(evi_extrema_proc)}
	Save_Rast(evi_extrema_proc, vpRm$dirs$evi_extrema_proc_dir)
	rm(evi_extrema_proc)

	####### process green
	if(vpRm$verbose){print("start process green")}
	if(is.null(vpRm$dirs$green_dir)){
		### TODO: if there are times in plate in any year, that whole year evi must be present or error
		### TODO: TODO: NOT HAVING THIS STOP() IMPLEMENTED RESULTED IN US HUNTING A BUG FOR HOURS>>>>
		#                 if{
		#                 }#end 
		green_proc <- green(EVI_proc)
	}else{
		green <- terra::rast(vpRm$dirs$green_dir)
		green_proc <- proc_2d(green,plate)
	} #end else
	if(vpRm$verbose){Print_Info(green_proc)}
	Save_Rast(green_proc, vpRm$dirs$green_proc_dir)

	rm(green_proc)
	rm(EVI, EVI_proc)

	### TODO: CHECK ALL DIMENSIONS

	return(vpRm)
}#end func process.vpRm
