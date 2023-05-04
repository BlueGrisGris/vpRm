#' set_domain()
#'
#' Sets the domain of a vpRm object 
#' Give a vpRm object a temporal spatial domain over which to run VPRM.
#' Sets the output CRS and extent.  
#' Can take a given terra::spatRaster object, or directory to geospatial data readable by terra. 
#' For example, a STILT domain you want to convolve with the VPRM NEE output field
#' Can also take a projection, xy bounds, and and time series.
#'
#' @param vpRm (vpRm): vpRm object you want to set the domain of
#' @param domain (spatRaster or chr): domain you want to run VRPM over 
#' @param vpRm_ext (vector): c(xmin, xmax, ymin, ymax) 
#' @param vpRm_crs (chr): Optional CRS.  Overwrites CRS of domain 
#' @param vpRm_res (chr): Optional resolution. Overwrites res of domain
#' @param vpRm_time (vector): Optional times to run VPRM over. Overwrites time of domain 
#' 
#' If not NULL- vpRm_ext, vpRm_crs, vpRm_time, will overwrite the CRS of domain, if domain is given. 
#'
#' @export
set_domain <- function(
	vpRm
	, domain = NULL
	, vpRm_crs = NULL
	, vpRm_ext = NULL
	, vpRm_res = NULL
	, vpRm_time = NULL
){

if(!methods::is(vpRm, "vpRm")){stop("must be an object of class vpRm")}

#######
### check different bits
#######

### read domain and extract data 
if(!is.null(domain)){
	domain <- sanitize_raster(domain)
	vpRm$domain$crs <- terra::crs(domain)
	vpRm$domain$ext <- terra::ext(domain)
	vpRm$domain$res <- terra::res(domain)
	vpRm$domain$time <- terra::time(domain)
}#end if(!is.null(domain)){

### overwrite domain data if supplied 
if(!is.null(vpRm_crs)){
	vpRm$domain$crs <- vpRm_crs
}#end if(!is.null(vpRm_crs)){
if(!is.null(vpRm_ext)){
	vpRm$domain$ext <- vpRm_ext
}#end if(!is.null(vpRm_ext)){
if(!is.null(vpRm_res)){
	vpRm$domain$res <- vpRm_res
}#end if(!is.null(vpRm_res)){
if(!is.null(vpRm_time)){
	vpRm$domain$time <- vpRm_time
}#end if(!is.null(vpRm_time)){

### the hours in the domain for use in filenames
filename_tt <- paste0(paste(
	lubridate::year(vpRm$domain$time)
	, stringr::str_pad(lubridate::month(vpRm$domain$time),width = 2, pad = "0")
	, stringr::str_pad(lubridate::day(vpRm$domain$time),width = 2, pad = "0")
	, stringr::str_pad(lubridate::hour(vpRm$domain$time),width = 2, pad = "0")
	, stringr::str_pad(lubridate::minute(vpRm$domain$time),width = 2, pad = "0")
	, sep = "_"
), ".nc") #end paste

### set the processed data filenames
### yearly processed filenames
domain_years <- unique(lubridate::year(vpRm$domain$time))
vpRm$dirs$evi_extrema_proc_files_dir <- file.path(vpRm$dirs$evi_extrema_proc_dir, paste0(domain_years, ".tif"))
vpRm$dirs$green_proc_files_dir <- file.path(vpRm$dirs$green_proc_dir, paste0(domain_years, ".tif"))
### hourly processed filenames
### TODO: evi needs to be special when we stop reproccing every hour
vpRm$dirs$temp_proc_files_dir <- file.path(vpRm$dirs$temp_proc_dir, filename_tt)
vpRm$dirs$par_proc_files_dir <- file.path(vpRm$dirs$par_proc_dir, filename_tt)
vpRm$dirs$evi_proc_files_dir <- file.path(vpRm$dirs$evi_proc_dir, filename_tt)

### set the output filenames
vpRm$dirs$nee_files_dir <- file.path(vpRm$dirs$nee_dir, filename_tt)
vpRm$dirs$gee_files_dir <- file.path(vpRm$dirs$gee_dir, filename_tt)
vpRm$dirs$respir_files_dir <- file.path(vpRm$dirs$respir_dir, filename_tt)

return(vpRm)

}#end func set_domain
