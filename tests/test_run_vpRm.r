test_that("does run_vpRm() caclulate VPRM correctly?"{
	vpRm <- new_vpRm(vpRm_dir, lc_dir, temp_dir, par_dir, evi_dir, green_dir)
	plate <- gen_plate(matchdomain, vpRm$dirs$lc_dir)
	Save_Rast(plate, vpRm$dirs$plate_dir)
	vpRm <- proc_drivers.vpRm(vpRm)

	run.vpRm(vpRm)


})#end test_that("does run_vpRm() caclulate VPRM correctly?"{
