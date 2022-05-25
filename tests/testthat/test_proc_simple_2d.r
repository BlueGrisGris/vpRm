data_dir <- system.file("test_data",package="vpRm",mustWork = T)
list.files(data_dir)
lc_filename <- file.path(data_dir, "lc_test.nc") 
file.exists(lc_filename)
lc <- terra::rast(lc_filename)
plate_filename <- file.path(data_dir, "plate.nc")
file.exists(plate_filename)
plate <- terra::rast(plate_filename)

test_that("does proc_simple_2d work on lc?", {
proc_lc <- proc_simple_2d(lc,plate)
### nrows and ncols should match, but only 1 layer for land cover and 19 time layers for template
testthat::expect_equal(c(dim(proc_lc)[c(1,2)],1),c(dim(plate)[c(1,2)],1)   )
}) #end test_that()

### TODO: test proc_simple_2d on isa data
