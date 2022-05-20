#' Gen_Raster_Templ()
#' Creates the raster brick/stack/ netCDF4 structure that will be filled with processed driver data and VPRM NEE output. 
#' @param matchdomain 
#' @param lons ### NOT IMPLEMENTED 
#' @param lats ### NOT IMPLEMENTED 
#' @param times ### NOT IMPLEMENTED 
#' @param projection ### NOT IMPLEMENTED
#' @param vpRm_dir
#' @param outfile ### NOT IMPLEMENTED
#' @param verbose

#' @export
gen_templ <- function(
		      matchdomain = NULL
		      , lons = NULL
		      , lats = NULL
		      , times = NULL 
	     	      , xres = NULL
		      , yres = NULL
		      , projection = "+proj=longlat"
		      , vpRm_dir = "."
		      , outfile
		      , verbose = F
		      ){ #start func gen_templ

	if(!is.null(matchdomain)){
		stop("Specing coordinates is not yet implemented.  Supply matchdomain a file path with domain over which you want to run VPRM")
	} #end if !is.null matchdomain

	### make sure there is enough info provided to create a template
	if(!is.null(matchdomain)&( is.null(lons)| is.null(lats)|is.null(times)|is.null(xres)|is.null(yres) ) ){
		stop("If an example format is not provided via matchdomain, all of lon, lat, times, xres, yres must be provided")
	} #end if !is.null matchdomain
#######
### create template to match a given domain from a file, ie a stilt footprint.  
#######
	if(!is.null(matchdomain)){

	if(verbose){
	print(paste("Attempting to parse",matchdomain,"and create template"))
	}#end if verbose

	### check if matchdomain is a directory
	if(length(list.files(matchdomain)!=0)){
	filenames<- list.files(matchdomain)
	}#end if(length(list.files(matchdomain)!=0)){

	### read in data to match domain to using terra
	domain <- terra::rast(matchdomain)

	### TODO: Decide on projection plans
	### TODO: Look 1 more time for a way to have more than 3 dims in a terra::spatRaster
	### TODO: either empty domain, or create a new spat raster with same attributes 
	### TODO: save into init_vpRm() created dir processed

	}#if(!is.null(matchdomain)){
#######
### create template from given coordinates
### TO BE IMPLEMENTED
#######
return(NULL)
}#end func gen_templ
