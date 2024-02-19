#!/bin/bash
#SBATCH --partition=cmain                    # which partition to run the job, options are in the Amarel guide
#SBATCH --account=general
#SBATCH --constraint=oarc
#SBATCH --exclude=halc068               # exclude CCIB GPUs
#SBATCH --job-name=iqtree                        # job name for listing in queue
#SBATCH --mem=10G                               # memory to allocate in Mb
#SBATCH -n 20                                   # number of cores to use
#SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --time=5:00:00                       # maximum run time days-hours:minutes:seconds
#SBATCH --requeue                                # restart and paused or superseeded jobs

echo "Load conda needed for orthofinder"

module purge
eval "$(conda shell.bash hook)"
conda activate iqtree

iqtree -m TEST -s ${1}
