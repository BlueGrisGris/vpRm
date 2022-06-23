test_that("does gee() calc gee correctly?", {
	expect_equal(0, gee(1,2,3,4,5,6,7,"OTH"))
	expect_equal(720, gee(1,2,3,4,5,6,7,"DBF"))
})#end test_that("does gee() calc gee correctly?", {

test_that("does respir calculate the correct respiration values?", {
	expect_equal(0,respir <- respir(tair = 1, alpha = 2, beta = 3, lc = "OTH", isa = .5, evi = .5))
	expect_equal(2.5,respir(tair = 1, alpha = 2, beta = 3, lc = "DBF", isa = .5, evi = .5))
})#end test_that("does respir calculate the correct respiration values?", {
