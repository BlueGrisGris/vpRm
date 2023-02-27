
library(terra)
library(tidyterra)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggplot2)
library(lubridate)

calc_evi <- function(landsat){2.5*( (1e-4*landsat["SR_B5"] - 1e-4*landsat["SR_B4"])/(1e-4*landsat["SR_B5"] + 6 * 1e-4*landsat["SR_B4"] - 7.5*1e-4*landsat["SR_B2"] + 1) )}

stilt <- rast(list.files("~/storage/STILT_slantfoot", full.name = T)[1])[[1]]
values(stilt) <- 0

filenames <- list.files("landsat", full.names = T, pattern = "SR_B")
### TODO: project before mosaic/merge?
### is there a way to merge w/o destruction?
### vectorized/group/parallel mosaic/merge
### TODO: get dates from the filenames
yy <- stringr::str_extract(filenames, "[0-9]{8}")
dates <- ymd(yy)
# dates <- dates[order(dates)]
# filenames <- filenames[order(dates)]
filenames <- filenames[dates == ymd("2020-01-06")]

for(ii in 1:(length(filenames)/4)){
	### indices of the 4 bands for each scene
	print(ii)
	fn <- filenames[((ii-1)*4):((ii-1)*4+3) + 1]
	print(fn)
	landsat <- rast(fn)
	landsat <- project(landsat, stilt)
	evi <- calc_evi(landsat)
	print(evi)
	overlay
}#end for ii

### even time steps
fillTime

sapply(1:length(dates), function(di){
dates[di]




})#end sapply

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
