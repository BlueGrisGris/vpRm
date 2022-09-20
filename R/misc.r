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
		stop("Input must be either a terra::spatRaster or a filepath to geospatial data readable by terra::rast()")
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

### TODO: make it pad zeros correctly
### TODO: test?
out_field_filename <- function(field_name, field_time){
		field_filename <- paste0(
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
		, field_name 
		, ".nc"
		)#end paste0
	return(field_filename)
}#end func out_field_filename

save_co2_field <- function(ff){

	field_name <- names(ff)[1]
	field_time <- terra::time(ff)

	field_filename <- file.path( 
		vpRm$dirs[[paste(field_name, "dir", sep = "_")]]
		, out_field_filename(field_name, field_time)
	)#end file.path

	terra::writeCDF(
			ff
			, filename = field_filename
			, varname = field_name
			, longname = paste(field_name, "CO2 flux")
			, zname = "time"
			, unit = "micromol CO2 m-2 s-1"
			, overwrite = T
			, prec = "double"
	)#end writeCDF
	return(NULL)
}#end func save_co2_field

