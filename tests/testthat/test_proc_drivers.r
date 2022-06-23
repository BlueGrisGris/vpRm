test_that("does process_vpRm() make result in correct dims?",{
	vpRm <- new_vpRm(vpRm_dir, lc_dir, temp_dir, par_dir, evi_dir, green_dir)
	plate <- gen_plate(matchdomain, vpRm$dirs$lc_dir)
	Save_Rast(plate, vpRm$dirs$plate_dir)
	vpRm <- proc_drivers.vpRm(vpRm)

	### test that the processed drivers have same dimensions as the plate 
	### TODO:

})#end test_that("does process_vpRm() work correctly?",{
# unlink("/temp/vpRm")

### TODO: test error when there is times/ spaces in driver not in the plate
