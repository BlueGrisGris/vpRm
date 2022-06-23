test_that("does new_vpRm() make the correct object?",{
	vpRm <- new_vpRm(vpRm_dir)
	expect_equal("vpRm",class(vpRm))
})#end

unlink(vpRm_dir,recursive=T)
