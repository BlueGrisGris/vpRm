if(F){
### TODO: still want to be able to come back and gen_plate on a preexisting vpRm
### ----> maybe this is the provenance of vpRm() as opposed to new_vpRm()
### ----> I think gen_plate is a method that is called in the wrapper vpRm()
plate <- gen_plate(matchdomain, lc_dir)

### TODO: should this save to storage be a part of this function or in the S3 init?
### save into init_vpRm() created dir processed
### TODO: add to vprm.log/ do 
Save_Rast(plate, plate_dir)
rm(plate)

#########################
### Check Driver data
#########################
}#end if F
