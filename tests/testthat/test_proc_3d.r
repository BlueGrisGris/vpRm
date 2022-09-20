# skip("going to switch to hrrr par")
test_that("does proc_3d work on test hrrr temp data?", {
	temp <- terra::rast(temp_dir)
	plate <- terra::rast(plate_dir)
	expect_error( temp_par <- proc_3d(temp,plate) , "There are times in plate that are not in driver")
	### fake temp data is only for 2020-01
	plate <- plate[[1:8]]
	temp_proc <- proc_3d(temp,plate)
	### dimensions of processed should match template
	expect_equal( dim(temp_proc), dim(plate) ) 
	### every cell should have a value 
	expect_equal( length(which(!is.nan(terra::values(temp_proc)))) , length(terra::values(plate)) )
}) #end test_that()
