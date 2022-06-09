library(terra)

evi_dir <- c( "~/Desktop/landsat/landsat8" ,"~/Desktop/landsat/landsat7")

evi_7_filename <- file.path(evi_dir[2],list.files(evi_dir[2]))

evi_8_filename <- file.path(evi_dir[1],list.files(evi_dir[1],pattern = "20200105"))


evi1 <- rast(evi_8_filename[1])
plot(evi1[[1]])
evi2 <- rast(evi_8_filename[2])
plot(evi2[[1]])

ext1 <- ext(evi1)
ext2 <- ext(evi2)


ll <- lapply(evi_7_filename, function(fn){
	print(fn)
	#         evi <- rast(fn)
	#         return(evi)
	return(rast(fn)[[1]])
})#end lapply

cc <- sprc(ll)
### TODO: remove extraneous bands before slow mosaic step
### TODO: how to mosaic w na.rm = T
mm <- mosaic(cc[1:2], fun = "mean",na.rm = T)
# mm <- mm[[1]]
### example slant foot
foot <- rast("~/Desktop/stilt_slant_hb_202001071300.nc")
foot <- project(foot[[1]], mm)
mm_foot <- merge(gee, mm,foot)

plot(foot)
plot(gee)
plot(mm)
plot(mm_foot)

#  gee_files <- file.path("~/Desktop/landsat_evi","20200117.tif")
gee_path <- file.path("~/Desktop/landsat_evi")
gee_files <- file.path(gee_path,list.files(gee_path))[1]
gee <- rast(gee_files)
values(gee)
plot(gee)
gee <- project(gee, foot)
plot(merge(gee, foot))
library(ncdf4)
nc_open(gee_files)

foot <- aggregate(foot, fact = 20 , func = "mean")
writeCDF(foot, file = file.path("~/Desktop/evi_test.nc"))







extract_evi_time <- function(evi_filenames){
	xx <- stringr::str_split(evi_filenames, "_", simplify = T)[,3]
	return(lubridate::ymd(substr(xx,1,8)))
}#end func extract_evi_time

time(evi) <- extract_evi_time(evi_8_filename)

rast(evi_8_filename)


### see extent of test_stilt in goes_crs so that can pick somethign a bit bigger for evi
data_dir <- system.file("test_data", package="vpRm",mustWork=T)
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain1 <- file.path(stilt_dir,"by-id","01","01_foot.nc")
domain <- rast(matchdomain1)

proj_domain <- project(domain, crs(evi))

for(fn in c(evi_8_filename,evi_7_filename)){
print(fn)
plot(evi)
evi_test <- terra::crop(evi,ext(proj_domain)*1.7)
}#end for fn


###################
### composite in R
###################

### lapply read for each of needed 




