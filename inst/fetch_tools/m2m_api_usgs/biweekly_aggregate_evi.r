
library(terra)
library(stringr)

weekly_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi/weekly_evi"
biweekly_dir <- "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi/biweekly_evi" 

weekly_filenames <- grep(list.files(weekly_dir, full.names = T), pattern = "proj|mask", invert = T, value = T)

nn <- 1:length(weekly_filenames)
bi_idx <- 2*(nn-1) + 1

bi <- 5
biweekly_filenames <- sapply(bi_idx, function(bi){
				# applied_yywws <- lapply(bi_idx[1:10], function(bi){
	print(c(bi, bi+ 1))
	if(bi+1>length(bi_idx)){return("done")}
	bi_filenames <- weekly_filenames[c(bi, bi+ 1)]
	print(bi_filenames)
	bi_evi <- rast(bi_filenames)
	#         print(bi_evi)
	yyww <- stringr::str_extract(bi_filenames, "[0-9]{6}")[1]
	#         print(yyww)
	bi_evi_filename <- file.path(biweekly_dir, paste0(yyww, ".tif"))
	mean_bi_evi <- mean(bi_evi, filename = bi_evi_filename, overwrite = T)
	return(bi_evi_filename)
}) %>% unlist()#end lapply

ixx <- rast(weekly_filenames[20:25])
