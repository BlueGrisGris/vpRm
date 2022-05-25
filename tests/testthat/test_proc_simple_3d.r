vpRm_dir <- file.path("/tmp", "vpRm")
data_dir <- system.file("test_data",package="vpRm",mustWork = T)
init_vpRm(vpRm_dir)
driver_filename <- file.path(data_dir, "goes_test.nc")

file.exists(driver_filename)
#$gen_plate()



unlink(vpRm_dir,recursive=T)
