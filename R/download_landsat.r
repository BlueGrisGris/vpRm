#' usgs_credentials
#' Store USGS Earth Explorer credentials using the R package keyring:
#' Create a USGS Earth Explorer Account here:
#' https://earthexplorer.usgs.gov
#' keyring: https://github.com/cran/keyring
#'
#' @param usgs_username (chr): Your USGS username
#' @param usgs_password (chr): Your USGS password
#'
#' @export
usgs_credentials <- function(usgs_username,usgs_password){
	keyring::key_set_with_value(
		service = "vpRm_usgs_keyring"
		, username = usgs_username 
		, password = usgs_password 
	)#end keyring::key_set_with_value(
	return(NULL)
}#end func usgs_credentials

#' download_landsat
#' Download landsat reflectance data, mosaic and cloud screen, and calculate EVI and LSWI ratios over the domain of a vpRm object 
#'  
#' @param vpRm (vpRm): The vpRm object for which download LSWI reflectance data
#' 
#' @export 
download_landsat <- function(vpRm){

	RGISTools::lsDownSearch(
		satellite = "ls7" 
		### TODO: these time are likely not correct
		#                 , startDate = min(vpRm$domain$time)
		#                 , endDate = max(vpRm$domain$time)
		, extent = raster::raster(
			terra::rast(
				ext = vpRm$domain$ext
				, crs = vpRm$domain$crs
				, resolution = vpRm$domain$res
			)#end terra::rast
		)#end raster::raster
		, startDate = as.Date("2019-01-01", "%Y-%m-%d")
		, endDate = as.Date("2019-01-16", "%Y-%m-%d")
		### TODO: make a landsat directory
		, AppRoot = vpRm$dirs$landsat_data
		, lvl = 1
		, verbose = T
		, raw.rm = F
		, username = keyring::key_list()[keyring::key_list()$service == "vpRm_usgs_keyring", "username"]
		, password = keyring::key_get("vpRm_usgs_keyring")
	)#end lsDownSearch(

	### TODO: cloud filter scenes
	### TODO: mosaic

	### TODO: calculate EVI
	### TODO: calculate LSWI

	### TODO: remove landsat scene and mosaic geotiffs

	return(NULL)
} #end func download landsat

