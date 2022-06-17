test_that("does gee() calc gee correctly?", {
	expect_equal(0, gee(1,2,3,4,5,6,7,"OTH"))
	expect_equal(720, gee(1,2,3,4,5,6,7,"DBF"))
})#end test_that("does gee() calc gee correctly?", {
