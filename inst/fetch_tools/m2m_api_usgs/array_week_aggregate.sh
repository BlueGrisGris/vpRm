#!/bin/bash
#SBATCH -n 1                # Number of cores
#SBATCH -J evi
#SBATCH -t 0-05:00          # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH -p serial_requeue   # Partition to submit to
#SBATCH --mem-per-cpu=4000           # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o /n/wofsy_lab2/Users/emanninen/vprm/driver_data/logs_evi/%a_week_aggregate.out  # File to which STDOUT will be written, %j inserts jobid

module load R

Rscript week_aggregate_landsat.r ${SLURM_ARRAY_TASK_ID}
