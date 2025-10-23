#!/bin/bash 
## Submit job to our class's allocation
#SBATCH --partition=standard
#SBATCH --account=hpc4astro_crch_fall2025

## Time requested: 0 hours, 5 minutes, 0 seconds
#SBATCH --time=0:05:00 

## Ask for one core on one node
#SBATCH --nodes=1 
#SBATCH --ntasks=1 

## Promise that each CPU core will use no more than 1GB of RAM
#SBATCH --mem-per-cpu=1GB

## Save STDOUT and STDERR into one file (%j will expand to become the SLURM job id)
#SBATCH --output=ex1_serial_%j.log
## Optionally could uncomment line below to write STDERR to a separate file
##SBATCH --error=ex1_serial_%j.stderr  

## Specify job name, so easy to find using squeue –u
#SBATCH --job-name=ex1_serial

## Uncomment next two lines (by removing one of #'s in each line) and replace with your email if you want to be notified when jobs start and stop
##SBATCH --mail-user=YOUR_EMAIL_HERE@psu.edu
## Ask for emails when jobs begins, ends or fails (options are ALL, NONE, BEGIN, END, FAIL)
#SBATCH --mail-type=ALL

echo "Starting job $SLURM_JOB_NAME"
echo "Job id: $SLURM_JOB_ID"
date

echo "Activing environment that provides Julia 1.11.2"
source /storage/ehome/ebf11/hpc4astro/astro_528/scripts/env_setup

echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR            # Change into directory where job was submitted from

date
echo "About to start Julia"
julia --project=. -- ex1_serial.jl 1000000000
echo "Julia exited"
date

