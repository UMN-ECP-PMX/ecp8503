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
#SBATCH --output=NONMEM-LLP.log        # Log file name

ulimit -l unlimited

module load nonmem/750-rocky8

llp mod1.ctl -thetas=1,3 -rplots=2 -clean=0 -min_retries=3
