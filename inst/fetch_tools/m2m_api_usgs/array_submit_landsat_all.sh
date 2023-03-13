#!bin/bash
sbatch --array=1-73 array_submit_landsat_L7.sh
sbatch --array=1-100 array_submit_landsat_L8.sh
