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

#       TODO:  ---> also we are not following the principles about args on pg 304 Advanced R

#########################
### Create Directories 
#########################

proc_dir <- file.path(vpRm_dir, "processed")
out_dir <- file.path(vpRm_dir, "out")

dir.create(proc_dir, recursive = T, showWarnings = F)
dir.create(out_dir, recursive = T, showWarnings = F)

lc_proc_dir <- file.path(proc_dir, "lc.nc")
isa_proc_dir <- file.path(proc_dir, "isa.nc")
plate_dir <- file.path(proc_dir, "plate.nc")
temp_proc_dir <- file.path(proc_dir, "temp.nc")
par_proc_dir <- file.path(proc_dir, "par.nc")
evi_proc_dir <- file.path(proc_dir, "evi.nc")
evi_extrema_proc_dir <- file.path(proc_dir, "evi_extrema.nc")
green_proc_dir <- file.path(proc_dir, "green.nc")

gee_dir <- file.path(out_dir, "gee")
respir_dir <- file.path(out_dir, "respir")
nee_dir <- file.path(out_dir, "nee")

dir.create(nee_dir, recursive = T, showWarnings = F)
dir.create(gee_dir, recursive = T, showWarnings = F)
dir.create(respir_dir, recursive = T, showWarnings = F)

### TODO: outfiles for each time -- properly zero padded
# , nee_dir = nee_files_dir
# , gee_dir = gee_files_dir
# , respir_dir = respir_files_dir

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
		, plate_dir = plate_dir

		, lc_proc_dir = lc_proc_dir 	
		, isa_proc_dir = isa_proc_dir 	
		, temp_proc_dir = temp_proc_dir
		, par_proc_dir = par_proc_dir
		, evi_proc_dir = evi_proc_dir
		, evi_extrema_proc_dir = evi_extrema_proc_dir
		, green_proc_dir = green_proc_dir

		, out_dir = out_dir
		, nee_dir = nee_dir
		, gee_dir = gee_dir
		, respir_dir = respir_dir
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
