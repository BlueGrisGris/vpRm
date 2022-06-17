test_that("does Tscalar() return correct values?", {
	expect_equal(0.4375, Tscalar(Tair = 5, Tmin = 0, Tmax = 40))
	expect_equal(1, Tscalar(Tair = 25, Tmin = 0, Tmax = 40))
	expect_equal(0.875, Tscalar(Tair = 35, Tmin = 0, Tmax = 40))
})#end test_that("does gen_templ() create a good template?", {

test_that("does Pscalar() return correct values?", {
	expect_equal(0.5, Pscalar(2,3,1))
})#end test_that("does Tscalar() return correct values?", {

test_that("does Wscalar() return correct values?", {
	expect_equal(0.5, Wscalar(1,3))
})#end test_that("does Tscalar() return correct values?", {
