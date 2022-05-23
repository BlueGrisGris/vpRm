library(terra)
library(ncdf4)


data_dir <- system.file("test_data", package="vpRm",mustWork=T)

# goes_filename <- file.path("~/Desktop/research/phd/em27_carbfor/vprm/NLCD/LC/ngoesd_2019_land_cover_l48_20210604.img")
goes_filename <- file.path("~/Downloads/goes_test",list.files("~/Downloads/goes_test"))
goes <- rast(goes_filename)
plot(goes)
names(goes)
goes <- goes[[names(goes) == "ssi"]]
goessds <- sds(goes_filename)

### see extent of test_stilt in goes_crs so that can pick somethign a bit bigger for goes_test 
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain1 <- file.path(stilt_dir,"by-id","01","01_foot.nc")
domain <- rast(matchdomain1)
proj_domain <- project(domain, crs(goes))

### hmmm
plot(goes)

goes_test <- terra::crop(goes,ext(proj_domain)*1.7)

plot(proj_domain)
plot(goes_test)

goes_test <- aggregate(goes_test,fact = 20, fun="mean")

plot(goes_test)

writeCDF(goes_test, file.path("~/Downloads", "goes_test.nc"), overwrite=T)
