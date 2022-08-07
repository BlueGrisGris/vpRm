
goes <- terra::rast(par_dir)
### TODO: the edge of test data is NaN 
which(is.nan(terra::values(goes[[15]])))

skip("going to switch to hrrr par")
test_that("does proc_3d work on test goes data?", {
	goes <- terra::rast(par_dir)
	plate <- terra::rast(plate_dir)
	proc_par <- proc_3d(goes,plate)
	### dimensions of processed should match template
	expect_equal( dim(proc_par), dim(plate) ) 
	### every cell should have a value 
	expect_equal( length(which(!is.nan(terra::values(proc_par)))) , length(terra::values(plate)) )
}) #end test_that()

skip("going to switch to hrrr temp, tho should work on rap too..")
test_that("does proc_3d work on test rap?", {
	goes <- terra::rast(par_dir)
	plate <- terra::rast(plate_dir)
	hrrr_temp <- terra::rast(temp_dir)
	proc_temp <- proc_3d(hrrr_temp,plate)
	### dimensions of processed should match template
	expect_equal( dim(proc_temp), dim(plate) ) 
	### every cell should have a value 
	expect_equal( length(which(!is.nan(terra::values(proc_temp)))) , length(terra::values(plate)) )
}) #end test_that()

### TODO: test rap
### TODO: test error behavior

skip("something about testthat environment is causing this to fail on test(), but be ok if sent to terminal")
test_that("does proc_3d throw the correct errors", {
	expect_error(proc_3d(goes,plate_full), "There are times in plate that are not in driver")
}) #end test_that()

if(F){
terra::values(processed)
terra:: time(plate)
yy <- which(terra::time(driver) %in% terra::time(plate))
xx <- processed[[yy]]
zz <- processed[[1]] 
ww <- terra::subset(processed, 1)
terra::values(xx)
terra::values(zz)
terra::values(ww)
}#end if F
