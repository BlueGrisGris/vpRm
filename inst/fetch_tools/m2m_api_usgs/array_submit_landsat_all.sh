#!bin/bash
sbatch --array=1-97 array_submit_landsat_7.sh
#sbatch --array=1-133 array_submit_landsat_8.sh
#sbatch --array=1-2 array_submit_landsat_7.sh
#sbatch --array=1-2 array_submit_landsat_8.sh
