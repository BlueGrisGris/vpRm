### TODO: this is all haggard but I don't know a better way 

### parse doy from modis evi filenames downloades through appears
parse_doy_from_evi <- function(evi_filenames){
	doy <- substr(evi_filenames, 34, 40)
	return(as.numeric(doy))
}#end func
