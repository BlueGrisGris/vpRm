
library(terra)

evi_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi/weekly_evi"

evi_scene_filename <- list.files(evi_dir, pattern = "proj", full.names = T)
evi_week_filename <- list.files(evi_dir, pattern = "202225", full.names = T)

evi_week <- rast(evi_week_filename)
evi_scene <- rast(evi_scene_filename)

