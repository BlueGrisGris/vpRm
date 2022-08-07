test_that("does green() calculate the growing season correctly",{
	evi <- terra::rast(evi_dir)
	greenupdown <- green(evi)
	expect_equal( c(terra::nrow(greenupdown), terra::ncol(greenupdown), terra::nlyr(greenupdown)) 
		     , c(terra::nrow(greenupdown), terra::ncol(greenupdown), terra::nlyr(greenupdown)) 
	)#end expect_equal
})#end test_that("does green() calculate the growing season correctly",{
