test_that("does gee() calc gee correctly?", {
	expect_equal(round(gee(1,2,3,4,5,6,7)), 388)
})#end test_that("does gee() calc gee correctly?", {

test_that("does respir calculate the correct respiration values?", {
	expect_equal(respir(tair = 1, ALPHA = 2, BETA = 3, lc = "DBF", ISA = .5, evi = .5, tlow = -10), 2.5)
})#end test_that("does respir calculate the correct respiration values?", {
