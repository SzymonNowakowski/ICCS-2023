#!/bin/bash -l


# topola cluser version
#SBATCH -A GRANT_NUMBER
#SBATCH --cpus-per-task=1
#SBATCH --time=7-00:00:00
#SBATCH --partition=topola
#SBATCH --mem=48GB
module load apps/r/4.0.3
time Rscript $1.R $2 $3 $4 &> res_200_$1_$2_$3-$4

