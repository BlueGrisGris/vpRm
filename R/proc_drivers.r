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
	, overwrite_procd_data = F
	){ #end parameters
	### check the driver data
	driver_data_dirs <- list(
		  vpRm$dirs$lc_dir
		, vpRm$dirs$isa_dir
		, vpRm$dirs$temp_dir
		, vpRm$dirs$dswrf_dir
		, vpRm$dirs$evi_dir
		, vpRm$dirs$evi_extrema_dir
		, vpRm$dirs$green_dir
	)#end c()
	if(any(is.null(driver_data_dirs))){
	       stop("all driver data directories must be provided")
	}#end if is null
	lapply(driver_data_dirs, function(dd){
		       #                 if(!file.exists(dd)){stop(paste("driver data directory does not exists:", dd))}
		if(length(dd) == 0){stop(paste("driver data directory is empty:", dd))}
		return(NULL)
	})#end lapply

	### TODO: check that domain exists

	####### create plate
	plate <- terra::rast(
		crs = vpRm$domain$crs
		, extent = vpRm$domain$ext
		, resolution = vpRm$domain$res
	)#end terra::rast

	terra::values(plate) <- 1:terra::ncell(plate)

	####### scale factors
	### TODO: move to function input
	evi_scale_factor <- 1e-4
	par_scale_factor <- 1/.505

	### TODO: for now: dont rerun this for each slurm array job..
	if(F){
	if(vpRm$verbose){print("proc lc, isa")}
	if( !file.exists(vpRm$dirs$lc_proc_dir) |(overwrite_procd_data&file.exists(vpRm$dirs$lc_proc_dir))){
		####### process landcover
		lc <- terra::rast(vpRm$dirs$lc_dir)
		### TODO: switch to .tif
		lc_proc <- terra::project(lc,plate, method = "near")
		vpRm::Save_Rast(lc_proc, vpRm$dirs$lc_proc_dir)
	}#end if(vpRm$verbose){print("proc lc, isa")}
	####### process isa
	if( !file.exists(vpRm$dirs$isa_proc_dir) |(overwrite_procd_data&file.exists(vpRm$dirs$isa_proc_dir))){
		ISA <- terra::rast(vpRm$dirs$isa_dir)
		isa_proc <- terra::project(ISA,plate, method = "cubicspline")
		### isa should be a fraction, 125 is ocean NA code
		Save_Rast(isa_proc, vpRm$dirs$isa_proc_dir)
		rm(ISA, isa_proc)
	}#end if(vpRm$verbose){print("proc lc, isa")}
	gc()

	if(vpRm$verbose){print("proc yearly data")}
	####### loop through yearly driver data
	lapply(unique(lubridate::year(vpRm$domain$time)), function(yy){
		if(vpRm$verbose){print(paste("year:", yy))}
		####### process evi extrema
		evi_extrema_proc_filename <- file.path(vpRm$dirs$evi_extrema_proc_dir, paste0(yy, ".tif"))
		if( !file.exists(evi_extrema_proc_filename ) |(overwrite_procd_data&file.exists(evi_extrema_proc_filename ))){
			evi_extrema <- terra::rast(grep(vpRm$dirs$evi_extrema_dir, pattern = yy, value = T))
			evi_extrema_proc <- terra::project(evi_extrema,plate, method = "cubicspline", filename = evi_extrema_proc_filename, overwrite = T)
			#                 evi_extrema_proc <- evi_extrema_proc*evi_scale_factor
			rm(evi_extrema, evi_extrema_proc)
		}#end if( !file.exists(evi_extrema_proc_filename ) |(overwrite_procd_data&file.exists(evi_extrema_proc_filename ))){

		####### process green
		green_proc_filename <- file.path(vpRm$dirs$green_proc_dir, paste0(yy, ".tif"))
		if( !file.exists(green_proc_filename ) |(overwrite_procd_data&file.exists(green_proc_filename ))){
			GREEN <- terra::rast(grep(vpRm$dirs$green_dir, pattern = yy, value = T))
			green_proc <- terra::project(GREEN,plate, method = "cubicspline", filename = green_proc_filename, overwrite = T)
			rm(GREEN, green_proc)
		}#end if( !file.exists(evi_extrema_proc_filename ) |(overwrite_procd_data&file.exists(evi_extrema_proc_filename ))){
		gc()
		return(NULL)
	}) #end lapply yearly
	}#dnd if F

	if(vpRm$verbose){print("proc hourly data")}
	####### loop through hourly driver data
	parallel::mclapply(1:length(vpRm$domain$time), mc.cores = n_cores, function(tt_idx){

		tt <- vpRm$domain$time[tt_idx]

		if(vpRm$verbose){print(paste("hour:", tt))}

		terra::time(plate) <- tt

		### TODO: overwrite switching
		### TODO: variabel names, time, units
		####### process temp
		if( !file.exists(vpRm$dirs$temp_proc_files_dir[tt_idx]) |(overwrite_procd_data&file.exists(vpRm$dirs$temp_proc_files_dir[tt_idx]))){
			temp_dir_tt <- vpRm$dirs$temp_dir[tt == parse_herbie_hrrr_times(vpRm$dirs$temp_dir)]
			temp_proc <- terra::rast(temp_dir_tt)
			### TODO: hot fix bc the nc has no crs?? 
			crs(temp_proc) <- "+proj=lcc +lat_0=38.5 +lon_0=262.5 +lat_1=38.5 +lat_2=38.5 +x_0=0 +y_0=0 +R=6371229 +units=m +no_defs" 
			temp_proc <- terra::project(temp_proc,plate, method = "cubicspline", filename = )
			### TODO: replace Save_Rast w geotiff
			Save_Rast(temp_proc, vpRm$dirs$temp_proc_files_dir[tt_idx])
			rm(temp_proc)
		}#end if( !file.exists(evi_extrema_proc_filename ) |(overwrite_procd_data&file.exists(evi_extrema_proc_filename ))){

		####### process dswrf to par
		if( !file.exists(vpRm$dirs$par_proc_files_dir[tt_idx]) |(overwrite_procd_data&file.exists(vpRm$dirs$par_proc_files_dir[tt_idx]))){
			dswrf_dir_tt <- vpRm$dirs$dswrf_dir[tt == parse_herbie_hrrr_times(vpRm$dirs$dswrf_dir)]
			dswrf <- terra::rast(dswrf_dir_tt)
			### TODO: hot fix bc the nc has no crs?? 
			crs(dswrf) <- "+proj=lcc +lat_0=38.5 +lon_0=262.5 +lat_1=38.5 +lat_2=38.5 +x_0=0 +y_0=0 +R=6371229 +units=m +no_defs" 
			### Mahadevan 2008 factor to convert DSWRF to PAR
			par_proc <- terra::project(dswrf,plate, method = "cubicspline")*par_scale_factor
			par_proc[par_proc < 0] <- 0
			Save_Rast(par_proc, vpRm$dirs$par_proc_files_dir[tt_idx])
			rm(dswrf, par_proc)
		}#end if( !file.exists(evi_extrema_proc_filename ) |(overwrite_procd_data&file.exists(evi_extrema_proc_filename ))){

		####### process evi
		### TODO: only process evi when you have to
		### TODO: I think EVI is still slower than the others?
		### TODO: evi date alignment only need to happen once, but that is not the issue
		### TODO: maybe the missing domain slows it down? thats only difference i can see..
		if( !file.exists(vpRm$dirs$evi_proc_files_dir[tt_idx]) |(overwrite_procd_data&file.exists(vpRm$dirs$evi_proc_files_dir[tt_idx]))){
			date_evi <- parse_modis_evi_times(vpRm$dirs$evi_dir)
			date_domain <- vpRm$domain$time[tt_idx]
			idx <- findInterval(date_domain, vec = date_evi)
			evi_dir_tt <- vpRm$dirs$evi_dir[idx]
			EVI <- terra::rast(evi_dir_tt)
			EVI_proc <- terra::project(EVI,plate, method = "cubicspline")#*evi_scale_factor
			Save_Rast(EVI_proc, vpRm$dirs$evi_proc_files_dir[tt_idx])
			rm(EVI, EVI_proc)
		}#end if( !file.exists(evi_extrema_proc_filename ) |(overwrite_procd_data&file.exists(evi_extrema_proc_filename ))){
		gc()
		return(NULL)
	})#end lapply hourly

	return(vpRm)
}#end func process.vpRm
