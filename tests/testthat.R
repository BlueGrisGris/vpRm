library(testthat)
library(vpRm)

### used in many tests
data_dir <- system.file("test_data",package="vpRm",mustWork = T)
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain <- Get_Stilt_Out_Filenames(stilt_dir,"foot")

lc_dir <- file.path(data_dir, "lc_test.nc") 
temp_dir <- file.path(data_dir, "hrrr_temp_test.nc") 
par_dir <- file.path(data_dir, "par_test.nc") 
evi_dir <- file.path(data_dir, "evi_test.nc") 
green_dir <- file.path(data_dir, "greendown_test.nc") 
plate_dir <- file.path(data_dir, "plate.nc") 

print("hello")
vpRm_dir <- file.path("/tmp", "vpRm")

test_check("vpRm")
