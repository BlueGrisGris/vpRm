tests_dir <- system.file("tests",package="vpRm")
# skip("this passes on test(), but on check() says do not have permission to create the vpRm directory...")
### test init_vpRm()
### this might be excessive testing
test_that("does init_vpRm create the correct directory structure?",{

	directory <- file.path("/tmp","test_init_vpRm")
	init_vpRm(directory)

	expect_equal(
	file.exists(
		directory
		, file.path(directory,"driver_data")
		, file.path(directory,"driver_data","veg_index")
		, file.path(directory,"driver_data","par")
		, file.path(directory,"driver_data","surface_temp")
		, file.path(directory,"driver_data","green_season")
		, file.path(directory,"driver_data","landcover")
		, file.path(directory,"driver_data","permeability")

		, file.path(directory,"processed")

		, file.path(directory,"output")
		)#end file.exists

		, rep(T, 10)
	)#end expect equal	

	### remove created directories	
	unlink(directory,recursive=T)

})#end test_that
