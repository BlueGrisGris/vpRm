### TODO: make an actual generic/method

#' proc_drivers.vpRm()
#' Process the driver data for a VPRM model
#' calls functions proc*
#'
#' @param vpRm (vpRm) a vpRm object 
#' @export
proc_drivers.vpRm <- function(vpRm){

	### TODO: nicer error
	if(length(which(is.null(c(
				    vpRm$dirs$lc_dir
				  , vpRm$dirs$isa_dir
				  , vpRm$dirs$temp_dir
				  , vpRm$dirs$par_dir
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
	if(vpRm$verbose){Print_Info(lc)}
	lc_proc <- proc_2d(lc,plate)
	if(vpRm$verbose){Print_Info(lc_proc)}
	Save_Rast(lc_proc, vpRm$dirs$lc_proc_dir)

	####### process isa
	if(vpRm$verbose){print("start process impermeability")}
	isa <- terra::rast(vpRm$dirs$isa_dir)
	if(vpRm$verbose){Print_Info(isa)}
	isa_proc <- proc_2d(isa,plate)
	if(vpRm$verbose){Print_Info(isa_proc)}
	Save_Rast(isa_proc, vpRm$dirs$isa_proc_dir)
	rm(isa, isa_proc)
	####### process temp
	if(vpRm$verbose){print("start process temperature")}
	temp <- terra::rast(vpRm$dirs$temp_dir)
	terra::time(temp) <- parse_herbie_hrrr_times(vpRm$dirs$temp_dir)
	if(vpRm$verbose){Print_Info(temp)}
	temp_proc <- proc_3d(temp,plate, temp_times)
	if(vpRm$verbose){Print_Info(temp_proc)}
	Save_Rast(temp_proc, vpRm$dirs$temp_proc_dir)
	rm(temp, temp_proc)

	####### process par
	if(vpRm$verbose){print("start process PAR")}
	par <- terra::rast(vpRm$dirs$par_dir)
	terra::time(par) <- parse_herbie_hrrr_times(vpRm$dirs$par_dir)
	if(vpRm$verbose){Print_Info(temp)}
	if(vpRm$verbose){Print_Info(par)}
	par_proc <- proc_3d(par,plate)
	if(vpRm$verbose){Print_Info(par_proc)}
	Save_Rast(par_proc, vpRm$dirs$par_proc_dir)
	rm(par, par_proc)

	####### process evi
	evi_scale_factor <- 1e-5

	### TODO: check that evi \in {-1,1}
	if(vpRm$verbose){print("start process evi")}
	evi <- terra::rast(vpRm$dirs$evi_dir)
	terra::time(evi) <- parse_modis_evi_times(vpRm$dirs$evi_dir)
	if(vpRm$verbose){Print_Info(evi)}
	evi_proc <- proc_3d(evi,plate, strict_times = F)
	evi_proc <- evi_proc*evi_scale_factor
	### mask out water which would ruin extrema
	evi_proc <- terra::mask(evi_proc, lc_proc, maskvalues = 11)
	### TODO: better (real) ocean mask
	ocean_cutoff <- .35
	evi_proc <- terra::mask(evi_proc, evi_proc<ocean_cutoff, maskvalues = 0)
	if(vpRm$verbose){Print_Info(evi)}
	Save_Rast(evi_proc, vpRm$dirs$evi_proc_dir)

	####### process evi extrema
	### TODO: if it alrdy exists dont rerun?
	if(vpRm$verbose){print("start process evi extrema")}
	if(is.null(vpRm$dirs$evi_extrema_dir)){
		### TODO: if there are times in plate in any year, that whole year must be present or error
		### TODO: TODO: NOT HAVING THIS STOP() IMPLEMENTED RESULTED IN US HUNTING A BUG FOR HOURS>>>>
		#                 if{
		#                 }#end 
		evi_extrema_proc <- c(max(evi_proc, na.rm = T), min(evi_proc, na.rm = T))
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
		green_proc <- green(evi_proc)
	}else{
		green <- terra::rast(vpRm$dirs$green_dir)
		green_proc <- proc_2d(green,plate)
	} #end else

	if(vpRm$verbose){Print_Info(green_proc)}
	Save_Rast(green_proc, vpRm$dirs$green_proc_dir)
	rm(green_proc)

	rm(evi, evi_proc)

	return(vpRm)
}#end func process.vpRm
