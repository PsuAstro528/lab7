#!/bin/bash 
## Submit job to our class's allocation
#SBATCH --partition=standard
#SBATCH --account=hpc4astro_crch_fall2025

## Time requested: 0 hours, 5 minutes, 0 seconds
#SBATCH --time=0:05:00 

## Ask for one core on one node for each element of the task array
#SBATCH --nodes=1 
#SBATCH --ntasks=1 

## Promise that each processor will use no more than 1GB of RAM
#SBATCH --mem-per-cpu=1GB

## Save STDOUT and STDERR into one file (%A_%a will expand to become the SLURM job id of the first job in the array and then the task id within the array)
#SBATCH --output=ex1_jobarray_%A_%a.log
## Optionally could uncomment line below to write STDERR to a separate file
##SBATCH --error=ex1_jobarray_%A_%a.stderr  

## Specificy job name, so easy to find using squeue 
#SBATCH --job-name=ex1_jobarray

## Submit a job array with 10 tasks, but limit to 5 tasks running at once
#SBATCH --array=1-10%5

## Uncomment next two lines (by removing one of #'s in each line) and replace with your email if you want to be notifed when jobs start and stop
##SBATCH --mail-user=YOUR_EMAIL_HERE@psu.edu
## Ask for emails when jobs begins, ends or fails (options are ALL, NONE, BEGIN, END, FAIL)
#SBATCH --mail-type=ALL

echo "Starting job $SLURM_JOB_NAME"
echo "Job id: $SLURM_JOB_ID"
date

echo "Activing environment with that provides Julia 1.11.2"
source /storage/ehome/ebf11/hpc4astro/astro_528/scripts/env_setup

echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR            # Change into directory where job was submitted from

date
echo "About to start Julia"
julia --project=. ex1_job_array.jl $SLURM_ARRAY_TASK_ID 
echo "Julia exited"
date

