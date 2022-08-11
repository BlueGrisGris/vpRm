# skip("the test driver filenames are messed up for the parsers...")
test_that("does run_vpRm produce the correct results?",{
	vpRm <- new_vpRm(
		vpRm_dir
		, lc_dir
		, isa_dir
		, temp_dir
		, dswrf_dir
		, evi_dir
		, evi_extrema_dir
		, green_dir
		, verbose = F
		)#end new_vpRm 
	plate <- gen_plate(matchdomain, vpRm$dirs$lc_dir)
	plate <- plate[[5:8]]
	Save_Rast(plate, vpRm$dirs$plate_dir)
	vpRm <- set_vpRm_out_names(vpRm, plate)
	vpRm <- proc_drivers(vpRm)
	vpRm <- run_vpRm(vpRm)
	expect_equal( dim( terra::rast( vpRm$dirs$nee_files_dir)) , dim(plate) )
	expect_equal( dim(terra::rast(vpRm$dirs$gee_files_dir)) , dim(plate) )
	expect_equal( dim(terra::rast(vpRm$dirs$respir_files_dir)) , dim(plate) )
}) #end test_that("does run.vpRm produce the correct results?"{
