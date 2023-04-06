#!/bin/bash
#
#SBATCH -J download_landsat
#SBATCH -p serial_requeue # Partition
#SBATCH -c 5
#SBATCH -t 0-10:30 
#SBATCH --mem-per-cpu 4000 
#SBATCH -o /n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/logs_download_landsat/all_download_landsat_out.txt

module load GCCcore/8.2.0 Python/3.7.2

landsat_data_dir='/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/' 
vprm_m2m_dir='/n/home00/emanninen/vpRm/inst/fetch_tools/m2m_api_usgs/'

cp ${vprm_m2m_dir}landsat.py ${vprm_m2m_dir}landsat_wd/landsat_L7_all.py 
python ${vprm_m2m_dir}landsat_wd/landsat_L7_all.py -c ${vprm_m2m_dir}usgs_credentials.txt -s ${landsat_data_dir}scenes_L7.txt  -d ${landsat_data_dir}scenes_L7/
rm ${vprm_m2m_dir}landsat_wd/landsat_L7_all.py 

cp ${vprm_m2m_dir}landsat.py ${vprm_m2m_dir}landsat_wd/landsat_L8_all.py 
python ${vprm_m2m_dir}landsat_wd/landsat_L8_all.py -c ${vprm_m2m_dir}usgs_credentials.txt -s ${landsat_data_dir}scenes_L8.txt  -d ${landsat_data_dir}scenes_L8/
rm ${vprm_m2m_dir}landsat_wd/landsat_L8_all.py 
