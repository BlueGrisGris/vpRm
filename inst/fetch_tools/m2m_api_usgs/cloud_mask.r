### LSDS 1618 V4.0 pg 13
# L7_sr_cloud_qa_values_CLOUD <- c(2,34)
# L7_sr_cloud_qa_values_SHADOW <- c(4,12,20,36,52) 
# L7_qa_pixel_values_CLOUD <- c(5896,7960,8088)
# L7_qa_pixel_values_SHADOW <- c(7440,7568,7696,7834,7960,8088) 
# L7_qa_pixel <- c(L7_qa_pixel_values_CLOUD, L7_qa_pixel_values_SHADOW)
### I think we want to go w qa_pixel for L7, gets more of the cloud
# plot(scene[["qa_pixel"]] %in% L7_qa_pixel)
# plot(scene[["sr_b1"]] )

cloudmask <- function(scene, mission, qa_pixel = "qa_pixel", return_mask =F){
	if(!mission %in% c("etm", "oli")){stop("mission must be one of etm, oli (landsat 7, landsat 8&9)")} 
	### Add snow??
	if(mission == "etm"){
		### LSDS 1618 V4.0 pg 13
		qa_pixel_cloud_vals <- c(5896,7440,7568,7696,7834,7960,8088) 
	}#end if(mission == "etm"){
	if(mission == "oli"){
		### LSDS 1619 V4.0 pg 14
		qa_pixel_cloud_vals <- c(22280,24088,24216,24344,24472,55052,56856,56984,57240,23888,23952) 
	}#end if(mission == "etm"){

	### for some reason terra::mask shits the bed and crashes R..
	#         scene_masked <- terra::mask(scene, scene[[qa_pixel]], maskvalues = qa_pixel_cloud_vals, updatevalue = NA)
	#         cloudmask <- !(scene[[qa_pixel]] %in% qa_pixel_cloud_vals)
	#         scene_masked <- terra::mask(scene, cloudmask, maskvalues = T, updatevalue = NA)

	if(return_mask){return(scene[[qa_pixel]] %in% qa_pixel_cloud_vals)}
	print(paste("cloud mask memory", pryr::mem_used()/1e3))
	scene[(scene[[qa_pixel]] %in% qa_pixel_cloud_vals)] <- NA 
	return(scene)
}#end func cloudmask

### looks good
# plot(is.na(cloudmask(scene, 'etm')[["sr_b3"]]))
