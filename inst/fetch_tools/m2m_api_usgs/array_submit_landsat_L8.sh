#!/bin/bash
#
#SBATCH -J download_landsat
#SBATCH -p serial_requeue # Partition
#SBATCH -c 1
#SBATCH -t 0-1:00 
#SBATCH --mem-per-cpu 2000 
#SBATCH -o /n/wofsy_lab2/Users/emanninen/vprm_20230311/driver_data/landsat/logs_download_landsat/download_landsat8_out_%a.txt

module load GCCcore/8.2.0 Python/3.7.2
landsat_data_dir='/n/wofsy_lab2/Users/emanninen/vprm_20230311/driver_data/landsat/' 
block_size=50
index_start=$(( ${block_size}*(${SLURM_ARRAY_TASK_ID}-1) ))
index_end=$(( ${block_size}-1+${block_size}*(${SLURM_ARRAY_TASK_ID}-1) ))
echo index_start
echo ${index_start}
echo index_end
echo ${index_end}
cp ~/vpRm/inst/fetch_tools/m2m_api_usgs/landsat.py ~/vpRm/inst/fetch_tools/m2m_api_usgs/landsat_wd/landsat_L8_${SLURM_ARRAY_TASK_ID}.py 
python ~/vpRm/inst/fetch_tools/m2m_api_usgs/landsat.py -c /n/home00/emanninen/vpRm/inst/fetch_tools/m2m_api_usgs/usgs_credentials.txt -s ${landsat_data_dir}scenes_L8.txt  -d ${landsat_data_dir}scenes_L8/ -is ${index_start} -ie ${index_end}
rm ~/vpRm/inst/fetch_tools/m2m_api_usgs/landsat_wd/landsat_L8_${SLURM_ARRAY_TASK_ID}.py 
