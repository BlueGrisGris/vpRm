new_vpRm <- function(
		     ### TODO: control flow for creating /not creating directories
	vpRm_dir = "."
	, matchdomain = NULL

	#         , driver_dir = NULL
	#         , proc_dir = NULL
	#         , out_dir = NULL
	, lc_dir = NULL
	, temp_dir = NULL
	, par_dir = NULL
	, evi_dir = NULL
	, greenup_dir = NULL



	, verbose = F 
		     
	, params = NULL
		     
		     
		     
	){

#########################
### Create Directories 
#########################
### TODO: right now drivers are pre downloaded
# driver_dir <- file.path(vpRm_dir, "driver")
proc_dir <- file.path(vpRm_dir, "processed")
out_dir <- file.path(vpRm_dir, "out")

# dir.create(driver_dir, recursive = T, showWarnings = F)
dir.create(proc_dir, recursive = T, showWarnings = F)
dir.create(out_dir, recursive = T, showWarnings = F)

lc_proc_dir <- file.path(proc_dir, "lc.nc")
temp_proc_dir <- file.path(proc_dir, "temp.nc")
par_proc_dir <- file.path(proc_dir, "par.nc")
evi_proc_dir <- file.path(proc_dir, "evi.nc")
greenup_proc_dir <- file.path(proc_dir, "greenup.nc")

gee_dir <- file.path(out_dir, "gee.nc")
respir_dir <- file.path(out_dir, "respir.nc")
nee_dir <- file.path(out_dir, "nee.nc")

#########################
### Save plate to vpRm_dir/processed
#########################

### TODO: still want to be able to come back and gen_plate on a preexisting vpRm
### ----> maybe this is the provenance of vpRm() as opposed to new_vpRm()
plate <- gen_plate(matchdomain, lc_dir)

### TODO: should this save to storage be a part of this function or in the S3 init?
### save into init_vpRm() created dir processed
### TODO: add to vprm.log/ do 
plate_dir <- file.path(vpRm_dir,"processed","plate.nc")
suppressWarnings( ### warning when saving an empty netcdf
terra::writeCDF(
		plate
		, filename = plate_dir 
		, overwrite = T 
	)#end terra::writeCDF
)#end suppressWarnings

rm(plate)

#########################
### Check Driver data
#########################

#########################
###  
#########################

vpRm <- list(
	vpRm_dir = vpRm_dir

	#         , driver_dir = driver_dir
	, lc_dir = lc_dir 	
	, temp_dir = temp_dir
	, par_dir = par_dir
	, evi_dir = evi_dir
	, greenup_dir = greenup_dir


	, proc_dir = proc_dir
	, plate_dir = plate_dir

	, lc_proc_dir = lc_proc_dir 	
	, temp_proc_dir = temp_proc_dir
	, par_proc_dir = par_proc_dir
	, evi_proc_dir = evi_proc_dir
	, greenup_proc_dir = greenup_proc_dir

	, out_dir = out_dir
	, gee_dir = gee_dir
	, respir_dir = respir_dir
	, nee_dir = nee_dir

	, params = params
)#end list

class(vpRm) <- "vpRm"

return(vpRm)

}#end func new vpRm
