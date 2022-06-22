### system.file has inconsistent, unadvertised behavior w/r/t package root, inst/.  between r console, test(), check()
data_dir <- system.file("test_data",package="vpRm",mustWork = T)
# print(data_dir)
stilt_dir <- file.path(data_dir, "stilt_test")
# print(stilt_dir)

vpRm_dir <- file.path("/tmp", "vpRm")

### rast lc 
lc_filename <- file.path(data_dir, "lc_test.nc") 
lc <- terra::rast(lc_filename)
init_vpRm(vpRm_dir)

matchdomain <- Get_Stilt_Out_Filenames(stilt_dir,"foot")

test_that("does gen_templ() create a good template?", {
### get stilt filenames
		  # templ <- gen_plate(matchdomain,lc_filename, vpRm_dir)
	templ <- gen_plate(matchdomain,lc_filename)
	### TODO: understand these magic numbers that come from projecting matchdomain
	expect_equal(dim(templ),c(21,17,19))
	#         expect_true(file.exists(file.path(vpRm_dir, "processed", "plate.nc" )))
})#end test_that("does gen_templ() create a good template?", {

unlink(vpRm_dir,recursive=T)
