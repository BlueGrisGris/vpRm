### TODO: I doubt this setup scheme is robust.  Can also direct user to herbie github

#' setup_herbie  
#' Set up herbie for downloading HRRR meteorology files. 
#' An installation of conda is a prerequisite. 
#' if this fails to automatically setup the 
#' This is taken from the herbie github: https://github.com/blaylockbk/Herbie 
#'  
#' @export
setup_herbie <- function(){
	### TODO: check that python version 3.10
	system("conda install -c conda-forge herbie-data")
	### TODO: do we need the below env managament to do the unholy download?
	#         system("wget https://github.com/blaylockbk/Herbie/raw/main/environment.yml")
	#         system("conda env create -f environment.yml")
	#         system("rm environment.yml")
	#         system("source activate herbie")

	return(NULL)

}#end func setup_herbie

#' download_hrrr  
#' download HRRR files using the herbie python.
#' To enable, must run vpRm::setup_herbie()
#' herbie github: https://github.com/blaylockbk/Herbie 
#'  
#' @param times (POSIXct): 
#' @param vpRm (vpRm, character): An object of class vpRm, or a file path to a vpRm control file.
#'  
#' @export
download_hrrr <- function(times = NULL, vpRm = NULL, download_dir = "."){
	### use times from vpRm object if one is provided
	if(!is.null(vpRm)){
		if(class(vpRm) %in% c("character", "vpRm")){stop("parameter vpRm must be of class vpRm or path to control file of such")}
		#                 TODO: if(class(vpRm) == "character"){read_vpRm()}
		times <- vpRm$domain$time
	}#end if(!is.null(vpRm)){

	### don't even have to call the conda env?????
	#         reticulate::use_condaenv("herbie")

	herbie <- reticulate::import("herbie")
	pd <- reticulate::import("pandas")

	### this is unholy
	### download temp
	herbie$tools$fast_Herbie_download(
		DATES = pd$to_datetime(times)
		, model='hrrr'
		, product='sfc'
		, fxx=as.integer(0)
		, searchString = "TMP:2 m"
		, save_dir = file.path(download_dir, "hrrr_temp")
	)#end fast_Herbie_download
	### download par
	herbie$tools$fast_Herbie_download(
		DATES = pd$to_datetime(times)
		, model='hrrr'
		, product='sfc'
		, fxx=as.integer(0)
		, searchString = "DSWRF"
		, save_dir = file.path(download_dir, "hrrr_par")
	)#end fast_Herbie_download

	return(NULL)
}#end func download_hrrr
