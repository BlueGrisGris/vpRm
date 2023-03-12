load_all()
library(terra)
data_dir <- system.file("test_data",package="vpRm",mustWork = T)
stilt_dir <- file.path(data_dir, "stilt_test")
matchdomain <- Get_Stilt_Out_Filenames(stilt_dir,"foot")

stilt <- rast(matchdomain) 

evi_dir <- "~/Desktop/evi"
evi_filename <- file.path(evi_dir,list.files(evi_dir))

evi <- rast(evi_filename)

library(stringr)
library(lubridate)
xx <- str_split(evi_filename, "/", simplify = T)[,4]
yy <- str_split(xx, "_", simplify = T)[,7]
doy <- as.numeric(substr(yy, start = 8, stop = length(yy)))
doy[1] <- -4
doy <- doy - 1

yr <- 2020 
evi_times <- as.Date(paste0(yr, "-01-01")) + doy
evi_times <- as.POSIXct(evi_times)

time(evi) <- evi_times
### first one is 2019
gud  <- green(evi)
# plot(gud[[2]] - gud[[1]])
hist(gud[[2]] - gud[[1]])

if(F){
plot(evi)
}#end if F

##################################
### Create evi test 
##################################

domain <- rast(matchdomain)
proj_domain <- project(domain, crs(evi))
evi_test <- terra::crop(evi,ext(proj_domain)*1.7)
evi_aggr <- aggregate(evi_test,fact = 130, fun="mean")
time(evi_aggr) <- evi_times

evi_max <- max(evi_aggr, na.rm = T)
evi_min <- min(evi_aggr, na.rm = T)

idx <- findInterval( yday(time(domain)) , vec = doy)
evi_aggr <- evi_aggr[[idx]]

if(F){
plot(evi_aggr)
}#end if F
writeCDF(evi_aggr, file.path("~/Downloads", "evi_test.nc"), overwrite=T)

##################################
### Create evi max 
##################################

evi_extrema <- c(evi_max, evi_min)

if(F){
plot(evi_extrema)
}#end if F

writeCDF(evi_extrema, file.path("~/Downloads", "evi_extrema_test.nc"), overwrite=T)

##################################
### Create green
##################################
### see r/green.r for what we came up with 

### sample pixels
sample_size <- 1000
# set.seed(41)

xx <- sample(1:nrow(evi), sample_size)
yy <- sample(1:ncol(evi), sample_size)
evi_sample <- evi[cellFromRowCol(evi, xx, yy)] 
colnames(evi_sample) <- evi_times
evi_sample$xx <- xx
evi_sample$yy <- yy
evi_sample <- tidyr::pivot_longer(evi_sample, cols = colnames(evi_sample)[1:nlyr(evi)], names_to = "doy", values_to = "evi") 
evi_sample <- evi_sample[!is.na(evi_sample$evi),]

library(ggplot2)
print(
ggplot(evi_sample, aes(y = evi, x = doy)) +
		       #                        , color = paste(xx,yy,sep = "_"))) + 
	#         geom_line(aes(group = paste(xx,yy,sep = "_"))) +
	geom_line() +
	theme_classic()
)#end pring
=======

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

