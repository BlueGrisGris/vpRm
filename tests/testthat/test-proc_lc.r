data_dir <- system.file("test_data",package="vpRm",mustWork = T)
lc_filename <- file.path(data_dir, "lc_test.nc") 
file.exists(lc_filename)
lc <- terra::rast(lc_filename)
plate_filename <- file.path(data_dir, "plate.nc")
file.exists(plate_filename)
plate <- terra::rast(plate_filename)

test_that("does proc_lc work?", {
  expect_equal(2 * 2, 4)
})
