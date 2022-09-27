skip("not rdy")
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
		, verbose = T
		)#end new_vpRm 
	domain <- terra::rast(domain_dir)
	domain <- domain[[5:8]]

	vpRm <- set_domain(vpRm, domain)
	vpRm <- proc_drivers(vpRm)
	vpRm <- run_vpRm(vpRm)

	expect_equal( dim(terra::rast( vpRm$dirs$nee_files_dir)) , dim(plate) )
	expect_equal( dim(terra::rast(vpRm$dirs$gee_files_dir)) , dim(plate) )
	expect_equal( dim(terra::rast(vpRm$dirs$respir_files_dir)) , dim(plate) )
}) #end test_that("does run.vpRm produce the correct results?"{
