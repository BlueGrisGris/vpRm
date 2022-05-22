tests_dir <- system.file("tests",package="vpRm")
data_dir <- file.path(tests_dir, "data") 
stilt_dir <- file.path(data_dir, "stilt_test")

skip("this passes on test(), but on check() says do not have permission to create the vpRm directory...")
test_that("does gen_templ() create a good template?", {
### get stilt filenames
matchdomain <- Get_Stilt_Out_Filenames(stilt_dir,"foot")
### rast lc 
lc_filename <- file.path(data_dir, "lc_test.nc") 
lc <- terra::rast(lc_filename)
vpRm_dir <- file.path(data_dir, "vpRm")
init_vpRm(vpRm_dir )
templ <- gen_templ(matchdomain,lc_filename, vpRm_dir)
# xx <- terra::rast(matchdomain)
# terra::plot(xx[[1]])
# terra::plot(templ[[1]])
	### TODO: understand these magic numbers that come from projecting matchdomain
	expect_equal(dim(templ),c(21,17,19))
})
unlink(vpRm_dir,recursive=T)
