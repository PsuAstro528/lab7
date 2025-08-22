#!/bin/bash 
## Submit job to our class's allocation
#SBATCH --partition=standard
#SBATCH --account=hpc4astro_crch_fall2025

## Time requested: 0 hours, 5 minutes, 0 seconds
#SBATCH --time=0:05:00 

## Ask for one core on each of four nodes
#SBATCH --nodes=2 
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=2 

## Promise that each processor will use no more than 1GB of RAM
#SBATCH --mem-per-cpu=1GB

## Save STDOUT and STDERR into one file (%j will expand to become the SLURM job id)
#SBATCH --output=ex1_parallel_2node_%j.log
## Optionally could uncomment line below to write STDERR to a separate file
##SBATCH --error=ex1_parallel_2node_%j.stderr  

## Specificy job name, so easy to find using squeue –u
#SBATCH --job-name=ex1_parallel_2node

## Uncomment next two lines (by removing one of #'s in each line) and replace with your email if you want to be notifed when jobs start and stop
##SBATCH --mail-user=YOUR_EMAIL_HERE@psu.edu
## Ask for emails when jobs begins, ends or fails (options are ALL, NONE, BEGIN, END, FAIL)
#SBATCH --mail-type=ALL

echo "Starting job $SLURM_JOB_NAME"
echo "Job id: $SLURM_JOB_ID"
date

echo "This job was assigned the following nodes"
echo $SLURM_NODELIST

echo "Activing environment with that provides Julia 1.11.2"
source /storage/ehome/ebf11/hpc4astro/astro_528/scripts/env_setup

echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR            # Change into directory where job was submitted from

julia --version
date
echo "About to start Julia, using Slurm Cluster Manager to connect to one worker process on each of $SLURM_NNODES nodes."
julia --project=. -e 'include("setup_slurm_manager.jl"); include("ex1_parallel.jl") '  
echo "Julia exited"
date
