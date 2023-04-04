
	print(paste(" before for  memory", pryr::mem_used()*1e-3))
library(terra)
library(tidyterra)
library(ggplot2)
library(lubridate)
library(stringr)

evi_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi"

fetch_landsat_scripts_dir <- "/n/home00/emanninen/vpRm/inst/fetch_tools/m2m_api_usgs"
source(file.path(fetch_landsat_scripts_dir, "cloud_mask.r"))
source(file.path(fetch_landsat_scripts_dir, "calc_evi.r"))

stilt_dir <- list.files("/n/wofsy_lab2/Users/emanninen/STILT_slantfoot", full.names = T)[1]
stilt <- rast(stilt_dir)[[13]]

landsat7_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/scenes_L7"
landsat7_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/old/scenes_old/scenes_L7"

landsat8_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/old/scenes_old/scenes_L8"

filenames <- list.files(c(landsat7_dir, landsat8_dir), full.names = T)


LC <- stringr::str_extract(filenames, "[0-9]{2}")

entityid <- paste( stringr::str_extract(filenames, "[0-9]{2}") ,stringr::str_extract(filenames, "[0-9]{6}_[0-9]{8}"), sep = "_")
### how many of the scenese have all 6 bands?

complete_entityid <- sapply(1:length(unique(entityid)), simplify = "vector", USE.NAMES = F, function(ei){
	ei <- unique(entityid)[ei]
	filenames_scene <- filenames[entityid == ei]
	lc <- stringr::str_extract(filenames_scene, "[0-9]{2}")[1]
	#         print(filenames_scene)
	if((length(filenames_scene) == 6 & lc == "07")| (length(filenames_scene) == 5 & lc %in% c("08", "09")) ){return(ei)}else{return()}
}) %>% unlist()#end sapply ei

### ~73% of the L7 scenes have 6 bands....
# length(complete_entityid)/ length(unique(entityid))


complete_filenames <- filenames[entityid %in% complete_entityid]
complete_LC <- LC[entityid %in% complete_entityid]

dates <- ymd(stringr::str_extract(complete_filenames, "[0-9]{8}"))

year_weeks <- as.numeric(paste0(year(dates),str_pad(week(dates), 2, "left", "0")))

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
	}else{yyww <- unique(year_weeks)[c(12)]}#end if(!interactive()){

	print(paste("yyww:", yyww))

	filenames_week <- complete_filenames[year_weeks %in% yyww]
	entityid_week <- paste( stringr::str_extract(filenames_week, "[0-9]{2}") ,stringr::str_extract(filenames_week, "[0-9]{6}_[0-9]{8}"), sep = "_")
	LC_week <- complete_LC[year_weeks %in% yyww]

	### set a much larger domain to fill in so projection works at the edges
	stilt_x <- stilt
	values(stilt_x) <- 0
	ext(stilt_x) <- 1.2*ext(stilt_x)

	### terra thinks it can access the full mem of the interactive node?
	terraOptions(memmax = 4)
	ei <- 2

	#         xx <- parallel::mclapply(1:2, mc.cores = 2, function(ei){
	#         xx <- 	lapply(1:2, function(ei){
				   #         parallel::mclapply(1:length(unique(entityid_week)), mc.cores = 2, function(ei){
				   #                 print(paste("scene_index", ei))

	#         for(ei in 1:length(unique(entityid_week))){

		ei <- unique(entityid_week)[ei]
		print(paste("scene", ei))
		lc <- stringr::str_extract(ei, "[0-9]{2}")

		filenames_scene <- filenames_week[entityid_week == ei]
		#                 print(filenames_scene)
		scene <- rast(filenames_scene)
	print(paste(" scene memory", pryr::mem_used()*1e-3))

	if(F){
		if(lc == "07"){
			names(scene) <- c("qa_pixel", "sr_b1", "sr_b3", "sr_b4", "sr_b5", "qa_cloud")
			### mask then calc evi
			print("about to mask")
	print(paste(" memory", pryr::mem_used()/1e3))
	#                         scene_mask <- cloudmask(scene, "etm")
	#                         print("finish to mask")
			print("about to evi")
			#                         evi <- calc_evi(scene_mask, "etm")
			evi <- calc_evi(scene, "etm")
			print("finish to evi")
	print(paste(" memory", pryr::mem_used()/1e3))
		}#end if lc == 07
		if(lc %in%  c("08", "09")){
			names(scene) <- c("qa_pixel", "sr_b2", "sr_b4", "sr_b5", "sr_b6")
			### mask then calc evi
			### TODO: can provide filename to reduce memory load?
			#         print(paste("pre cloud mask memory", pryr::mem_used()/1e3))
	#                         scene_mask <- cloudmask(scene, "oli")
	#                         evi <- calc_evi(scene_mask, "oli")
			evi <- calc_evi(scene, "oli")
		}#end if lc == 07
		### project evi to stilt domain
			print("about  to proj")
		evi_proj <- terra::project(evi, stilt_x, mask = T, threads = T, filename = file.path(evi_dir, paste0(ei, "proj", ".tif")), overwrite = T)
			print("finish to proj")
		#                 print("memory used")
		#                 print(pryr::mem_used())
	}#ende if F
	}#end for	
		#         })#end lapply(entityid, function(ei)
	# stop("finished")

	filenames_evi_week <- file.path(evi_dir, paste0(unique(entityid_week), "proj", ".tif"))
	evi_week <- terra::rast(filenames_evi_week)
	evi_week_mean <- mean(evi_week, na.rm = T, filename = file.path(evi_dir, paste0(yyww, ".tif")), overwrite = T)
	unlink(filenames_evi_week)
	#         return(NULL)

	# })#end lapply year_weeks
	#         plot(evi)
	#         plot(evi_proj)
	if(interactive()){
		plot(evi_week_mean)
	}#end interactive
	stop("finished")
