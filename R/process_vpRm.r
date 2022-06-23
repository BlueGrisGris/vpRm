#' process.vpRm()
#' Process the driver data for a VPRM model
#' calls functions proc*
#'
#' @param vpRm (vpRm) a vpRm object 
#' @export
proc_drivers.vpRm <- function(vpRm){
	plate <- terra::rast(vpRm$dirs$plate)

	####### process landcover
	lc <- terra::rast(vpRm$dirs$lc_dir)
	lc_proc <- proc_simple_2d(lc,plate)
	Save_Rast(lc_proc, vpRm$dirs$lc_proc_dir)

	####### process temp
	temp <- terra::rast(vpRm$dirs$temp_dir)
	temp_proc <- proc_simple_3d(temp,plate)
	Save_Rast(temp_proc, vpRm$dirs$temp_proc_dir)


	par <- terra::rast(vpRm$dirs$par_proc_dir)
	
	evi <- terra::rast(vpRm$dirs$evi_proc_dir)
	
	green <- terra::rast(vpRm$dirs$greenup_proc_dir)

	### TODO: what to return??
	return(vpRm)
}#end func process.vpRm
