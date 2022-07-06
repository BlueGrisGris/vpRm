#' Run a VPRM model defined by a vpRm object
#' @param vpRm (vpRm) a vpRm object 
#' @export
run.vpRm <- function(vpRm){

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

if(F){
terra::plot(Pscalar)
terra::plot(plate)
terra::plot(EVI)
terra::plot(Tmin)
terra::plot(Tmax)
terra::plot(pw_idx)
terra::plot(lc)
terra::plot(alpha)
terra::plot(yy)
}#end if F

#############################################
### calculate scalars
#############################################

Tscalar <- Tscalar(temp, Tmin, Tmax)

### TODO: dates look wrong
EVImax <- EVIextrema[[1]]
EVImin <- EVIextrema[[2]]
Pscalar <- Pscalar(EVI, EVImin, EVImax) 

### TODO: resolve LSWI conundrum
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

### TODO: Set gee to zero outside of growing season
### but not for evergreen?

# Save_Rast(gee, vpRm$dirs$gee)

#############################################
### calculate respiration
#############################################

### gee = zero where there is water
gee <- gee * (lc!=11)

respir <- respir(
	temp
	, alpha
	, beta
	, lc
	, isa
	, evi
)#end respir

Save_Rast(respir, vpRm$dirs$respir)

# nee <- respir - gee

# Save_Rast(nee, vpRm$dirs$nee)

}#end func run.vpRm
