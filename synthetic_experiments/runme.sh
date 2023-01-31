#!/bin/bash

mkdir results_iccs

for beta in 1 2 3 4 5 6; do
  for snr in 1 2 3 4 5 6 7 8; do
    for group in 1 2; do
      sbatch runme.slurm $beta $snr $group
    done
  done
done
