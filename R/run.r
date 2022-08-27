#' run_vpRm
#' Run a VPRM model defined by a vpRm object
#' 
#' Execute the models calculations defined in Mahadevan et al 2008 and Winbourne et al 2021.  Processes the driver data attached to the vpRm object with a call to proc_drivers(). 
#' 
#' @param vpRm (vpRm): a vpRm S3 object with attached driver data 
#' @return vpRm (vpRm): the same vpRm object, now with attached gee, respiration and nee netcdf files. 
#' @export
run_vpRm <- function(vpRm){
if(class(vpRm) != "vpRm"){stop("must be an object of class vpRm")}
### TODO: an option to update the output location
### TODO: run should check shape

#############################################
### point to processed drivers
#############################################

plate <- terra::rast(vpRm$dirs$plate_dir)

LC <- terra::rast(vpRm$dirs$lc_proc_dir)
ISA <- terra::rast(vpRm$dirs$isa_proc_dir)

### TODO: test the stop behavior
if( any(dim(LC) != c(dim(plate)[1:2], 1) )){stop(paste("dim lc_proc =", dim(LC), " does not align dim plate =", dim(plate)))}
if( any(dim(ISA) != c(dim(plate)[1:2], 1) )){stop(paste("dim isa_proc =", dim(ISA), " does not align dim plate =", dim(plate)))}

TEMP <- terra::rast(vpRm$dirs$temp_proc_dir)
PAR <- terra::rast(vpRm$dirs$par_proc_dir)
EVI <- terra::rast(vpRm$dirs$evi_proc_dir)
if( any(dim(TEMP) != dim(plate)) ){stop(paste("dim temp_proc =", dim(TEMP), " does not match dim plate =", dim(plate)))}
if( any(dim(PAR) != dim(plate)) ){stop(paste("dim par_proc =", dim(PAR), " does not match dim plate =", dim(plate)))}
if( any(dim(evi) != dim(plate)) ){stop(paste("dim evi_proc =", dim(evi), " does not match dim plate =", dim(plate)))}

EVIextrema <- terra::rast(vpRm$dirs$evi_extrema_proc_dir)
GREEN <- terra::rast(vpRm$dirs$green_proc_dir)
if( any(dim(EVIextrema) != c(dim(plate)[1:2], 2) )){stop(paste("dim EVIextrema_proc =", dim(EVIextrema), " does not align dim plate =", dim(plate)))}
if( any(dim(GREEN) != c(dim(plate)[1:2], 2) )){stop(paste("dim green_proc =", dim(GREEN), " does not align dim plate =", dim(plate)))}

vprm_params <- vpRm$params

if(vpRm$verbose){print("read in proc'd data");print(terra::free_RAM())}

#############################################
### collate vprm paramters
#############################################
if(vpRm$verbose){print("start collate VPRM params")}

### TODO: check that we dont need an addtl mask
lambda <- sum( (LC == vprm_params[,"lc"])*vprm_params[,"lambda"] )

Tmin <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"Tmin"] )
Tmax <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"Tmax"] )

PAR0 <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"PAR0"] )

ALPHA <- sum( (LC == vprm_params[,"lc"])*vprm_params[,"alpha"] )
BETA <-  sum( (LC == vprm_params[,"lc"])*vprm_params[,"beta"] )

#############################################
### calculate scalars
#############################################
if(vpRm$verbose){print("start calculate scalars")}

Tscalar <- Tscalar(TEMP, Tmin, Tmax)

EVImax <- EVIextrema[[1]]
EVImin <- EVIextrema[[2]]

Pscalar <- Pscalar(EVI, EVImax, EVImin) 

Pscalar[LC == 42] <- 1
Pscalar[Pscalar < 0] <- 0 
Pscalar[Pscalar > 1] <- 1 

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

### Set gee to zero outside of growing season
doy <- lubridate::yday(terra::time(GEE)) 
green_mask <- (GREEN[[1]] < doy) & (GREEN[[2]] > doy)
### but not for evergreen?
### TODO: our test set doesn't have evergreen, so untested
green_mask[LC == 42] <- 1
GEE <- GEE*green_mask 

### gee = zero where there is water
GEE <- GEE * (LC!=11)
### just a few pixels come out negative
### TODO: send a warning if more than 1%
# GEE <- GEE * (GEE>0)
### for some reason this mask crashes R in terra 1.6.3. woo
# GEE <- terra::mask(GEE, GEE<0, maskvalues = 1)

#############################################
### calculate respiration
#############################################
if(vpRm$verbose){print("start calculate respiration")}

RESPIR <- respir(
	TEMP
	, ALPHA
	, BETA
	, LC
	, ISA
	, EVI
)#end respir

terra::time(RESPIR) <- terra::time(plate)


### respir = zero where there is water
RESPIR <- RESPIR * (LC!=11)

if(vpRm$verbose){print("start calculate nee")}

NEE <- RESPIR - GEE
names(NEE) <- rep("nee", terra::nlyr(NEE))


### save output CO2 flux fields
lapply(list(NEE, GEE, RESPIR), function(ff){
	field_name <- names(ff)[1]
	### save each time point to a different file
	lapply(ff, function(tt){
		field_time <- terra::time(tt)

		field_filename <- file.path( 
			vpRm$dirs[[paste(field_name, "dir", sep = "_")]]
			,
			paste0(
			paste(
				lubridate::year(field_time)
				, lubridate::month(field_time)
				, lubridate::day(field_time)
				, paste0(
					lubridate::hour(field_time)
					, lubridate::minute(field_time)
					, lubridate::second(field_time)
				) #end paste 0 inner
				, sep = "_"
			)#end paste
			, ".nc"
			)#end paste0
		)#end file.path
		terra::writeCDF(
				tt
				, filename = field_filename
				, varname = field_name
				, longname = paste(field_name, "CO2 flux")
				, zname = "time"
				, unit = "micromol CO2 m-2 s-1"
				, overwrite = T
				, prec = "double"
		)#end writeCDF
		return(NULL)
	}) #end sapply tt
	return(NULL)
})#end lapply list fields

if(vpRm$verbose){print("run finished!")}
return(vpRm)

}#end func run.vpRm
