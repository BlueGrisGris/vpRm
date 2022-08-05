#' Run a VPRM model defined by a vpRm object
#' 
#' Execute the models calculations defined in Mahadevan et al 2008 and Winbourne et al 2021.  Processes the driver data attached to the vpRm object with a call to proc_drivers(). 
#' 
#' 
#' @param vpRm (vpRm): a vpRm S3 object with attached driver data 
#' @return vpRm (vpRm): the same vpRm object, now with attached gee, respiration and nee netcdf files. 
#' @export
run.vpRm <- function(vpRm){

### TODO: an option to update the output location

#############################################
### point to processed drivers
#############################################

plate <- terra::rast(vpRm$dirs$plate_dir)
lc <- terra::rast(vpRm$dirs$lc_proc_dir)
isa <- terra::rast(vpRm$dirs$isa_proc_dir)
temp <- terra::rast(vpRm$dirs$temp_proc_dir)
PAR <- terra::rast(vpRm$dirs$par_proc_dir)
EVI <- terra::rast(vpRm$dirs$evi_proc_dir)
EVIextrema <- terra::rast(vpRm$dirs$evi_extrema_proc_dir)
green <- terra::rast(vpRm$dirs$green_proc_dir)
vprm_params <- vpRm$params

if(vpRm$verbose){print("read in proc'd data");print(terra::free_RAM())}

#############################################
### collate vprm paramters
#############################################
if(vpRm$verbose){print("start collate VPRM params")}

### TODO: check that we dont need an addtl mask
lambda <- sum( (lc == vprm_params[,"lc"])*vprm_params[,"lambda"] )

Tmin <-  sum( (lc == vprm_params[,"lc"])*vprm_params[,"Tmin"] )
Tmax <-  sum( (lc == vprm_params[,"lc"])*vprm_params[,"Tmax"] )

PAR0 <-  sum( (lc == vprm_params[,"lc"])*vprm_params[,"PAR0"] )

alpha <- sum( (lc == vprm_params[,"lc"])*vprm_params[,"alpha"] )
beta <-  sum( (lc == vprm_params[,"lc"])*vprm_params[,"beta"] )

#############################################
### calculate scalars
#############################################
if(vpRm$verbose){print("start calculate scalars")}

Tscalar <- Tscalar(temp, Tmin, Tmax)

EVImax <- EVIextrema[[1]]
EVImin <- EVIextrema[[2]]
Pscalar <- Pscalar(EVI, EVImax, EVImin) 
### TODO: hmmm sometimes EVImax and min are super close..
Pscalar <- terra::mask(Pscalar, (Pscalar > 1) | (Pscalar < 0)  , maskvalues = 1)
### simplified Wscalar
Wscalar <- Wscalar("fake_lswi", "fake_lswi")  

#############################################
### calculate gee
#############################################
if(vpRm$verbose){print("start calculate gee")}

gee <- gee(
	   lambda
	   , Tscalar
	   , Pscalar
	   , Wscalar
	   , EVI
	   , PAR
	   , PAR0
)#end gee

terra::time(gee) <- terra::time(plate)

if(vpRm$verbose){print("start apply growing system boundary")}
### Set gee to zero outside of growing season
doy <- lubridate::yday(terra::time(gee)) 
green_mask <- (green[[1]] < doy) & (green[[2]] > doy)
### but not for evergreen?
### TODO: our test set doesn't have evergreen, so untested
green_mask[lc == 42] <- 1
gee <- gee*green_mask 

### gee = zero where there is water
gee <- gee * (lc!=11)
### just a few pixels come out negative
### TODO: send a warning if more than 1%
gee <- mask(gee, gee<0, maskvalues = 1)

terra::writeCDF(gee, vpRm$dirs$gee, overwrite = T, prec = "double")

# Save_Rast(gee, vpRm$dirs$gee)

#############################################
### calculate respiration
#############################################
if(vpRm$verbose){print("start calculate respiration")}
respir <- respir(
	temp
	, alpha
	, beta
	, lc
	, isa
	, EVI
)#end respir

### respir = zero where there is water
respir <- respir * (lc!=11)

terra::writeCDF(respir, vpRm$dirs$respir, overwrite = T, prec = "double")
# Save_Rast(respir, vpRm$dirs$respir)

if(vpRm$verbose){print("start calculate nee")}

nee <- respir - gee

terra::writeCDF(nee, vpRm$dirs$nee, overwrite = T, prec = "double")

if(vpRm$verbose){print("finished!")}
return(vpRm)

}#end func run.vpRm
