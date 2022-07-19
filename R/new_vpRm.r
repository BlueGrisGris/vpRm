#' new_vpRm
#' Initialize an object of class vpRm
#'
#' @param vpRm_dir (chr): path to initialize vpRm into; where to store processed drivers and outputs
#' @param lc_dir (chr): path to land cover data 
#' @param isa_dir (chr): path to impermeable surface data 
#' @param temp_dir (chr): path to temperature data
#' @param par_dir (chr): path to initialize photosynthetically available radiation data
#' @param evi_dir (chr): path to vegetation index data
#' @param verbose (bool): print intermediary updates?
#'
#' @export
new_vpRm <- function(
	vpRm_dir = "."
	, lc_dir = NULL
	, isa_dir = NULL
	, temp_dir = NULL
	, par_dir = NULL
	, evi_dir = NULL
	, evi_extrema_dir = NULL
	, green_dir = NULL

	, verbose = F 
	#         , params = NULL
	){

#       TODO:  ---> also we are not following the principles about args on pg 304 Advanced R

#########################
### Create Directories 
#########################
### TODO: right now drivers are pre downloaded
### TODO: ability to override dirs
# driver_dir <- file.path(vpRm_dir, "driver")
proc_dir <- file.path(vpRm_dir, "processed")
out_dir <- file.path(vpRm_dir, "out")

# dir.create(driver_dir, recursive = T, showWarnings = F)
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

gee_dir <- file.path(out_dir, "gee.nc")
respir_dir <- file.path(out_dir, "respir.nc")
nee_dir <- file.path(out_dir, "nee.nc")

#########################
### Save plate to vpRm_dir/processed
#########################


#########################
### vprm_params
#########################
### TODO: implement user defined paraams

params <- vpRm::vprm_params

#########################
### Save S3 class 
#########################
### TODO: save as a plaintext? or a rda?
vpRm <- list(
	dirs = list(
	vpRm_dir = vpRm_dir

	#         , driver_dir = driver_dir
	, lc_dir = lc_dir 	
	, isa_dir = isa_dir 	
	, temp_dir = temp_dir
	, par_dir = par_dir
	, evi_dir = evi_dir
	, evi_extrema_dir = evi_dir
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
	, gee_dir = gee_dir
	, respir_dir = respir_dir
	, nee_dir = nee_dir
	)#end list dirs

	, params = params
	, verbose = verbose
)#end list vpRm

class(vpRm) <- "vpRm"

return(vpRm)

}#end func new vpRm
