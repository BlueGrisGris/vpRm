library(terra)
### LC data retrieved from https://www.mrlc.gov/data

tests_dir <- system.file("tests",package="vpRm")
data_dir <- file.path(tests_dir, "data") 

lc_filename <- file.path("~/Desktop/research/phd/em27_carbfor/vprm/NLCD/LC/nlcd_2019_land_cover_l48_20210604.img")
file.exists(lc_filename)
lc <- rast(lc_filename)

### see extent of test_stilt in lc_crs so that can pick somethign a bit bigger for test_lc 
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain1 <- file.path(stilt_dir,"by-id","202001310500_-72.1898_42.5331_364","202001310500_-72.1898_42.5331_364_foot.nc")
domain <- rast(matchdomain1)
proj_domain <- project(domain, crs(lc))

### hmmm
plot(lc)
raster_lc <- raster::raster(lc_filename)
raster::plot(raster_lc)

test_lc <- lc
ext(test_lc) <- ext(proj_domain)
test_lc <- crop(lc,proj_domain) 
plot(proj_domain)
plot(test_lc)
