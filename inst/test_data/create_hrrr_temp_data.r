library(terra)
library(ncdf4)

data_dir <- system.file("test_data", package="vpRm",mustWork=T)

rap_grb2_filename<- file.path("~/Downloads/rap_test_grb2",list.files("~/Downloads/rap_test_grb2"))[1]
rap_filename <- file.path("~/Downloads/rap_test",list.files("~/Downloads/rap_test"))[1]

file.exists(rap_filename)
rap <- rast(rap_filename)

file.exists(rap_grb2_filename)
rap_grb2 <- rast(rap_grb2_filename)

head(names(rap))
plot(rap[[which(names(rap) == "TMP_P0_L1_GLC0")]])

varnames(rap_grb2)
names(rap_grb2)

nc <- nc_open(rap_filename)
names(nc$var)


nc_grb2	<- nc_open(rap_grb2_filename)

plot(rap)
names(rap)
# rap <- rap[[names(rap) == "ssi"]]

### see extent of test_stilt in rap_crs so that can pick somethign a bit bigger for rap_test 
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain1 <- file.path(stilt_dir,"by-id","01","01_foot.nc")
domain <- rast(matchdomain1)
proj_domain <- project(domain, crs(rap))

### hmmm
plot(rap)

rap_test <- terra::crop(rap,ext(proj_domain)*1.7)

plot(proj_domain)
plot(rap_test)

rap_test <- aggregate(rap_test,fact = 20, fun="mean")

plot(rap_test)

# writeCDF(rap_test, file.path("~/Downloads", "rap_test.nc"), overwrite=T)

### The index of each variable changes both converting grb2 to nc and year to year ....
hrrr_filename <- file.path("~/Downloads","hrrr.nc")
file.exists(hrrr_filename)
hrrr <- rast(hrrr_filename)
names(hrrr[[names(hrrr) == "TMP_2maboveground"]])
names(hrrr)[[106]]

plot(hrrr[[names(hrrr) == "TMP_2maboveground"]])

### terra::rast directly on the grb2 is no good
hrrr_grb2_filename <- file.path("~/Downloads","hrrr.t00z.wrfsfcf00.grib2")
file.exists(hrrr_grb2_filename)
hrrr_grb2 <- rast(hrrr_grb2_filename)
names(hrrr_grb2[[71]])
plot(hrrr_grb2[[70]])

stilt_names <- AtmosfeaR::Get_Stilt_Out_Filenames("stilt_test","foot")[[1]]
terra::rast(stilt_names )

################
#### Actually create the test temp from HRRR
################

hrrr_dir <- "~/Desktop/hrrr_temp_test/"
hrrr_filenames <- file.path(hrrr_dir, list.files(hrrr_dir,pattern = ".nc"))

hrrr <- rast(hrrr_filenames)
print(hrrr)
### for some reason extra vars messed up like it grabbed a different variable?
plot(hrrr[[1]])
### just take good for now, learn about rast later
plot(hrrr[[1:8]])
hrrr <- hrrr[[1:8]]

### see extent of test_stilt in goes_crs so that can pick somethign a bit bigger for goes_test 
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain1 <- file.path(stilt_dir,"by-id","01","01_foot.nc")
domain <- rast(matchdomain1)
proj_domain <- project(domain, crs(hrrr))

hrrr_test <- terra::crop(hrrr,ext(proj_domain)*170)

plot(hrrr_test)
plot(proj_domain)

# hrrr_test <- aggregate(hrrr_test,fact = 20, fun="mean")

# plot(hrrr_test)

writeCDF(hrrr_test, file.path("~/Downloads", "hrrr_test.nc"), overwrite=T)
