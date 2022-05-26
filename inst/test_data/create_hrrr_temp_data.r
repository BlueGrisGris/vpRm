library(terra)


hrrr_dir <- "~/Downloads/hrrr"
hrrr_filenames <- file.path(hrrr_dir, list.files(hrrr_dir,pattern = ".nc"))

hrrr <- rast(hrrr_filenames)
print(hrrr)
plot(hrrr)
time(hrrr)

### TODO: big uh oh.  CRS is not being transferred?
### also .nc is in K, while the native grb2 is in C. wtf man
crs(hrrr)
# --> ""

# grb2_filename <- file.path(grb2_dir, "hrrr.t00z.wrfsfcf00.grib2")
grb2_filenames <- file.path(hrrr_dir, list.files(hrrr_dir, pattern = "grib2"))
grb2 <- terra::rast(grb2_filenames)
print(grb2)
plot(grb2)
### doesn't have time(), while .nc has time but not CRS.  strange....
### might be able to eat grb2 after all?

time(grb2)
library(stringr)
xx <- str_split(grb2_filenames, "_", simplify = T)[,2]
yy <- str_split(grb2_filenames, "_", simplify = T)[,3]
ww <- substr(yy,1,2)
library(lubridate)
zz <- ymd_h( paste(xx,ww,sep="_"))
time(grb2) <- zz
plot(grb2)

### see extent of test_stilt in goes_crs so that can pick somethign a bit bigger for goes_test 
data_dir <- system.file("test_data",package="vpRm",mustWork = T)
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain1 <- file.path(stilt_dir,"by-id","01","01_foot.nc")
domain <- rast(matchdomain1)
time(domain)
proj_domain <- project(domain, crs(grb2))

hrrr_test <- terra::crop(grb2,ext(proj_domain)*1.5)

hrrr_test <- hrrr_test[[19:30]]
plot(hrrr_test)

hrrr_test <- aggregate(hrrr_test,fact = 20, fun="mean")
time(hrrr_test) <- zz[19:30]
units(hrrr_test) <- 
plot(hrrr_test)

# plot(hrrr_test)

writeCDF(hrrr_test, file.path("~/Downloads", "hrrr_test.nc"), overwrite=T)
