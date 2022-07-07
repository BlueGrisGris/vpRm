test_that("does parse_doy_from_evi() return the correct doy?", {
	evi_filenames <- "MYD13A1.006__500m_16_days_EVI_doy2019361_aid0001.tif" 
	expect_equal( parse_doy_from_evi(evi_filenames[1]),  2019361)
})#end test_that("does parse_doy_from_evi() return the correct doy?", {
