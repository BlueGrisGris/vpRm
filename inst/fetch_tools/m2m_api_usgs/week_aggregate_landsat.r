
library(terra)
library(tidyterra)
library(ggplot2)
library(lubridate)
library(stringr)

fetch_landsat_scripts_dir <- "/n/home00/emanninen/vpRm/inst/fetch_tools/m2m_api_usgs"
source(file.path(fetch_landsat_scripts_dir, "cloud_mask.r"))
source(file.path(fetch_landsat_scripts_dir, "calc_evi.r"))

stilt_dir <- list.files("/n/wofsy_lab2/Users/emanninen/STILT_slantfoot", full.names = T)[1]
stilt <- rast(stilt_dir)[[13]]

landsat7_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/scenes_L7"
filenames <- list.files(landsat7_dir, full.names = T)

evi_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi"

dates <- ymd(stringr::str_extract(filenames, "[0-9]{8}"))

### aggregating all scenes w/in a week.
yyww <- 201944
filenames_week <- filenames[paste0(year(dates),week(dates)) == yyww]
entityid <- stringr::str_extract(filenames_week, "[0-9]{6}_[0-9]{8}")

for(ei in unique(entityid)){
	#         print(ei)
	filenames_scene <- filenames_week[entityid == ei]
	if(length(filenames_scene) == 6){print(ei)}
}#end for ei

ei <- "021032_20191102" 
# lapply(entityid, function(ei){
	print(ei)
	filenames_scene <- filenames_week[entityid == ei]
	scene <- rast(filenames_scene)
	plot(scene)
	names(scene) <- c("qa_pixel", "sr_b1", "sr_b3", "sr_b4", "sr_b5", "qa_cloud")
	### TODO: we dont wnat the drift nas in the qa code to propogate>>>
	### On the other hadn , projection might solve?
	### on the other other hand, might be the source of our projection woes.....
	### test if the drift nas is the cause of the all NA projection/ aggregation?? 
	b1_proj <- terra::project(scene[["sr_b1"]], stilt, filename = file.path(landsat7_dir, "test_b1.tif"), overwrite = T) 
	plot(scene[["sr_b1"]])
	plot(b1_proj)

	### mask then calc evi
	scene_mask <- cloudmask(scene, "etm")
	evi <- calc_evi(scene_mask, "etm")

	### for some reason, direct terra::project(x,y) makes all vals NaN...
	evi_proj <- terra::project(evi, crs(stilt), threads = T, filename = file.path(evi_dir, paste0(ei, "proj", ".tif")), overwrite = T)

	print(evi_proj)

	evi_ext <- terra::extend(evi_proj, stilt, filename = file.path(evi_dir, paste0(ei, "_ext", ".tif")), overwrite = T)

	evi_exp <- terra::project(evi_ext, crs(stilt), threads = T, filename = file.path(evi_dir, paste0(ei, ".tif")), overwrite = T)

	plot(evi_exp)
	print(evi_proj)

	evi_agg <- aggregate(evi_proj, fact = res(stilt)[1]/res(evi_proj)[1], fun = "mean")
	xx <- project(stilt, evi)

	resample(evi_proj, res(stilt))

	ext(evi_proj) <- ext(stilt)
	merge
	evi_res <- resample(evi_proj, stilt, threads = T)
	plot(c(evi_res, stilt[[13]]))


	# })#end lapply(entityid, function(ei){
