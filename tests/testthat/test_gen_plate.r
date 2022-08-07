test_that("does gen_templ() create a good template?", {
### get stilt filenames
		  # templ <- gen_plate(matchdomain,lc_filename, vpRm_dir)
	templ <- gen_plate(matchdomain,lc_dir)
	### TODO: understand these magic numbers that come from projecting matchdomain
	expect_equal(dim(templ),c(21,17,19))
	#         expect_true(file.exists(file.path(vpRm_dir, "processed", "plate.nc" )))
})#end test_that("does gen_templ() create a good template?", {

unlink(vpRm_dir,recursive=T)
