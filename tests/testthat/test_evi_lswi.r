test_that("does evi calculate the correct value?", {
	expect_equal( 0.294, round(evi(1,2,3), 3) )
})#end testthat("does evi calculate the correct value?", {

test_that("does lswi calculate the correct value?", {
	expect_equal( -.5, lswi(1,3) )
})#end testthat("does evi calculate the correct value?", {
