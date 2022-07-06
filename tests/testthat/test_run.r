# test_that("does run.vpRm produce the correct results?",{
	vpRm <- new_vpRm(
		vpRm_dir
		, lc_dir
		, isa_dir
		, temp_dir
		, par_dir
		, evi_dir
		, evi_extrema_dir
		, green_dir
		, plate_dir
		)#end new_vpRm 
	plate <- gen_plate(matchdomain, vpRm$dirs$lc_dir)
	Save_Rast(plate, vpRm$dirs$plate_dir)
	vpRm <- proc_drivers.vpRm(vpRm)
	# }) #end test_that("does run.vpRm produce the correct results?"{
