# This script downloads GOES-16 downwelling shortwave radiation (surface) files in NetCDF-4 format 

# It is necessary to register for an account with the OSI SAF data repository 
# Credentials are as follows:
# username = c1f2a8
# password = teleobjectifs-retomberont-simplifieras

#!/bin/bash
#$ -l h_rt=96:00:00
#$ -j y
#$ -V

# Load modules
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
#module load gcc
#shopt -s expand_aliases


# Set directories and shell variables

year=2020
#varname='ssi'
#DIR=GOES/$year
#inDIR=GOES/$year/goes2021/
#outDIR=GOES/$year/origTIFF/

username=c1f2a8
pass=teleobjectifs-retomberont-simplifieras

#cd DIR
 
# Download files

#cd $DIR/goes$year
wget -r -nd --user=$username --password=$pass ftp://eftp.ifremer.fr/cersat-rt/project/osi-saf/data/radflux/l3/goes13/hourly/$year/
#bunzip2 *.bz2

#cd $inDIR
#for ncfile in *.nc
#do
#tmp=${ncfile/.nc/}
#outfile=$outDIR$tmp\.tif
#echo $tmp
#gdal_translate -a_srs "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" NETCDF:$ncfile:$varname $outfile
#done
#echo $year " complete"
