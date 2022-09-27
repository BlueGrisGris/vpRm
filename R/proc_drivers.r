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
		, extent = vpRm$domain$ext
		, resolution = vpRm$domain$res
	)#end terra::rast

	terra::values(plate) <- 1:ncell(plate)

	####### scale factors
	evi_scale_factor <- 1e-4
	par_scale_factor <- 1/.505

	####### process landcover
	lc <- terra::rast(vpRm$dirs$lc_dir)
	terra::project(lc,plate, method = "near", filename = vpRm$dirs$lc_proc_dir)

	####### process isa
	ISA <- terra::rast(vpRm$dirs$isa_dir)
	isa_proc <- terra::project(ISA,plate, method = "near")
	### isa should be a fraction, 125 is ocean NA code
	isa_proc <- isa_proc/100
	isa_proc <- terra::mask(isa_proc, isa_proc<1, maskvalues = 0)
	### rudimentary add canada imperviousness
	urban_lc <- 17
	urban_factor <- .25*(lc_proc==urban_lc)
	urban_factor_canada <- terra::mask(urban_factor, is.na(isa_proc),maskvalues = F)
	isa_proc <- sum(isa_proc, urban_factor_canada, na.rm = T)
	### save processed isa	
	Save_Rast(isa_proc, vpRm$dirs$isa_proc_dir)
	rm(ISA, isa_proc)

	####### process evi extrema
	evi_extrema <- terra::rast(vpRm$dirs$evi_extrema_dir)
	evi_extrema_proc <- terra::project(evi_extrema,plate, method = "cubicspline")
	evi_extrema_proc <- evi_extrema_proc*evi_scale_factor
	Save_Rast(evi_extrema_proc, vpRm$dirs$evi_extrema_proc_dir)
	rm(evi_extrema, evi_extrema_proc)

	####### process green
	green <- terra::rast(vpRm$dirs$green_dir)
	green_proc <- terra::project(green,plate, method = "cubicspline")
	Save_Rast(green_proc, vpRm$dirs$green_proc_dir)
	rm(green, green_proc)

	####### loop through hourly driver data
	sapply(vpRm$domain$time, function(tt){
		if(vpRm$verbose){print(tt)}
		terra::time(plate) <- tt

		####### TODO: get directories of driver data
		temp_dir_tt <- parse_herbie_hrrr_times(vpRm$dirs$temp_dir)[tt = parse_herbie_hrrr_times(vpRm$dirs$temp_dir)]
		dswrf_dir_tt <- parse_herbie_hrrr_times(vpRm$dirs$dswrf_dir)[tt = parse_herbie_hrrr_times(vpRm$dirs$dswrf_dir)]

		### TODO: only process evi when you have to
		evi_dir_tt <- parse_modis_evi_times(vpRm$dirs$evi_dir)[tt == parse_modis_evi_times(vpRm$dirs$evi_dir)]

		####### process temp
		temp <- terra::rast(temp_dir_tt)
		temp_proc <- terra::project(temp,plate, method = "cubicspline", filename = vpRm$dirs$temp_proc_dir)
		rm(temp, temp_proc)

		####### process dswrf to par
		dswrf <- terra::rast(dswrf_dir_tt)
		### Mahadevan 2008 factor to convert DSWRF to PAR
		par_proc <- terra::project(dswrf,plate, method = "cubicspline")*par_scale_factor
		Save_Rast(par_proc, vpRm$dirs$par_proc_dir)
		rm(dswrf, par_proc)

		####### process evi
		EVI <- terra::rast(vpRm$dirs$evi_dir)
		EVI_proc <- terra::project(EVI,plate, method = "cubicspline")*evi_scale_factor
		Save_Rast(EVI_proc, vpRm$dirs$evi_proc_dir)

		return(NULL)
	})#end sapply

	return(vpRm)
}#end func process.vpRm
