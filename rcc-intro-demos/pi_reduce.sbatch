#!/bin/bash

#SBATCH --job-name=pi_reduce
#SBATCH --output=pi_reduce.out
#SBATCH --error=pi_reduce.err
#SBATCH --reservation=workshop
#SBATCH --partition=sandyb
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8

# Note: Remove the "--reservation=workshop" line above if you are not
# using this code during the RCC workshop.

module load intelmpi
module load mkl 
mpirun -n 16 ./pi_reduce 100000000
