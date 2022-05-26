data_dir <- system.file("test_data",package="vpRm",mustWork = T)
list.files(data_dir)
goes_filename <- file.path(data_dir, "goes_test.nc") 
file.exists(goes_filename)
goes <- terra::rast(goes_filename)
driver <- goes
plate_filename <- file.path(data_dir, "plate.nc")
file.exists(plate_filename)
plate_full <- terra::rast(plate_filename)
### TODO: do we want lubridate as dependency?
plate <- plate_full[[ lubridate::day( terra::time(plate_full))!=30 ]]

if(F){
length( which( terra::time(plate) %in% terra::time(driver))) != 0
}

test_that("does proc_simple_3d work on test goes data?", {
	proc_par <- proc_simple_3d(goes,plate)
	### dimensions of processed should match template
	expect_equal( dim(proc_par), dim(plate) ) 
	### every cell should have a value 
	expect_equal( length(which(!is.nan(terra::values(proc_par)))) , length(terra::values(plate)) )
}) #end test_that()

### TODO: test rap
### TODO: test error behavior

skip("something about testthat environment is causing this to fail on test(), but be ok if sent to terminal")
test_that("does proc_simple_3d throw the correct errors", {
	expect_error(proc_simple_3d(goes,plate_full), "There are times in plate that are not in driver")
}) #end test_that()
