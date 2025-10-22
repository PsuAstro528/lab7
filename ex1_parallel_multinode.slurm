#!/bin/bash 
## Submit job to our class's allocation
#SBATCH --partition=standard
#SBATCH --account=hpc4astro_crch_fall2025

## Time requested: 0 hours, 5 minutes, 0 seconds
#SBATCH --time=0:05:00 

## Ask for a total of 4 tasks spread over 2 nodes
#SBATCH --nodes=2     # Force slurm to spread job over two nodes
#SBATCH --ntasks=4 

## Promise that each CPU will use no more than 4GB of RAM
#SBATCH --mem=4GB

## Save STDOUT and STDERR into one file (%j will expand to become the SLURM job id)
#SBATCH --output=ex1_parallel_2node_%j.log
## Optionally could uncomment line below to write STDERR to a separate file
##SBATCH --error=ex1_parallel_2node_%j.stderr  

## Specify job name, so easy to find using squeue –u
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

echo "Activing environment that provides Julia 1.11.2"
source /storage/ehome/ebf11/hpc4astro/astro_528/scripts/env_setup

echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR            # Change into directory where job was submitted from

export JULIA_NUM_THREADS=1
export JULIA_PROJECT=`pwd`      # This "should" cause all worker processes to have same project directory, but I still had to manually set it.

#julia --version                 # To check that you're using the version of Julia you expect
#env |grep JULIA                # To check JULIA environment variables
#env |grep SLURM                # To check slurm environment variables

echo "Create list of all nodes that you should connect to (repeating number of times based on number of CPU cores allocated)"
srun -l /usr/bin/hostname | sort | awk '{print $2}' > machinefile.$SLURM_JOB_ID

date
echo "About to start Julia, using ssh to connect to each CPU core allocated by slurm as a separate process"

julia --machine-file machinefile.$SLURM_JOB_ID -e 'using Distributed; using Pkg; Pkg.precompile(); @everywhere using Pkg; @everywhere Pkg.activate("."); n=1_000_000_000; include("ex1_parallel.jl") ' 

echo "Julia exited"
date

# Cleanup temporary file (or leave it to see what happened)
#rm machinefile.$SLURM_JOB_ID

