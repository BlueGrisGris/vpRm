#### TODO: make it a method that is optionally called on vpRm() helper 

#' vpRm_init
#' Initialize directory structure for vpRm

#' @param directory (chr) filepath of the root of the vpRm directory tree

#' @export
init_vpRm <- function(directory){
	dir.create(directory)

	dir.create(file.path(directory,"driver_data"))
	dir.create(file.path(directory,"driver_data","veg_index"))
	dir.create(file.path(directory,"driver_data","par"))
	dir.create(file.path(directory,"driver_data","surface_temp"))
	dir.create(file.path(directory,"driver_data","green_season"))
	dir.create(file.path(directory,"driver_data","landcover"))
	dir.create(file.path(directory,"driver_data","permeability"))

	dir.create(file.path(directory,"processed"))

	dir.create(file.path(directory,"output"))

	return(directory)

}#end function vpRm_init
