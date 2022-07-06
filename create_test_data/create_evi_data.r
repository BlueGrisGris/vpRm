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
evi_times <- as.POSIXct(paste0(yr, "-01-01")) + doy
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

time(evi) <- evi_times

up_cutoff <- ((evi>.85*max(evi))*doy)
plot(up_cutoff)

### starting thing we will replace zeros with the doy where it exceeds some cutoff
greenup <- evi[[1]]
values(greenup) <- 0
plot(greenup)

for(dd in nlyr(up_cutoff)){
	if(pixel == 0){
		lapp
		pixel <- up_cutoff[[dd]]
	}#end if(pixel == 0){
}#end for dd


ff <- function(up_cutoff){
	if(greenup == 0 & up_cutoff != 0){greenup <- up_cutoff}
}#end ff

for(uc in up_cutoff){
	print(uc)
}#end for uc

ll <- lapply(up_cutoff, function(uc){
	replace_greenup <- (greenup == 0 & uc != 0)
	greenup <- replace_greenup*max(uc)
	greenup
})#end lapply

### TODO: mask where 
zz <- sds(greenup, up_cutoff)
ff <- function(gg,uc){
	browser()
	str(gg)
	str(uc)
	gg == 0
	uc != 0
	if(gg == 0 & uc != 0){
		gg <- uc 
	}#end if 
	return(gg)
}# end fucn

lapp(zz,ff) 
