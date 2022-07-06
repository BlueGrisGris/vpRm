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
### first one is 2019


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

idx <- findInterval( yday(time(domain)) , vec = doy)
evi_aggr <- evi_aggr[[idx]]

if(F){
plot(evi_aggr)
}#end if F
writeCDF(evi_aggr, file.path("~/Downloads", "evi_test.nc"), overwrite=T)

##################################
### Create evi max 
##################################

evi_max <- max(evi_aggr, na.rm = T)
evi_min <- min(evi_aggr, na.rm = T)

evi_extrema <- c(evi_max, evi_min)

if(F){
plot(evi_extrema)
}#end if F

writeCDF(evi_extrema, file.path("~/Downloads", "evi_extrema_test.nc"), overwrite=T)

##################################
### Create green
##################################

vals <- values(evi)
# hist(evi)

list.files(data_dir)
rast(file.path(data_dir,"evi_test.nc" ))
xx <- rast("~/Downloads/evi_test.nc")
class(time(xx))
