test_that("does parse_modis_evi_times() return the correct dates", {
	evi_filenames <- c("MYD13A1.006__500m_16_days_EVI_doy2018361_aid0001.tif" , "MYD13A1.006__500m_16_days_EVI_doy2019009_aid0001.tif")
	parsed <- parse_modis_evi_times(evi_filenames)
	expected <- as.POSIXct(c("2018-12-26 19:00:00" , "2019-01-08 19:00:00"),tz = "")
	### lol wtf
	attributes(expected)[2] <- NULL

	expect_equal(parsed, expected)

})#end test_that("does parse_modis_evi_times() return the correct dates"){

test_that("does parse_herbie_hrrr_times() return the correct dates", {
	evi_filenames <- c("/n/wofsy_lab2/Users/emanninen/vprm/driver_data/hrrr_temperature/hrrr/20200627/suc_hrrr.t19z.wrfsfcf06.grib2")
	parsed <- parse_herbie_hrrr_times(evi_filenames)
	expected <- as.POSIXct("2020-06-27 19:00:00 EST",tz = "UTC")

	expect_equal(parsed, expected)

})#end test_that("does parse_herbie_hrrr_times() return the correct dates"){

test_that("does parse_stilt_times() return the correct dates", {
	stilt_filenames <- "/n/holylfs04/LABS/wofsy_lab/Lab/Everyone/for_Ethan/STILT_slantfoot/stilt_slant_hb_202012291900.nc"
	parsed <- parse_stilt_times(stilt_filenames)
	expected <- as.POSIXct("2020-12-29 19:00:00" ,tz = "UTC")

	expect_equal(parsed, expected)

})#end test_that("does parse_herbie_hrrr_times() return the correct dates"){
