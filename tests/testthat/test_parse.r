test_that("does parse_modis_evi_times() return the correct dates", {
	evi_filenames <- c("MYD13A1.006__500m_16_days_EVI_doy2018361_aid0001.tif" , "MYD13A1.006__500m_16_days_EVI_doy2019009_aid0001.tif")
	parsed <- parse_modis_evi_times(evi_filenames)
	expected <- as.POSIXct(c("2018-12-26 19:00:00 EST" , "2019-01-08 19:00:00 EST"),tz = "")
	### lol wtf
	attributes(expected)[2] <- NULL

	expect_equal(parsed, expected)

})#end test_that("does parse_modis_evi_times() return the correct dates"){
