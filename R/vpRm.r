#' vpRm
#' Wrapper function to run a vpRm model from start to finish.
#'
#' @param vpRm_dir (chr): path to initialize vpRm into; where to store processed drivers and outputs
#'
#' @param lc_dir (chr): path to land cover data 
#' @param isa_dir (chr): path to impermeable surface data 
#'
#' @param temp_dir (chr): path to temperature data
#' @param dswrf_dir (chr): path to initialize photosynthetically available radiation data
#'
#' @param landsat_dir (chr): path to raw landsat reflectance data
#' @param evi_dir (chr): path to vegetation index data
#' @param lswi_dir (chr): path to LSWI data
#'
#' @param evi_extrema_dir (chr): path to evi_extrema 2d data
#' @param green_dir (chr): path to greenup/down data
#' 
#' @param vprm_params (data.frame): VPRM parameters, trained from tower data
#' @param domain_template (chr, terra::spatRaster): Spatiotemporal domain over which to run VPRM. For example: a series of STILT footprints.
#' @param vprm_params (data.frame): VPRM parameters, trained from tower data
#' 
#' @param verbose (bool): print intermediary updates?
#'
#' @export
vpRm <- function(
		 
	vpRm_dir = "."

	, lc_dir = NULL
	, isa_dir = NULL

	, temp_dir = NULL
	, dswrf_dir = NULL

	, landsat_dir = NULL
	, evi_dir = NULL
	, lswi_dir = NULL

	, evi_extrema_dir = NULL
	, green_dir = NULL

	, vprm_params = vpRm::vprm_params 

	, domain_template = NULL 

	, verbose = F 
		 
){#end params vpRm()

	### initialize a vpRm object

	### get missing driver data
	### check if capable of downloading data
	### download driver data

	### get unprocessed driver data 
	### process driver data

	### run VPRM

	return(vpRm)

}#end func vpRm
