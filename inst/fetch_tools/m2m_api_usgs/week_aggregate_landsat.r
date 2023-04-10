
library(terra)
library(tidyterra)
library(ggplot2)
library(lubridate)
library(stringr)

evi_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi/weekly_evi"

fetch_landsat_scripts_dir <- "/n/home00/emanninen/vpRm/inst/fetch_tools/m2m_api_usgs"
source(file.path(fetch_landsat_scripts_dir, "cloud_mask.r"))
source(file.path(fetch_landsat_scripts_dir, "calc_evi.r"))

stilt_dir <- list.files("/n/wofsy_lab2/Users/emanninen/STILT_slantfoot", full.names = T)[1]
stilt <- rast(stilt_dir)[[13]]

landsat7_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/scenes_L7"
landsat8_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/scenes_L8"

seven <- list.files(c(landsat7_dir), full.names = T)
eight <- list.files(c(landsat8_dir), full.names = T)
filenames <- eight
filenames <- seven
filenames <- list.files(c(landsat7_dir, landsat8_dir), full.names = T)

### which satellite
LC <- stringr::str_extract(filenames, "[0-9]{2}")

### date, row/column, and which satellite
entityid <- paste( stringr::str_extract(filenames, "[0-9]{2}") ,stringr::str_extract(filenames, "[0-9]{6}_[0-9]{8}"), sep = "_")
xx <- unique(entityid)

### how many of the scenes have all 6 bands?
complete_entityid <- sapply(1:length(unique(entityid)), simplify = "vector", USE.NAMES = F, function(ei){
	ei <- unique(entityid)[ei]
	filenames_scene <- filenames[entityid == ei]
	if(length(filenames_scene) == 5){return(ei)}else{return()}
}) %>% unlist()#end sapply ei

complete_filenames <- filenames[entityid %in% complete_entityid]
complete_LC <- LC[entityid %in% complete_entityid]
# entityid[!entityid %in% complete_entityid]

dates <- ymd(stringr::str_extract(complete_filenames, "[0-9]{8}"))

year_weeks <- as.numeric(paste0(year(dates),str_pad(week(dates), 2, "left", "0")))
# unique(year_weeks)

if(!interactive()){
	ARGS <- commandArgs(trailingOnly = T)
	YYWW_INDEX <- as.numeric(ARGS[1])
}#end if(!interactive()){
# year_weeks <- unique(year_weeks)[order(unique(year_weeks))]

### aggregating all scenes w/in each week.
# yyww <- c(12,13)

# lapply(1:length(unique(year_weeks)), function(yyww){
	if(!interactive()){
		yyww <- unique(year_weeks)[YYWW_INDEX]
		#                 yyww <- unique(year_weeks)[YYWW_INDEX-1:YYWW_INDEX+1]
	}else{yyww <- unique(year_weeks)[c(1)]}#end if(!interactive()){

	print(paste("yyww:", yyww))

	filenames_week <- complete_filenames[year_weeks %in% yyww]
	entityid_week <- paste( stringr::str_extract(filenames_week, "[0-9]{2}") ,stringr::str_extract(filenames_week, "[0-9]{6}_[0-9]{8}"), sep = "_")
	LC_week <- complete_LC[year_weeks %in% yyww]

	print(paste("complete scenes in week:", length(unique(entityid_week)))) 

	### set a much larger domain to fill in so projection works at the edges
	stilt_x <- stilt
	values(stilt_x) <- 0
	ext(stilt_x) <- 1.2*ext(stilt_x)

	ei <- 50

	#         parallel::mclapply(1:8, mc.cores = 8, function(ei){
	parallel::mclapply(1:length(unique(entityid_week)), mc.cores = 8, function(ei){

		ei <- unique(entityid_week)[ei]
		print(paste("scene", ei))
		lc <- stringr::str_extract(ei, "[0-9]{2}")

		filenames_scene <- filenames_week[entityid_week == ei]
		filename_mask <- file.path(evi_dir, paste0(ei, "mask", ".tif"))

		scene <- rast(filenames_scene)

		if(lc == "07"){
			names(scene) <- c("qa_pixel", "sr_b1", "sr_b3", "sr_b4", "sr_b5")
			### mask then calc evi
			#                         print("about to mask")
			### TODO: it is likely faster to mask after calculating evi
			scene_mask <- cloudmask(scene, "etm", filename = filename_mask)
			#                         print("finish to mask")
			#                         print("about to evi")
			evi <- calc_evi(scene, "etm")
			#                         print("finish to evi")
		}#end if lc == 07
		if(lc %in%  c("08", "09")){
			names(scene) <- c("qa_pixel", "sr_b2", "sr_b4", "sr_b5", "sr_b6")
			### mask then calc evi
			#                         print("about to mask")
			scene_mask <- cloudmask(scene, "oli", filename = filename_mask)
			#                         print("finish to mask")
			#                         print("about to evi")
			evi <- calc_evi(scene, "oli")
			#                         print("finish to evi")
		}#end if lc == 07
		### project evi to stilt domain
		#                 print("about  to proj")
		evi_proj <- terra::project(evi, stilt_x, mask = T, threads = T, filename = file.path(evi_dir, paste0(ei, "proj", ".tif")), overwrite = T)
		#                 print("finish to proj")

		unlink(filename_mask)
	})#edn mclapply

	filenames_evi_week <- file.path(evi_dir, paste0(unique(entityid_week), "proj", ".tif"))
	evi_week <- terra::rast(filenames_evi_week)
	evi_week_mean <- mean(evi_week, na.rm = T, filename = file.path(evi_dir, paste0(yyww, ".tif")), overwrite = T)
	#         unlink(filenames_evi_week)

###################
if(interactive()){
evi_xx <- 2.5*( (1e-4*scene["sr_b5"] - 1e-4*scene["sr_b4"]) / (1e-4*scene["sr_b5"] + 6 * 1e-4*scene["sr_b4"] - 7.5*1e-4*scene["sr_b2"] + 1) )


scene <- scene * 0.0000275  - .2
evi_xx <- 2.5*( (as.numeric(scene["sr_b5"]) - as.numeric(scene["sr_b4"])) / (as.numeric(scene["sr_b5"]) + 6 * as.numeric(scene["sr_b4"]) - 7.5*as.numeric(scene["sr_b2"]) + 1) )
		evi_xx[evi_xx < -1] <- -1
	       	evi_xx[evi_xx > 1] <- 1
			
		plot(c(evi_xx,scene_mask[[1]] ))


	plot(c(evi_xx, is.na(scene_mask[[1]])))
		b5 <- scene["sr_b5"]
		class(values(b5)) 
		b5_vals <- values(b5) 
		b5_vals <- as.numeric(b5_vals)
		hist(as.numeric(b5))
		hist(b5_vals)

evi_xx
hist(evi_xx)
plot(evi_xx > 10)
	plot(evi_week_mean)
	plot(!is.na(scene))

	plot(is.na(evi))

	

}#end interactive
