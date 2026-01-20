#!/bin/bash -l
#SBATCH --time=12:00:00
#SBATCH --mem=10g
#SBATCH --tmp=10g
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH -L nonmem@slurmdb:1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=cheng423@umn.edu
#SBATCH -p msilarge
#SBATCH --output=NONMEM-SCM.log        # Log file name

ulimit -l unlimited

module load nonmem/750-rocky8

scm -config_file=scm1.scm
