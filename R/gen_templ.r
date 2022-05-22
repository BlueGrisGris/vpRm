#' Gen_Raster_Templ()
#' Creates the raster brick/stack/ netCDF4 structure that will be filled with processed driver data and VPRM NEE output. 
#' @param matchdomain (chr) filepath(s) of geospatial data files readable by terra::rast to run vpRm over. 
#' @param lc_filename (chr) landcover data filepath
#' @param vpRm_dir (chr) filepath of the vpRm directory
#' @param verbose (bool) Print messages?

#' @export
gen_templ <- function(
		      matchdomain = NULL
		      , lc_filename  ### TODO: maybe it should be able to eat one already terra::rast'ed?
		      ### TODO: should it be able to convert individual xmin etc into a SpatExtent or should the user do that?
		      #                       , spatextect = NULL
		      #                       , xmin = NULL
		      #                       , xmax = NULL
		      #                       , ymin = NULL
		      #                       , ymax = NULL
		      #                            , xres = NULL
		      #                       , yres = NULL
		      #                       , times = NULL 
		      #                       , projection = "+proj=longlat"
		      , vpRm_dir = "." #TODO: i think this would be handled by the S3/4 class?
		      #                       , outfile
		      , verbose = F
		      ){ #start func gen_templ

if(is.null(matchdomain)){
	stop("Specing coordinates is not yet implemented.  Supply matchdomain a file path with domain over which you want to run VPRM")

### make sure there is enough info provided to create a template
### TODO: or could let partial user specs overwrite the input where they exist?
if(!is.null(matchdomain)&( is.null(lons)| is.null(lats)|is.null(times)|is.null(xres)|is.null(yres) ) ){
	stop("If an example format is not provided via matchdomain, all of lon, lat, times, xres, yres must be provided")
}#end if(!is.null(matchdomain)&( is.null(lons)| is.null(lats)|is.null(times)|is.null(xres)|is.null(yres) ) ){ #TODO:put back once lat/lons implemented

}#end if !is.null matchdomain

#########################
### create template to match a given domain from a file, ie a stilt footprint.  
#########################

if(!is.null(matchdomain)){

if(verbose){
print(paste("Attempting to parse",matchdomain,"and create template"))
### TODO: add to vpRm.log
}#end if verbose

### check if matchdomain is a directory
if(length(list.files(matchdomain)!=0)){
	### TODO: further sanitize inputs from dir
matchdomain<- list.files(matchdomain)
}#end if(length(list.files(matchdomain)!=0)){
### read in data to match domain to using terra
domain <- terra::rast(matchdomain)
### Take projection from landcover bc Steve said to.
lc <- terra::rast(lc_filename)
lc_crs <- terra::crs(lc)
### project domain into lc_crs so that the extent etc have meaning
proj_domain <- terra::project(domain, lc_crs)
### init the template.  
### crs to match landcover crs
### spatio temporal domain to match domain projected into lc_crs 
templ <- terra::rast(
		     nrows = dim(proj_domain)[1]	
		     , ncols = dim(proj_domain)[2]	
		     , nlyr = dim(proj_domain)[3]	
		     , time = terra::time(proj_domain)
		     , extent = terra::ext(proj_domain) 
		     , crs = lc_crs
	)#end terra::rast
}#if(!is.null(matchdomain)){

#########################
### create template from given coordinates
### TO BE IMPLEMENTED
#########################

#########################
### Save template to vpRm_dir/processed for each of data sources
#########################

### save into init_vpRm() created dir processed
processed_filenames <- c("lc.nc","isa.nc","par.nc","veg.nc","temp.nc") 
for(p_f in processed_filenames){
### TODO: add to vprm.log/ do 
### warning when saving an empty netcdf
suppressWarnings(
terra::writeCDF(
		templ
		, filename = file.path(vpRm_dir,"processed",p_f)
		, overwrite = T 
	)#end terra::writeCDF
)#end suppressWarnings
}#end for(p_f in processed_filenames){
return(templ)
}#end func gen_templ
