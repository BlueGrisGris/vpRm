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
### TODO: run should check shape

#############################################
### point to processed drivers
#############################################

plate <- terra::rast(vpRm$dirs$plate_dir)

lc <- terra::rast(vpRm$dirs$lc_proc_dir)
isa <- terra::rast(vpRm$dirs$isa_proc_dir)

if( any(dim(lc) != c(dim(plate)[1:2], 1) )){stop(paste("dim lc_proc =", dim(lc), " does not align dim plate =", dim(plate)))}
if( any(dim(isa) != c(dim(plate)[1:2], 1) )){stop(paste("dim isa_proc =", dim(isa), " does not align dim plate =", dim(plate)))}


temp <- terra::rast(vpRm$dirs$temp_proc_dir)
PAR <- terra::rast(vpRm$dirs$par_proc_dir)
EVI <- terra::rast(vpRm$dirs$evi_proc_dir)
if( any(dim(temp) != dim(plate)) ){stop(paste("dim temp_proc =", dim(temp), " does not match dim plate =", dim(plate)))}
if( any(dim(par) != dim(plate)) ){stop(paste("dim par_proc =", dim(par), " does not match dim plate =", dim(plate)))}
if( any(dim(evi) != dim(plate)) ){stop(paste("dim evi_proc =", dim(evi), " does not match dim plate =", dim(plate)))}

EVIextrema <- terra::rast(vpRm$dirs$evi_extrema_proc_dir)
green <- terra::rast(vpRm$dirs$green_proc_dir)
if( any(dim(EVIextrema) != c(dim(plate)[1:2], 2) )){stop(paste("dim EVIextrema_proc =", dim(EVIextrema), " does not align dim plate =", dim(plate)))}
if( any(dim(green) != c(dim(plate)[1:2], 2) )){stop(paste("dim green_proc =", dim(green), " does not align dim plate =", dim(plate)))}

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

GEE <- gee(
	   lambda
	   , Tscalar
	   , Pscalar
	   , Wscalar
	   , EVI
	   , PAR
	   , PAR0
)#end gee

terra::time(GEE) <- terra::time(plate)

if(vpRm$verbose){print("start apply growing system boundary")}
### Set gee to zero outside of growing season
doy <- lubridate::yday(terra::time(GEE)) 
green_mask <- (green[[1]] < doy) & (green[[2]] > doy)
### but not for evergreen?
### TODO: our test set doesn't have evergreen, so untested
green_mask[lc == 42] <- 1
GEE <- GEE*green_mask 

### gee = zero where there is water
GEE <- GEE * (lc!=11)
### just a few pixels come out negative
### TODO: send a warning if more than 1%
GEE <- GEE * (GEE>0)
### for some reason this mask crashes R in terra 1.6.3. woo
# GEE <- terra::mask(GEE, GEE<0, maskvalues = 1)

### writeCDF breaks but writeRaster doesn't? terra plz fix your shit>>>
terra::writeRaster(GEE, vpRm$dirs$gee, overwrite = T)
# terra::writeCDF(GEE, vpRm$dirs$gee, overwrite = T, prec = "double")

#############################################
### calculate respiration
#############################################
if(vpRm$verbose){print("start calculate respiration")}

RESPIR <- respir(
	temp
	, alpha
	, beta
	, lc
	, isa
	, EVI
)#end respir

### respir = zero where there is water
RESPIR <- RESPIR * (lc!=11)

terra::time(RESPIR) <- terra::time(plate)

terra::writeRaster(RESPIR, vpRm$dirs$respir, overwrite = T)
# terra::writeCDF(RESPIR, vpRm$dirs$respir, overwrite = T, prec = "double")

if(vpRm$verbose){print("start calculate nee")}

NEE <- RESPIR - GEE
# terra::writeCDF(NEE, vpRm$dirs$nee, overwrite = T, prec = "double")
terra::writeRaster(NEE, vpRm$dirs$nee, overwrite = T)

if(vpRm$verbose){print("run finished!")}
return(vpRm)

}#end func run.vpRm
