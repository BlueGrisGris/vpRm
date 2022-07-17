test_that("does Tscalar() return correct values?", {
	expect_equal(round(Tscalar(Tair = 5, Tmin = 0, Tmax = 40),2),0.30)
	expect_equal(Tscalar(Tair = 25, Tmin = 0, Tmax = 40),1)
	expect_equal(round(Tscalar(Tair = 35, Tmin = 0, Tmax = 40),2),0.64 )
})#end test_that("does gen_templ() create a good template?", {

test_that("does Pscalar() return correct values?", {
	expect_equal(Pscalar(2,3,1), 0.5)
})#end test_that("does Tscalar() return correct values?", {

test_that("does Wscalar() return correct values?", {
	expect_equal(Wscalar(1,3) ,0.9)
})#end test_that("does Tscalar() return correct values?", {
