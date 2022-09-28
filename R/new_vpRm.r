#' new_vpRm
#' Initialize an object of class vpRm
#'
#' @param vpRm_dir (chr): path to initialize vpRm into; where to store processed drivers and outputs
#' @param lc_dir (chr): path to land cover data 
#' @param isa_dir (chr): path to impermeable surface data 
#' @param temp_dir (chr): path to temperature data
#' @param dswrf_dir (chr): path to initialize photosynthetically available radiation data
#' @param evi_dir (chr): path to vegetation index data
#' @param evi_extrema_dir (chr): path to evi_extrema 2d data
#' @param green_dir (chr): path to greenup/down data
#' 
#' @param vprm_params (data.frame): VPRM parameters, trained from tower data
#' 
#' @param vpRm_crs (terra::crs): coordinate reference system for intake
#' @param vpRm_ext (terra::ext): extent for intake
#' @param vpRm_res (terra::ext): resolution for intake
#' @param vpRm_time (terra::time): times of intake
#'
#' @param verbose (bool): print intermediary updates?
#'
#' @export
new_vpRm <- function(

	vpRm_dir = "."
	### TODO: set default to the heavy dir
	, lc_dir = NULL
	, isa_dir = NULL

	### TODO: enable ingest many files each with one time, or a rast w many times
	, temp_dir = NULL
	, dswrf_dir = NULL
	, evi_dir = NULL

	### TODO: set default to the heavy dir
	, evi_extrema_dir = NULL
	, green_dir = NULL

	, vprm_params = vpRm::vprm_params 

	, vpRm_crs = NULL
	, vpRm_ext = NULL
	, vpRm_res = NULL
	, vpRm_time = NULL

	, verbose = F 
	){

#########################
### Create Directories 
#########################

proc_dir <- file.path(vpRm_dir, "processed")
out_dir <- file.path(vpRm_dir, "out")

dir.create(proc_dir, recursive = T, showWarnings = F)
dir.create(out_dir, recursive = T, showWarnings = F)

lc_isa_proc_dir <- file.path(proc_dir, "lc_isa")
dir.create(lc_isa_proc_dir, recursive = T, showWarnings = F)
lc_proc_dir <- file.path(lc_isa_proc_dir, "lc.nc")
isa_proc_dir <- file.path(lc_isa_proc_dir, "isa.nc")

### parent directories of processed hourly driver data
temp_proc_dir <- file.path(proc_dir, "temp")
par_proc_dir <- file.path(proc_dir, "par")
evi_proc_dir <- file.path(proc_dir, "evi")
dir.create(temp_proc_dir, recursive = T, showWarnings = F)
dir.create(par_proc_dir, recursive = T, showWarnings = F)
dir.create(evi_proc_dir , recursive = T, showWarnings = F)

### parent directories of processed yearly driver data
evi_extrema_proc_dir <- file.path(proc_dir, "evi_extrema")
green_proc_dir <- file.path(proc_dir, "green")
dir.create(evi_extrema_proc_dir, recursive = T, showWarnings = F)
dir.create(green_proc_dir, recursive = T, showWarnings = F)

### parent directories of VPRM outputs
nee_dir <- file.path(out_dir, "nee")
gee_dir <- file.path(out_dir, "gee")
respir_dir <- file.path(out_dir, "respir")
dir.create(nee_dir, recursive = T, showWarnings = F)
dir.create(gee_dir, recursive = T, showWarnings = F)
dir.create(respir_dir, recursive = T, showWarnings = F)


evi_extrema_proc_files_dir <- NULL
green_proc_files_dir <- NULL

temp_proc_files_dir <- NULL
par_proc_files_dir <- NULL
evi_proc_files_dir <- NULL

nee_files_dir <- NULL
gee_files_dir <- NULL
respir_files_dir <- NULL

#########################
### Save S3 class 
#########################

### TODO: save as a plaintext
vpRm <- list(

	dirs = list(
		vpRm_dir = vpRm_dir

		, lc_dir = lc_dir 	
		, isa_dir = isa_dir 	
		, temp_dir = temp_dir
		, dswrf_dir = dswrf_dir
		, evi_dir = evi_dir
		, evi_extrema_dir = evi_extrema_dir
		, green_dir = green_dir

		, proc_dir = proc_dir

		, lc_isa_proc_dir = lc_isa_proc_dir 	
		, lc_proc_dir = lc_proc_dir 	
		, isa_proc_dir = isa_proc_dir 	

		### parent directories of processed hourly driver data
		, temp_proc_dir = temp_proc_dir
		, par_proc_dir = par_proc_dir
		, evi_proc_dir = evi_proc_dir
		### filenames of processed hourly driver data
		, temp_proc_files_dir = temp_proc_files_dir
		, par_proc_files_dir = par_proc_files_dir
		, evi_proc_files_dir = evi_proc_files_dir

		### parent directories of processed yearly driver data
		, evi_extrema_proc_dir = evi_extrema_proc_dir
		, green_proc_dir = green_proc_dir
		### filenames of processed yearly driver data
		, evi_extrema_proc_files_dir = evi_extrema_proc_files_dir
		, green_proc_files_dir = green_proc_files_dir

		### parent directories of VPRM outputs
		, out_dir = out_dir
		, nee_dir = nee_dir
		, gee_dir = gee_dir
		, respir_dir = respir_dir
		### filenames of VPRM outputs
		, nee_files_dir = nee_files_dir
		, gee_files_dir = gee_files_dir
		, respir_files_dir = respir_files_dir
	)#end list dirs

	, domain = list(
		  crs = vpRm_crs
		, ext = vpRm_ext 
		, res = vpRm_res
		, time = vpRm_time
	) #end list domain

	, vprm_params = vprm_params

	, verbose = verbose
)#end list vpRm

class(vpRm) <- "vpRm"

saveRDS(vpRm, file.path(vpRm_dir, "vpRm.rds"))

return(vpRm)

}#end func new vpRm
