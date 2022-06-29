test_that("does gee() calc gee correctly?", {
	#         expect_equal(gee(1,2,3,4,5,6,7,"OTH"), 0)
	expect_equal(gee(1,2,3,4,5,6,7,"DBF"), 720)
})#end test_that("does gee() calc gee correctly?", {

test_that("does respir calculate the correct respiration values?", {
	#         expect_equal(respir(tair = 1, alpha = 2, beta = 3, lc = "OTH", isa = .5, evi = .5),0)
	expect_equal(respir(tair = 1, alpha = 2, beta = 3, lc = "DBF", isa = .5, evi = .5), 2.5)
})#end test_that("does respir calculate the correct respiration values?", {
