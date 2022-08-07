
library(terra)
green_path <- file.path("~/Desktop/research/phd/em27_carbfor/vprm/driver_data/ms_lsp")
up_path <- file.path(green_path, "greenup.tif")
down_path <- file.path(green_path, "dormancy.tif")
up <- rast(up_path)
down <- rast(down_path)
plot(up)
plot(down)

### cant use ians green up/down, bc wrong domain.
### use completely artificial green test data for now

data_dir <- system.file("test_data", package="vpRm",mustWork=T)
out_dir <- file.path("~/Desktop/research/vpRm/inst/test_data/")
list.files(data_dir)

up <- rast( file.path(data_dir, "goes_test.nc") )[[1]]
time(up) <- NULL
values(up) <- round(runif(ncell(up))*100) 
writeCDF(up, file.path(out_dir, "greenup_test.nc"), overwrite=T)

down <- rast( file.path(data_dir, "goes_test.nc") )[[1]]
time(down) <- NULL
values(down) <- round(runif(ncell(down))*360) 
writeCDF(down, file.path(out_dir, "greendown_test.nc"), overwrite=T)
