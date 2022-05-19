#' Gen_Raster_Templ()
#' Creates the raster brick/stack/ netCDF4 structure that will be filled with processed driver data and VPRM NEE output. 
#' @param matchdomain 
#' @param lons 
#' @param lats 
#' @param times 
#' @param rojection

#' @export
gen_templ <- function(matchdomain = NULL, lons = NULL, lats = NULL, times = NULL, xres = NULL, yres = NULL, projection = "+proj=longlat", verbose = F){
	### make sure there is enough info provided to create a template
	if(!is.null(matchdomain)&( is.null(lons)| is.null(lats)|is.null(times) ) ){
		stop("If an example format is not provided via matchdomain, all of lon, lat, times, xres, yres must be provided")
	} #end if !is.null matchdomain
#######
### create template to match a given domain 
#######
	if(!is.null(matchdomain)){
		if(verbose){
		print(paste0("Attempting to parse",matchdomain,"and create template to match it"))
		}#end if verbose

		### check if matchdomain is a directory
		if(length(list.files(matchdomain)!=0)){
			### make sure the directory is a stilt out directory
			if(length(list.files(matchdomain, pattern = "by-id"))!=0){
				stop("match template is a directory.  match template does not appear to be a uataq STILT out directory, which are only directories currently supported. If you think match template is a uataq STILT out directory, check for matchdomain/by-id")  
			}#end if(list.files(matchdomain,

			Get_Stilt_Out_Filename()
		}#end if length list.files matchdomain
	} #end if is.null matchdomain	
	
	return("hello!")
	file.exists
}#end function Gen_Raster_Templ()
