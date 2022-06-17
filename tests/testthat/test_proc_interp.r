data_dir <- system.file("test_data",package="vpRm",mustWork = T)
list.files(data_dir)
### for testing
get_test_data <- function(filename){
	test_data_filename <- file.path(data_dir, filename)
	#         print(paste(test_data_filename, "exists", file.exists(test_data_filename)))
	test_data <- terra::rast(test_data_filename)
	return(test_data)
}#end func get_test_data.r

plate <- get_test_data("plate.nc")

# landsat <- landsat("plate.nc")


skip("not done")
test_that("does proc_interp work on test landsat data?", {
	proc_par <- proc_simple_3d(goes,plate)
	### dimensions of processed should match template
	expect_equal( dim(proc_par), dim(plate) ) 
	### every cell should have a value 
	expect_equal( length(which(!is.nan(terra::values(proc_par)))) , length(terra::values(plate)) )
}) #end test_that()
