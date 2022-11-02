#' setup_herbie  
#' Set up herbie for downloading HRRR meteorology files. 
#' conda is a prerequisite. 
#' This is taken from the herbie github: https://github.com/blaylockbk/Herbie 
#'  
#' @export
setup_herbie <- function(){
	### TODO: check that python version 3.10
	system("conda install -c conda-forge herbie-data")
	system("wget https://github.com/blaylockbk/Herbie/raw/main/environment.yml")
	system("conda env create -f environment.yml")
	system("rm environment.yml")
	system("source activate herbie")

	return(NULL)

}#end func setup_herbie

#' download_hrrr  
#' download HRRR files using the herbie python.
#' conda is a prerequisite. 
#' herbie github: https://github.com/blaylockbk/Herbie 
#'  
#' @param times ()  
#' @param vpRm (vpRm, character) An object of class vpRm, or a file path to a vpRm control file.
#'  
#' @export
download_hrrr <- function(times = NULL, vpRm = NULL){
	if(!is.null(vpRm)){
		if(class(vpRm) %in% c("character", "vpRm")){stop("parameter vpRm must be of class vpRm or path to control file of such")}
		#                 TODO: if(class(vpRm) == "character"){read_vpRm()}
		times <- vpRm$domain$time
	}#end if(!is.null(vpRm)){

	system("source activate herbie", ignore.stderr = T)
	system(paste("python", system.file("fetch_scripts/hrrr_par_temp.py", package = "vpRm", mustWork = T), paste0("$",times)))
	system("source deactivate herbie", ignore.stderr = T)
}#end func download_hrrr

times <- seq(as.POSIXct("2021-01-01 00:00:00"), as.POSIXct("2021-01-01 03:00:00"), by="hour")
download_hrrr(times)

# sink("~/Desktop/vprm.txt")
# print(xx)
# sink()
