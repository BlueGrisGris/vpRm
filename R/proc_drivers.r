#' proc_drivers()
#' Process the driver data for a VPRM model
#'
#' @param vpRm (vpRm) a vpRm object 
#' @param n_cores (int): number of cores for parallel processing. vpRm only parallellizes over hourly times, not over spatial subsets
#'
#' @export
proc_drivers <- function(
	vpRm
	, n_cores = 1
	){ #end parameters

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
	Save_Rast(lc_proc, vpRm$dirs$lc_proc_dir)

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

	####### loop through yearly driver data
	lapply(unique(lubridate::year(vpRm$domain$time)), function(yy){

		####### process evi extrema
		evi_extrema <- terra::rast(vpRm$dirs$evi_extrema_files_dir)
		evi_extrema_proc <- terra::project(evi_extrema,plate, method = "cubicspline")
		#                 evi_extrema_proc <- evi_extrema_proc*evi_scale_factor
		Save_Rast(evi_extrema_proc, file.path(vpRm$dirs$evi_extrema_proc_dir, paste0(yy, ".nc")))
		rm(evi_extrema, evi_extrema_proc)

		####### process green
		GREEN <- terra::rast(vpRm$dirs$green_dir)
		green_proc <- terra::project(GREEN,plate, method = "cubicspline")
		Save_Rast(green_proc, file.path(vpRm$dirs$green_proc_dir, paste0(yy, ".nc")))
		rm(GREEN, green_proc)

		return(NULL)
	}) #end lapply yearly

	####### loop through hourly driver data
	parallel::mclapply(1:length(vpRm$domain$time), mc.cores = n_cores, function(tt_idx){

		tt <- vpRm$domain$time[tt_idx]

		if(vpRm$verbose){print(tt)}

		terra::time(plate) <- tt

		####### process temp
		temp_dir_tt <- vpRm$dirs$temp_dir[tt == parse_herbie_hrrr_times(vpRm$dirs$temp_dir)]
		temp_proc <- terra::rast(temp_dir_tt)
		temp_proc <- terra::project(temp_proc,plate, method = "cubicspline")
		Save_Rast(temp_proc, vpRm$dirs$temp_proc_files_dir[tt_idx])
		rm(temp_proc)

		####### process dswrf to par
		dswrf_dir_tt <- vpRm$dirs$dswrf_dir[tt == parse_herbie_hrrr_times(vpRm$dirs$dswrf_dir)]
		dswrf <- terra::rast(dswrf_dir_tt)
		### Mahadevan 2008 factor to convert DSWRF to PAR
		par_proc <- terra::project(dswrf,plate, method = "cubicspline")*par_scale_factor
		par_proc[par_proc < 0] <- 0
		Save_Rast(par_proc, vpRm$dirs$par_proc_files_dir[tt_idx])
		rm(dswrf, par_proc)

		####### process evi
		### TODO: only process evi when you have to
		### TODO: I think EVI is still slower than the others?
		### TODO: evi date alignment only need to happen once, but that is not the issue
		### TODO: maybe the missing domain slows it down? thats only difference i can see..
		date_evi <- parse_modis_evi_times(vpRm$dirs$evi_dir)
		date_domain <- vpRm$domain$time[tt_idx]
		idx <- findInterval(date_domain, vec = date_evi)
		evi_dir_tt <- vpRm$dirs$evi_dir[idx]

		EVI <- terra::rast(evi_dir_tt)
		EVI_proc <- terra::project(EVI,plate, method = "cubicspline")*evi_scale_factor
		Save_Rast(EVI_proc, vpRm$dirs$evi_proc_files_dir[tt_idx])
		rm(EVI, EVI_proc)

		return(NULL)
	})#end lapply hourly

	return(vpRm)
}#end func process.vpRm
