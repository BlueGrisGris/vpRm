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
#' @param vpRm_crs (chr): optional CRS. 
#' @param vpRm_time (vector): times to run VPRM over
#' 
#' If not NULL- vpRm_ext, vpRm_crs, vpRm_time, will overwrite the CRS of domain, if domain is given. 
#'
#' @export
set_domain <- function(
	vpRm
	, domain = NULL
	, vpRm_crs = NULL
	, vpRm_ext = NULL
	, vpRm_time = NULL
){

#######
### check different bits
#######

### read domain and extract data 
domain <- sanitize_raster(domain)
vpRm$domain$crs <- terra::crs(domain)
vpRm$domain$ext <- terra::ext(domain)
vpRm$domain$time <- terra::time(domain)

### overwrite domain data if supplied 
if(!is.null(vpRm_crs)){
	vpRm$domain$crs <- vpRm_crs
}#end if(!is.null(vpRm_crs)){
if(!is.null(vpRm_ext)){
	vpRm$domain$ext <- vpRm_ext
}#end if(!is.null(vpRm_ext)){
if(!is.null(vpRm_time)){
	vpRm$domain$time <- vpRm_time
}#end if(!is.null(vpRm_time)){

return(vpRm)

}#end func set_domain
