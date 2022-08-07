# This script downloads the NOAA Rapid Refresh 13km hourly analysis data

#!/bin/bash -l
$ -l h_rt=72:00:00
$ -j y
$ -N RAP21
$ -pe omp 10

#shopt -s expand_aliases
#alias wgrib2='/projectnb/buultra/iasmith/grib2/wgrib2/wgrib2'
#source /projectnb/buultra/iasmith/RAP_wget1.sh
#source /usr/local/Modules/3.2.10/init/bash
#source /share/pkg.7/ncl/6.5.0/module_load_ncl_dependencies.sh
#module load gdal/2.3.2
#module load netcdf/4.6.1
#module load ncl/6.5.0
#module load nco/4.7.8
#module load geos/3.7.0
#module load R/3.6.0
#module load rstudio/1.2.1335
#module load freetype/2.9.1
#module load hdfeos2/20v1.00
#module load proj4/5.1.0
#
shopt -s expand_aliases

# Set directories and shell variables
year=2020
dataset='rap'
varname='TMP_2maboveground'
### for some reason curly brace expansion is not working properly.
## this 
## also 202001 202002  202004 and some days in 202003 is in a different place..
subdirs=`echo ${year}{06..12}`
## gives the series without the padded zero to make it a valid datetime format
## this 
hr=`echo {0000..2300..0100}`
## doesnt expand at all.
echo $subdirs
echo "$hr"

baseDIR=.
mkdir -p $baseDIR/$dataset
mkdir -p $baseDIR/$dataset/$year
mkdir -p $baseDIR/$dataset/$year/$dataset\grib
mkdir -p $baseDIR/$dataset/$year\/origTIFF
inDIR=$baseDIR/$dataset/$year/$dataset\grib
outDIR=$baseDIR/$dataset/$year\/origTIFF/

cd rap/$year/RAPgrib

# Download files

   for d in $subdirs
   do
   s2=`echo ${d}{01..31}`
   for s in $s2
   do
   for h in $hr
   do
   # For 2013 and later use:
   # echo https://www.ncei.noaa.gov/data/rapid-refresh/access/rap-130-13km/analysis/$d\/$s/\rap_130_$s\_$h\_000.grb2
   wget -r -np -nc -l2 --no-check-certificate -e robots=off  https://www.ncei.noaa.gov/data/rapid-refresh/access/rap-130-13km/analysis/$d\/$s/\rap_130_$s\_$h\_000.grb2
   # echo xxxxxx
   done
   done
   done

   find . -type f -name "rap_130*" -exec mv "{}" . \;
   find . -type f -name "rap_252*" -exec rm "{}" \;

cd $inDIR
   rm -f *_001.grb2
   rm -f *_001.inv

#alias wgrib2='/projectnb/buultra/iasmith/grib2/wgrib2/wgrib2'

for grbfile in *.grb2
do
tmp=${grbfile/.grb2/}
outfile=$tmp\.nc
wgrib2 $grbfile -netcdf $outfile
done

#for ncfile in *.nc
#do
#tmp=${ncfile/.nc/}
#outfile=$outDIR$tmp\.tif
#echo $tmp
#gdal_translate -a_srs "+proj=lcc +lat_1=25 +lat_2=25 +lat_0=25 +lon_0=-95 +x_0=0 +y_0=0 +a=6371229 +b=6371229 +units=m +no_defs" NETCDF:$ncfile:$varname $outfile
#gdalwarp -t_srs '+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs' temp.tif $outfile
#done
