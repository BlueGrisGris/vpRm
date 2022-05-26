data_dir <- system.file("test_data",package="vpRm",mustWork = T)
list.files(data_dir)

get_test_data <- function(filename){
	test_data_filename <- file.path(data_dir, filename)
	#         print(paste(test_data_filename, "exists", file.exists(test_data_filename)))
	test_data <- terra::rast(test_data_filename)
	return(test_data)
}#end func get_test_data.r

plate_full <- get_test_data("plate.nc")
### TODO: do we want lubridate as dependency?
plate <- plate_full[[ lubridate::day( terra::time(plate_full))!=30 ]]

goes <- get_test_data("goes_test.nc")
terra::plot(goes[[15]])
### TODO: the edge of test data is NaN 
which(is.nan(terra::values(goes[[15]])))
test_that("does proc_simple_3d work on test goes data?", {
	proc_par <- proc_simple_3d(goes,plate)
	### dimensions of processed should match template
	expect_equal( dim(proc_par), dim(plate) ) 
	### every cell should have a value 
	expect_equal( length(which(!is.nan(terra::values(proc_par)))) , length(terra::values(plate)) )
}) #end test_that()

hrrr_temp <- get_test_data("hrrr_temp_test.nc")
### TODO: units aren't working???
terra::units(hrrr_temp)
### TODO: the edge of test data is NaN 
plate <- plate_full[[terra::time(plate_full) %in% terra::time(hrrr_temp)]]

test_that("does proc_simple_3d work on test rap?", {
	proc_temp <- proc_simple_3d(hrrr_temp,plate)
	### dimensions of processed should match template
	expect_equal( dim(proc_temp), dim(plate) ) 
	### every cell should have a value 
	expect_equal( length(which(!is.nan(terra::values(proc_temp)))) , length(terra::values(plate)) )
}) #end test_that()

### TODO: test rap
### TODO: test error behavior

skip("something about testthat environment is causing this to fail on test(), but be ok if sent to terminal")
test_that("does proc_simple_3d throw the correct errors", {
	expect_error(proc_simple_3d(goes,plate_full), "There are times in plate that are not in driver")
}) #end test_that()
