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
#' @param SpatRaster (spatRaster): SpatRaster to be saved
#' @param filename (chr): filename to save to 
#'
#' @export 
Save_Rast <- function(SpatRaster, filename){
	suppressWarnings( ### warning when saving an empty netcdf
	terra::writeCDF(SpatRaster, filename = filename, overwrite = T )#end terra::writeCDF
	)#end suppressWarnings
	return(SpatRaster)
}#end Save_Rast <- function(rast, filename){

Dir_Create <- function(dir){
	if(!dir.exists(dir)){
		dir.create(dir, recursive = T, showWarnings = F)	
	}#end if dir.exists
}#end func Create_Dir
