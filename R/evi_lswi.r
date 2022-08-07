### calculate EVI as in Mahadevan et al 2008
evi <- function(nir, red, blue){
	### G = 2.5
	### C1 = 6
	### C2 = 7.5
	### L = 1

	return(
		2.5 *( (nir - red)/(nir + (6*red - 7.5*blue) + 1) )
	)#end return

}#end func evi

### calculate LSWI as in Mahadevan et al 2008
lswi <- function(nir, swir){
	return(
	       (nir - swir)/(nir+swir)
	       )#end return
}#end func lswi
