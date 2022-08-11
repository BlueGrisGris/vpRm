#' Get_Stilt_Out_Filenames 
#' Get the footprint or trajectory filenames from a STILT output
#' Taken directly from R package AtmosfeaR <3

#' @param stilt_out_dir (chr): the path to a STILT out directory 
#' @param outtype (chr): One of ("foot","traj"). "foot" --> get the footprint output.  "traj" --> get the traj output.

#' @export
Get_Stilt_Out_Filenames <- function(stilt_out_dir,outtype){ 
	file_receps  <- list.files(file.path(stilt_out_dir,"by-id"))
	if(!outtype %in% c("foot","traj")){stop("outtype must be either foot or traj")} 
	if(outtype == "foot"){
		file_names <- file.path(stilt_out_dir, "by-id", file_receps, paste0(file_receps, "_foot.nc"))
	}#end if outtype == "foot"
	if(outtype == "traj"){
		file_names <- file.path(stilt_out_dir, "by-id", file_receps, paste0(file_receps, "_traj.rds"))
	}#end if outtype == "traj"
	return(file_names)
}#end func Get_Stilt_Out_Filenames

### make sure inputs that we expect to be rasterizableare 
sanitize_raster <- function(raster){
if(class(raster)[[1]] != "SpatRaster"){
	if(class(raster)[[1]] != "character"){
		stop("input must be either a terra::rasted land cover or a filepath to such")
	}#end if(!class(driver)[[1]] != c){
	raster <- terra::rast(raster)
}#end if(class(driver)[[1]]{
return(raster)
}#end func sanitize_driver

#' Save_Rast
#' Save a SpatRaster as a netcdf
#'
#' @param rast (SpatRaster): SpatRaster to be saved
#' @param filename (chr): filename to save to 
#'
#' @export 
Save_Rast <- function(rast, filename){
	suppressWarnings( ### warning when saving an empty netcdf
	terra::writeCDF( rast , filename = filename , overwrite = T )#end terra::writeCDF
	)#end suppressWarnings
	return(rast)
}#end Save_Rast <- function(rast, filename){

Print_Info <- function(rast){
	print(deparse(substitute(rast)))
	print(rast)
	print(terra::mem_info(rast))
	print(paste(terra::free_RAM()/1e6, "GB free"))
}#end func print info

### TODO: test?
set_vpRm_out_names <- function(vpRm, plate){
	field_time <- terra::time(plate)
	for(field_name in c("nee", "gee", "respir")){
		vpRm$dirs[[paste(field_name, "files", "dir", sep = "_")]] <- file.path( 
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
	}#end for dd
	return(vpRm)
}#end func
