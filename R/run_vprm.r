#' run.vpRm()
#' Run a VPRM model defined by a vpRm object
#' @param vpRm (vpRm) a vpRm object 
#' @export
run.vpRm <- function(vpRm){

lc <- terra::rast(vpRm$dirs$lc_proc_dir)
temp <- terra::rast(vpRm$dirs$temp_proc_dir)
par <- terra::rast(vpRm$dirs$par_proc_dir)
evi <- terra::rast(vpRm$dirs$evi_proc_dir)
green <- terra::rast(vpRm$dirs$greenup_proc_dir)
vprm_params <- vpRm$params

#############################################
### calculate gee
#############################################

gee <- gee()

#############################################
### TODO: Set gee to zero outside of growing season
#############################################

Save_Rast(gee, vpRm$dirs$gee)

#############################################
### calculate respiration
#############################################

respir <- respir(
	temp
	### TODO: create a new alpha and beta raster in memory?
	, vprm_params[vprm_params$lc == lc,"alpha"]
	, vprm_params[vprm_params$lc == lc,"beta"] 
	, lc
	, isa
	, evi
)#end respir
Save_Rast(respir, vpRm$dirs$respir)

nee <- respir - gee
Save_Rast(nee, vpRm$dirs$nee)

}#end func run.vpRm
