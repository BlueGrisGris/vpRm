data_dir <- system.file("test_data",package="vpRm",mustWork = T)
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain <- Get_Stilt_Out_Filenames(stilt_dir,"foot")

lc_dir <- file.path(data_dir, "lc_test.nc") 

vpRm_dir <- file.path("/tmp", "vpRm")

test_that("does new_vpRm() make the correct object?",{
	vpRm <- new_vpRm(vpRm_dir,matchdomain, lc_dir)
	expect_equal("vpRm",class(vpRm))
})#end


unlink(vpRm_dir,recursive=T)
