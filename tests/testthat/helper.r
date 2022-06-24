### Do not know the difference between helper files and setup files
### used in many tests
data_dir <- system.file("test_data",package="vpRm",mustWork = T)
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain <- Get_Stilt_Out_Filenames(stilt_dir,"foot")

lc_dir <- file.path(data_dir, "lc_test.nc") 
isa_dir <- file.path(data_dir, "isa_test.nc") 
temp_dir <- file.path(data_dir, "hrrr_temp_test.nc") 
par_dir <- file.path(data_dir, "goes_test.nc") 
evi_dir <- file.path(data_dir, "evi_test.nc") 
green_dir <- file.path(data_dir, "greenup_test.nc") 
plate_dir <- file.path(data_dir, "plate.nc") 

vpRm_dir <- file.path("/tmp", "vpRm")
