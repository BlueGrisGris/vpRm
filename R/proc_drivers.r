#' proc_drivers()
#' Process the driver data for a VPRM model
#'
#' @param vpRm (vpRm) a vpRm object 
#' @export
proc_drivers <- function(vpRm){

	### TODO: stopif
	if(any(is.null(c(
		  vpRm$dirs$lc_dir
		, vpRm$dirs$isa_dir
		, vpRm$dirs$temp_dir
		, vpRm$dirs$dswrf_dir
		, vpRm$dirs$evi_dir
		, vpRm$dirs$evi_extrema_dir
		, vpRm$dirs$green_dir
	)))){
	       stop("all driver data directories must be provided")
	}#end if is null

	### TODO: check that domain exists

	####### create plate
	plate <- terra::rast(
		crs = vpRm$domain$crs
		, extent = vpRm$domain$ext
		, resolution = vpRm$domain$res
	)#end terra::rast

	terra::values(plate) <- 1:terra::ncell(plate)

	####### scale factors
	evi_scale_factor <- 1e-4
	par_scale_factor <- 1/.505

	####### process landcover
	lc <- terra::rast(vpRm$dirs$lc_dir)
	lc_proc <- terra::project(lc,plate, method = "near")
	Save_Rast(lc_proc, file.path(vpRm$dirs$lc_proc_dir))

	####### process isa
	ISA <- terra::rast(vpRm$dirs$isa_dir)
	isa_proc <- terra::project(ISA,plate, method = "cubicspline")
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

	### TODO: handle multiple years of evi extrema and green
	####### process evi extrema
	evi_extrema <- terra::rast(vpRm$dirs$evi_extrema_dir)
	evi_extrema_proc <- terra::project(evi_extrema,plate, method = "cubicspline")
	evi_extrema_proc <- evi_extrema_proc*evi_scale_factor
	Save_Rast(evi_extrema_proc
		, file.path(vpRm$dirs$evi_extrema_proc_dir, lubridate::year(terra::time(evi_extrema)[1]))
	)#end Save_Rast
	rm(evi_extrema, evi_extrema_proc)

	####### process green
	GREEN <- terra::rast(vpRm$dirs$green_dir)
	green_proc <- terra::project(GREEN,plate, method = "cubicspline")
	Save_Rast(green_proc
		, file.path(vpRm$dirs$green_proc_dir , lubridate::year(terra::time(GREEN))[1])
	)#end Save_Rast
	rm(GREEN, green_proc)

	####### loop through hourly driver data
	lapply(vpRm$domain$time, function(tt){
		if(vpRm$verbose){print(tt)}

		terra::time(plate) <- tt

		####### get directories of driver data
		filename <- paste(
			lubridate::year(tt)
			, stringr::str_pad(lubridate::month(tt),width = 2, pad = "0")
			, stringr::str_pad(lubridate::day(tt),width = 2, pad = "0")
			, stringr::str_pad(lubridate::hour(tt),width = 2, pad = "0")
			, stringr::str_pad(lubridate::minute(tt),width = 2, pad = "0")
			, sep = "_"
		)#end paste

		####### process temp
		temp_dir_tt <- vpRm$dirs$temp_dir[tt == parse_herbie_hrrr_times(vpRm$dirs$temp_dir)]
		temp <- terra::rast(temp_dir_tt)
		temp <- terra::project(temp,plate, method = "cubicspline")
		Save_Rast(temp, file.path(vpRm$dirs$temp_proc_dir, filename))
		rm(temp)

		####### process dswrf to par
		dswrf_dir_tt <- vpRm$dirs$dswrf_dir[tt == parse_herbie_hrrr_times(vpRm$dirs$dswrf_dir)]
		dswrf <- terra::rast(dswrf_dir_tt)
		### Mahadevan 2008 factor to convert DSWRF to PAR
		par_proc <- terra::project(dswrf,plate, method = "cubicspline")*par_scale_factor
		Save_Rast(par_proc, file.path(vpRm$dirs$par_proc_dir, filename))
		rm(dswrf, par_proc)

		####### process evi
		### TODO: only process evi when you have to
		doy_evi <- lubridate::yday(parse_modis_evi_times(vpRm$dirs$evi_dir))
		doy_domain <- lubridate::yday(tt)
		idx <- findInterval(doy_domain, vec = doy_evi)
		evi_dir_tt <- vpRm$dirs$evi_dir[idx]

		EVI <- terra::rast(evi_dir_tt)
		EVI_proc <- terra::project(EVI,plate, method = "cubicspline")*evi_scale_factor
		Save_Rast(EVI_proc, file.path(vpRm$dirs$evi_proc_dir, filename))

		return(NULL)
	})#end sapply

	return(vpRm)
}#end func process.vpRm
