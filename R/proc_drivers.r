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
				  )))) != 0 ){
	       stop("all driver data directories must be provided")
	}#end if length which

	if(!file.exists(vpRm$dirs$plate)){
	stop(paste(deparse(substitute(vpRM)), "does not have an associated template. use gen_plate()"))
	}#end if(!file.exists(vpRm$dirs$plate)){
	plate <- terra::rast(vpRm$dirs$plate)

	####### process landcover
	if(vpRm$verbose){print("start process landcover")}
	lc <- terra::rast(vpRm$dirs$lc_dir)
	lc_proc <- proc_2d(lc,plate)
	Save_Rast(lc_proc, vpRm$dirs$lc_proc_dir)

	####### process isa
	if(vpRm$verbose){print("start process impermeability")}
	isa <- terra::rast(vpRm$dirs$isa_dir)
	isa_proc <- proc_2d(isa,plate)
	Save_Rast(isa_proc, vpRm$dirs$isa_proc_dir)

	####### process temp
	if(vpRm$verbose){print("start process temperature")}
	temp <- terra::rast(vpRm$dirs$temp_dir)
	temp_proc <- proc_3d(temp,plate)
	Save_Rast(temp_proc, vpRm$dirs$temp_proc_dir)

	####### process par
	if(vpRm$verbose){print("start process PAR")}
	par <- terra::rast(vpRm$dirs$par_dir)
	par_proc <- proc_3d(par,plate)
	Save_Rast(par_proc, vpRm$dirs$par_proc_dir)

	####### process evi
	### TODO: test that evi \in {-1,1}
	if(vpRm$verbose){print("start process evi")}
	evi <- terra::rast(vpRm$dirs$evi_dir)
	evi_proc <- proc_3d(evi,plate, strict_times = F)
	evi_proc <- evi_proc*1e-4
	Save_Rast(evi_proc, vpRm$dirs$evi_proc_dir)

	####### process evi extrema
	### TODO: if it alrdy exists dont rerun?
	if(vpRm$verbose){print("start process evi extrema")}
	evi_extrema_proc <- c(max(evi_proc, na.rm = T), min(evi_proc, na.rm = T))
	Save_Rast(evi_extrema_proc, vpRm$dirs$evi_extrema_proc_dir)

	####### process green
	if(vpRm$verbose){print("start process green")}
	green <- green(evi)
	green_proc <- proc_2d(green,plate)
	Save_Rast(green_proc, vpRm$dirs$green_proc_dir)

	return(vpRm)
}#end func process.vpRm
