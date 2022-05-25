#' proc_lc
#' Convert Land cover data to match crs and extent to template

#' @param driver_filename (chr) file path to land cover data file to be processed

#' @export 
proc_lc <- function(driver_filename, templ_filename, proc_filename){
### touch lc driver data with rast
driver <- terra::rast(driver_filename)
templ <- terra::rast(templ_filename)

### right now domain will always be encompassed by LC, bc LC is for the \rq
goes_test <- terra::crop(goes,ext(proj_domain)*1.7)

processed <- driver

return(processed)

}#end func proc_lc


