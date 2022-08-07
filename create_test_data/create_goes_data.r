library(terra)
library(ncdf4)


data_dir <- system.file("test_data", package="vpRm",mustWork=T)

# goes_filename <- file.path("~/Desktop/research/phd/em27_carbfor/vprm/NLCD/LC/ngoesd_2019_land_cover_l48_20210604.img")
file.exists("~/Downloads/goes_test")
goes_filename <- file.path("~/Downloads/goes_test",list.files("~/Downloads/goes_test"))
file.exists(goes_filename)
goes <- rast(goes_filename)
plot(goes)
names(goes)
### the par var we want
goes <- goes[[names(goes) == "ssi"]]

### find a way to get the time data...........
time(goes)
library(stringr)
xx <- str_split(goes_filename, "/", simplify = T)[,4]
yy <- str_split(xx, "-", simplify = T)[,1]
library(lubridate)
zz <- ymd_hms(yy)

time(goes) <- zz
time(goes)
### I am assuming the dates in the filenames are UTC, but I am not double checking bc in crunch
plot(goes)

### this terra::sds is poorly documented, maybe a new raster brick type thing for 3 dimensions and more than 1 var 
# goessds <- sds(goes_filename)

### see extent of test_stilt in goes_crs so that can pick somethign a bit bigger for goes_test 
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain1 <- file.path(stilt_dir,"by-id","01","01_foot.nc")
domain <- rast(matchdomain1)
proj_domain <- project(domain, crs(goes))
time(proj_domain)


goes_test <- terra::crop(goes,ext(proj_domain)*1.7)

plot(proj_domain)
plot(goes_test)
time(goes_test)

goes_aggr <- aggregate(goes_test,fact = 20, fun="mean")
### I do not know why aggregate removes time?
time(goes_aggr) 
time(goes_aggr) <- zz

plot(goes_aggr)

writeCDF(goes_aggr, file.path("~/Downloads", "goes_test.nc"), overwrite=T)
