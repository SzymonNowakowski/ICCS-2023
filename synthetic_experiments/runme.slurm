#!/bin/bash -l

# sh cluster version
# #SBATCH -J high_dim_sim
# #SBATCH --cpus-per-task=1
# #SBATCH --ntasks-per-node=1
# #SBATCH --nodes=1
# #SBATCH --partition=msys
# module load compilers/gnu/8.1.0
# time Rscript simulate.R $1 $2 $3 >& iccs_$1_$2_$3

# topola cluster version
#SBATCH -A GRANT_NUMBER
#SBATCH -J high_dim_sim
#SBATCH --cpus-per-task=1
#SBATCH --time=7-00:00:00
#SBATCH --partition=topola
#SBATCH --mem=4GB
module load apps/r/4.0.3
time Rscript simulate.R $1 $2 $3 >& iccs_$1_$2_$3
