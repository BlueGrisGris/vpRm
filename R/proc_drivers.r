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
				  , vpRm$dirs$greenup_dir
				  ))))){
	       stop("all driver data directories must be provided")
	}#end if length which

	plate <- terra::rast(vpRm$dirs$plate)

	####### process landcover
	lc <- terra::rast(vpRm$dirs$lc_dir)
	lc_proc <- proc_2d(lc,plate)
	Save_Rast(lc_proc, vpRm$dirs$lc_proc_dir)

	####### process isa
	isa <- terra::rast(vpRm$dirs$isa_dir)
	isa_proc <- proc_2d(isa,plate)
	Save_Rast(isa_proc, vpRm$dirs$isa_proc_dir)

	####### process temp
	temp <- terra::rast(vpRm$dirs$temp_dir)
	temp_proc <- proc_3d(temp,plate)
	Save_Rast(temp_proc, vpRm$dirs$temp_proc_dir)

	####### process par
	par <- terra::rast(vpRm$dirs$par_dir)
	par_proc <- proc_3d(par,plate)
	Save_Rast(par_proc, vpRm$dirs$par_proc_dir)

	####### process evi
	### TODO: test that evi \in {-1,1}
	evi <- terra::rast(vpRm$dirs$evi_dir)
	evi_proc <- proc_3d(evi,plate, strict_times = F)
	evi_proc <- evi_proc*1e-4
	Save_Rast(evi_proc, vpRm$dirs$evi_proc_dir)

	####### process evi extrema
	evi_extrema <- terra::rast(vpRm$dirs$evi_extrema_dir)
	evi_extrema_proc <- proc_2d(evi_extrema,plate)
	evi_extrema_proc <- evi_extrema_proc*1e-4
	Save_Rast(evi_extrema_proc, vpRm$dirs$evi_extrema_proc_dir)

	####### process green
	#         green <- terra::rast(vpRm$dirs$green_dir)
	green <- green(evi)
	green_proc <- proc_2d(green,plate)
	Save_Rast(green_proc, vpRm$dirs$green_proc_dir)

	return(vpRm)
}#end func process.vpRm
