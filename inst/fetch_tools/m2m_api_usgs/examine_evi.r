
library(vpRm)
library(lubridate)
library(terra)

# evi_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi/weekly_evi"
evi_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi/two_week/weekly_evi"
# evi_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi/one_week/weekly_evi"

evi_scene_filename <- list.files(evi_dir, pattern = "proj", full.names = T)
evi_week_filename <- list.files(evi_dir, pattern = "202225", full.names = T)

evi_week <- rast(evi_week_filename)
# hist(evi_week)
# evi_scene <- rast(evi_scene_filename)

### compare to modis
### only have 2019-2020 modis evi
### these modis are the quality codes
modis_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/old_vprm/driver_data/modis_evi" 
parse_modis_evi_times( list.files(modis_dir, full.names = T))
modis_filename <- list.files(modis_dir, full.names = T)
[33]
modis <- 1e-4* rast(modis_filename)

