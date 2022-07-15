#!/bin/bash
shopt -s expand_aliases

variable=`echo TMP:2 m above ground`

year=2020
months=`echo 01`
days=`echo {30..31}`
hours=`echo {00..23}`



for mm in $months
do
for dd in $days
do
for hh in $hours
#for (( hh=01; hh<=05; hh++ ))
do
	date=`echo ${year}$mm$dd`

	date_time=`echo $date$hh`
	echo "$date_time"

#	echo $url

	prefix=`echo /n/wofsy_lab2/Users/emanninen/vprm/driver_data/hrrr_temperature`
	### fetch from Utah University hrrr archive.  Someday should transition to the GCP archive
	url=`echo https://pando-rgw01.chpc.utah.edu/hrrr/sfc/$date/hrrr.t$hh\z.wrfsfcf00.grib2`
	wget --no-check-certificate --directory-prefix=$prefix $url
	### convert from grb2 to nc, only take the var you want
#	wgrib2 $prefix\/hrrr.t$hh\z.wrfsfcf00.grib2 -match "TMP:2 m above ground" -netcdf ~/Downloads/hrrr/hrrr_$date\_$hh\.nc
	### can keep in grib2 which is more storage efficient.  terra::rast actually handles this fine 
	wgrib2 $prefix\/hrrr.t$hh\z.wrfsfcf00.grib2 -match "TMP:2 m above ground" -grib $prefix\/hrrr_$date\_$hh\.grib2
	rm $prefix\/hrrr.t$hh\z.wrfsfcf00.grib2
done
done
done

