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

lc <- terra::rast(vpRm$dirs$lc_proc_dir)
isa <- terra::rast(vpRm$dirs$isa_proc_dir)
temp <- terra::rast(vpRm$dirs$temp_proc_dir)
PAR <- terra::rast(vpRm$dirs$par_proc_dir)
EVI <- terra::rast(vpRm$dirs$evi_proc_dir)
EVIextrema <- terra::rast(vpRm$dirs$evi_extrema_proc_dir)
green <- terra::rast(vpRm$dirs$green_proc_dir)
vprm_params <- vpRm$params

#############################################
### collate vprm paramters
#############################################

### TODO: i think it is ok that these are in memory, bc if they get big
### terra will spit them to temp storage
### however, this might cause issues when run thru slurm
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

Tscalar <- Tscalar(temp, Tmin, Tmax)

### TODO: dates look wrong
EVImax <- EVIextrema[[1]]
EVImin <- EVIextrema[[2]]
Pscalar <- Pscalar(EVI, EVImin, EVImax) 

### TODO: resolve LSWI conundrum
### option: actually calculate the linear dependence betw/ evi lswi
LSWI <- EVI/2.5
LSWImax <- EVImax/2.5
Wscalar <- Wscalar(LSWI, LSWImax)  

#############################################
### calculate gee
#############################################

gee <- gee(
	   lambda
	   , Tscalar
	   , Pscalar
	   , Wscalar
	   , EVI
	   , PAR
	   , PAR0
)#end gee

### Set gee to zero outside of growing season
### but not for evergreen?

green

### gee = zero where there is water
gee <- gee * (lc!=11)

Save_Rast(gee, vpRm$dirs$gee)

#############################################
### calculate respiration
#############################################


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

Save_Rast(respir, vpRm$dirs$respir)

nee <- respir - gee

Save_Rast(nee, vpRm$dirs$nee)

return(vpRm)

}#end func run.vpRm
