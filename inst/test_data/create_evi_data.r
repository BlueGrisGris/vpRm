library(terra)

data_dir <- system.file("test_data", package="vpRm",mustWork=T)
### see extent of test_stilt in goes_crs so that can pick somethign a bit bigger for goes_test 
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain1 <- file.path(stilt_dir,"by-id","01","01_foot.nc")
domain <- rast(matchdomain1)
proj_domain <- project(domain, crs(evi))


evi_dir <- c( "~/Desktop/landsat/landsat8" ,"~/Desktop/landsat/landsat7")

evi_8_filename <- file.path(evi_dir[1],list.files(evi_dir[1])[1:2])
evi_7_filename <- file.path(evi_dir[2],list.files(evi_dir[2])[1:2])


for(fn in c(evi_8_filename,evi_7_filename)){
print(fn)
evi <- rast(fn)
plot(evi)
evi_test <- terra::crop(evi,ext(proj_domain)*1.7)
}#end for fn
