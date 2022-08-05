library(terra)
### LC data retrieved from https://www.mrlc.gov/data
### LC data retrieved from https://www.mrlc.gov/data

data_dir <- system.file("test_data",package="vpRm")

# lc_filename <- file.path("~/Desktop/research/phd/em27_carbfor/vprm/NLCD/LC/nlcd_2019_land_cover_l48_20210604.img")
lc_filename <- file.path("/n/wofsy_lab2/Users/emanninen/vprm/driver_data/nlcd/lc/nlcd_2019_land_cover_l48_20210604.img")
file.exists(lc_filename)
lc <- rast(lc_filename)

### see extent of test_stilt in lc_crs so that can pick somethign a bit bigger for lc_test 
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain1 <- file.path(stilt_dir,"by-id","202001310500_-72.1898_42.5331_364","202001310500_-72.1898_42.5331_364_foot.nc")
domain <- rast(matchdomain1)
proj_domain <- project(domain, crs(lc))

test_match_crs <- rast(crs = crs(lc), res = 80, ext = .1*ext(lc)) 
values(test_match_crs) <- 1:ncell(test_match_crs)
plot(test_match_crs)

ext(lc)
test_extent <- .1*ext(lc)

crop_lc <- terra::crop(lc , test_extent)
plot(crop_lc)
library(raster)

lc_raster <- raster(lc_filename)

resample_lc <- resample(lc, test_match_crs, "near")
sessionInfo()
plot(resample_lc)
plot(lc)

### hmmm
plot(lc, type = "classes")

raster_lc <- raster::raster(lc_filename)
terra::rast(lc_filename)

raster::plot(raster_lc)

lc_test <- terra::crop(lc,ext(test_match_crs))

plot(proj_domain)
plot(lc_test,type= "classes")

lc_test <- aggregate(lc_test,fact = 2000, fun="modal")

plot(lc_test,type= "classes")
writeCDF(lc_test, file.path("~/Downloads", "lc_test.nc"), overwrite=T)
