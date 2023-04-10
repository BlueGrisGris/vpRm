#!/bin/bash
#SBATCH -n 8                # Number of cores
#SBATCH -J evi
#SBATCH -t 0-08:00          # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH -p serial_requeue   # Partition to submit to
#SBATCH --mem-per-cpu=48000           # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o /n/wofsy_lab2/Users/emanninen/vprm/driver_data/evi/logs_evi/%a_week_aggregate.out  # File to which STDOUT will be written, %j inserts jobid
#SBATCH --mail-type=ARRAY_TASKS
#SBATCH --mail-user=emanninen@g.harvard.edu

echo ${SLURM_JOB_NAME} 
echo ${SLURM_JOB_ID} 
echo ${SLURM_ARRAY_TASK_ID} 

module load R
### SLURM ARRAY TASK ID sets the year_week
Rscript week_aggregate_landsat.r ${SLURM_ARRAY_TASK_ID}
