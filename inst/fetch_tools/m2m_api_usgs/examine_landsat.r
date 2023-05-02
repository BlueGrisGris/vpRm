
library(terra)
library(ncdf4)
library(tidyterra)
# library(rnaturalearth)
# library(rnaturalearthdata)
library(ggplot2)
library(lubridate)
library(stringr)


yang_stilt_dir <- "/n/wofsy_lab2/Users/emanninen/vprm_20230311/driver_data/landsat/scenes_L7"
if(F){
stilt <- rast(
	      list.files(yang_stilt_dir, full.name = T)[1]
	      )[[1]]
values(stilt) <- 0
}#ened if F

landsat7_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/test_scenes_L7"
 
filenames <- list.files(landsat7_dir, full.names = T)
### TODO: project before mosaic/merge?
### is there a way to merge w/o destruction?
### vectorized/group/parallel mosaic/merge
### TODO: get dates from the filenames
yy <- stringr::str_extract(filenames, "[0-9]{8}")
dates <- ymd(yy)


### aggregating all scenes w/in a week.
ww <- 44
filenames_week <- filenames[week(dates) == ww]
id <- stringr::str_extract(filenames_week, "[0-9]{6}_[0-9]{8}")
filenames_scene <- filenames_week[id == id[1]] 
scene <- rast(filenames_scene)
### Do cloud QA before projecting
names(scene) <- c("QA_CLOUD", "SR_B1", "SR_B3", "SR_B4", "SR_B5")
qa_cloud <- values(scene[["QA_CLOUD"]])

yy <- sapply(qa_cloud[!is.na(qa_cloud)], function(x){as.integer(intToBits(x))})


scene[["cloud"]] <- as.numeric(str_sub(values(scene[["QA_CLOUD"]]), 2, 2))
plot(scene[["cloud"]] == 1)

cloud_mask <-   

qa <- values(scene[["QA"]])

### calc evi before or after projection?
evi <- calc_evi(scene, "etm")













landsat <- mosaic(rast(filenames[9:12]),rast(filenames[13:16]))

evi_mask <- evi > 1 | evi < -1 | is.na(evi)

evi <- mask(evi, mask = evi_mask, maskvalues = T)
evi <- project(evi, stilt)
plot(evi)
plot(ext_stilt)


### frame for plotting
ext_stilt <- ext(stilt)*1.2
# stilt <- project(stilt, landsat)

world <- ne_countries(scale = "medium", returnclass = "sf", continent = "North America")
names(world)
world <- vect(world)
# world <- project(world, landsat)
world <- project(world, stilt)
world <- crop(world, ext_stilt)

pdf(file = "~/Desktop/mosaic_landsat_evi.pdf", width = 12)
print(
ggplot() +
	geom_spatvector(data = world) +
	geom_spatraster(data = stilt, alpha = .001) +
	### TODO:
	#         geom_spatvector(data = ext_stilt) +
	geom_spatraster(data = evi, alpha = .7) +
	labs(
		fill = "EVI"
	) +#end labs
	theme_classic()	
)#end print
dev.off()

### rgb "real color" for context
# rgb <- c(1e-1*landsat["SR_B4"], 1e-1*landsat["SR_B3"], 1e-1*landsat["SR_B2"])
# plotRGB(rgb)
