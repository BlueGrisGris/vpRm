if(F){
test_that("does download_hrrr suggest the correct filenames?", {

})#end	test_that("does download_hrrr suggest the correct filenames?"){

test_that("does download_landsat suggest the correct filenames?", {
	vpRm <- new_vpRm(vpRm_dir = "/tmp/vprm")
	vpRm$dirs$landsat_dir <- "/tmp/vprm/landsat"
	stilt <- terra::rast( Get_Stilt_Out_Filenames(stilt_dir, "foot"))
	vpRm <- set_domain(vpRm, stilt)

})#end	test_that("does download_hrrr suggest the correct filenames?"){
}#end if F
