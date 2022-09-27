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

	####### create plate
	plate <- terra::rast(
		crs = vpRm$domain$crs
		extent = vpRm$domain$ext
		resolution = vpRm$domain$res
	)#end terra::rast

	terra::values(plate) <- 1:ncell(plate)

	####### loop
	sapply(vpRm$domain$time, function(tt){

	terra::time(plate) <- tt

	####### TODO: get directories of driver data
	temp_dir_tt <- parse_herbie_hrrr_times(vpRm$dirs$temp_dir)[tt = parse_herbie_hrrr_times(vpRm$dirs$temp_dir)]
	dswrf_dir_tt <- parse_herbie_hrrr_times(vpRm$dirs$dswrf_dir)[tt = parse_herbie_hrrr_times(vpRm$dirs$dswrf_dir)]

	### TODO: only process evi when you have to
	evi_dir_tt <- parse_modis_evi_times(vpRm$dirs$evi_dir)[tt == parse_modis_evi_times(vpRm$dirs$evi_dir)]

	####### process landcover
	if(vpRm$verbose){print("start process landcover")}
	lc <- terra::rast(vpRm$dirs$lc_dir)
	lc_proc <- proc_2d(lc,plate)
	Save_Rast(lc_proc, vpRm$dirs$lc_proc_dir)

	####### process isa
	if(vpRm$verbose){print("start process impermeability")}
	isa <- terra::rast(vpRm$dirs$isa_dir)
	isa_proc <- proc_2d(isa,plate)
	### isa should be a fraction, 125 is ocean NA code
	isa_proc <- isa_proc/100
	isa_proc <- terra::mask(isa_proc, isa_proc<1, maskvalues = 0)
	Save_Rast(isa_proc, vpRm$dirs$isa_proc_dir)
	rm(isa, isa_proc)

	####### process temp
	if(vpRm$verbose){print("start process temperature")}
	temp <- terra::rast(vpRm$dirs$temp_dir)
	terra::time(temp) <- vpRm$times$temp_time
	temp_proc <- proc_3d(temp,plate)
	Save_Rast(temp_proc, vpRm$dirs$temp_proc_dir)
	rm(temp, temp_proc)

	####### process dswrf to par
	if(vpRm$verbose){print("start process PAR")}
	dswrf <- terra::rast(vpRm$dirs$dswrf_dir)
	terra::time(dswrf) <- vpRm$times$dswrf_time
	### Mahadevan 2008 factor to convert DSWRF to PAR
	par_proc <- proc_3d(dswrf,plate)/.505
	Save_Rast(par_proc, vpRm$dirs$par_proc_dir)
	rm(dswrf, par_proc)

	####### process evi
	evi_scale_factor <- 1e-4

	### TODO: check that evi \in {-1,1}
	if(vpRm$verbose){print("start process evi")}
	EVI <- terra::rast(vpRm$dirs$evi_dir)
	terra::time(EVI) <- vpRm$times$evi_time
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
	Save_Rast(green_proc, vpRm$dirs$green_proc_dir)
	rm(green_proc)

	rm(evi, EVI_proc)

	### TODO: CHECK ALL DIMENSIONS

	})#end sapply

	return(vpRm)
}#end func process.vpRm
