#!/bin/bash
#
#SBATCH -J download_landsat
#SBATCH -p serial_requeue # Partition
#SBATCH -c 5
#SBATCH -t 0-15:30 
#SBATCH --mem-per-cpu 4000 
#SBATCH -o /n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/logs_download_landsat/%a_download_landsat_out.txt

echo ${SLURM_JOB_NAME} 
echo ${SLURM_JOB_ID} 
echo ${SLURM_ARRAY_TASK_ID} 
block_size=100
index_start=$(( ${block_size}*(${SLURM_ARRAY_TASK_ID}-1) ))
index_end=$(( ${block_size}-1+${block_size}*(${SLURM_ARRAY_TASK_ID}-1) ))
echo index_start
echo ${index_start}
echo index_end
echo ${index_end}

module load GCCcore/8.2.0 Python/3.7.2

landsat_data_dir='/n/wofsy_lab2/Users/emanninen/vprm/driver_data/landsat/' 
vprm_m2m_dir='/n/home00/emanninen/vpRm/inst/fetch_tools/m2m_api_usgs/'

### 53 max slurm index
cp ${vprm_m2m_dir}landsat.py ${vprm_m2m_dir}landsat_wd/landsat_L7_${SLURM_ARRAY_TASK_ID}.py 
python ${vprm_m2m_dir}landsat_wd/landsat_L7_${SLURM_ARRAY_TASK_ID}.py -c ${vprm_m2m_dir}usgs_credentials.txt -s ${landsat_data_dir}scenes_L7.txt  -d ${landsat_data_dir}scenes_L7/ -is ${index_start} -ie ${index_end}
rm ${vprm_m2m_dir}landsat_wd/landsat_L7_${SLURM_ARRAY_TASK_ID}.py 

### 71 max slurm index
cp ${vprm_m2m_dir}landsat.py ${vprm_m2m_dir}landsat_wd/landsat_L8_${SLURM_ARRAY_TASK_ID}.py 
python ${vprm_m2m_dir}landsat_wd/landsat_L8_${SLURM_ARRAY_TASK_ID}.py -c ${vprm_m2m_dir}usgs_credentials.txt -s ${landsat_data_dir}scenes_L8.txt  -d ${landsat_data_dir}scenes_L8/ -is ${index_start} -ie ${index_end}
rm ${vprm_m2m_dir}landsat_wd/landsat_L8_${SLURM_ARRAY_TASK_ID}.py 
