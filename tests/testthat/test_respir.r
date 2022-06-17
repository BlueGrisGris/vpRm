test_that("does respir calculate the correct respiration values?", {
	expect_equal(0,respir <- respir(tair = 1, alpha = 2, beta = 3, lc = "OTH", isa = .5, evi = .5))
	expect_equal(2.5,respir(tair = 1, alpha = 2, beta = 3, lc = "DBF", isa = .5, evi = .5))
})#end test_that("does respir calculate the correct respiration values?", {
