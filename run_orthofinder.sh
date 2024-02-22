#!/bin/bash
#SBATCH --partition=cmain                    # which partition to run the job, options are in the Amarel guide
#SBATCH --exclude=gpuc001,gpuc002               # exclude CCIB GPUs
#SBATCH --job-name=orthofinder                        # job name for listing in queue
#SBATCH --mem=10G                               # memory to allocate in Mb
#SBATCH -n 20                                   # number of cores to use
#SBATCH -N 1                                    # number of nodes the cores should be on, 1 means all cores on same node
#SBATCH --time=5:00:00                       # maximum run time days-hours:minutes:seconds
#SBATCH --requeue                                # restart and paused or superseeded jobs

echo "Load conda needed for orthofinder"

module purge
eval "$(conda shell.bash hook)"
conda activate orthofinder

echo "Create variables for Orthofinder"

ulimit -n 2400

orthofinder -f investigating_orthogroups/ -M msa                  # Run full OrthoFinder analysis on FASTA format proteomes in specfied directory

# orthofinder [options] -f <dir1> -b <dir2>     # Add new species in to a previous run and run new analysis

