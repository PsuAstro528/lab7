#!/bin/bash 
## Submit job to our class's allocation
#SBATCH --partition=standard
#SBATCH --account=hpc4astro_crch_fall2025

## Time requested: 0 hours, 15 minutes, 0 seconds
#SBATCH --time=0:15:00 

## Ask for four cores on each of two nodes
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
##SBATCH --ntasks=8   

## Promise that each processor will use no more than 4GB of RAM
#SBATCH --mem-per-cpu=4GB
## OR 
## Promise that each processor will use no more than 8GB of RAM
##SBATCH --mem=16GB

## Save STDOUT and STDERR into one file (%j will expand to become the SLURM job id)
#SBATCH --output=ex2_parallel_2node_%j.log
## Optionally could uncomment line below to write STDERR to a separate file
##SBATCH --error=ex2_parallel_2node_%j.stderr  

## Specify job name, so easy to find using squeue –u
#SBATCH --job-name=ex2_parallel_2node

## Uncomment next two lines (by removing one of #'s in each line) and replace with your email if you want to be notifed when jobs start and stop
##SBATCH --mail-user=YOUR_EMAIL_HERE@psu.edu
## Ask for emails when jobs begins, ends or fails (options are ALL, NONE, BEGIN, END, FAIL)
#SBATCH --mail-type=ALL

echo "Starting job $SLURM_JOB_NAME"
echo "Job id: $SLURM_JOB_ID"
date

echo "This job was assigned the following nodes"
echo $SLURM_NODELIST

#env |grep SLURM                 # Uncomment to print slurm environment variables

echo "Activing environment that provides Julia 1.11.2"
source /storage/ehome/ebf11/hpc4astro/astro_528/scripts/env_setup

echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR            # Change into directory where job was submitted from

export JULIA_PROJECT=`pwd`
export JULIA_NUM_THREADS=1
# Repeat nodes if setting ntasks, since likely uneven distribution of tasks across nodes
srun -l /usr/bin/hostname | sort | awk '{print $2}' > machinefile.$SLURM_JOB_ID   
# Don't repeat nodes if setting ntasks-per-node and using multiple threads per node
#scontrol show hostnames | sed -e s/^/$SLURM_NTASKS_PER_NODE*/ > machinefile.$SLURM_JOB_ID   

date
echo "About to start Julia, starting on $SLURM_NNODES nodes each with $SLURM_NTASKS_PER_NODE processes."

julia --machine-file machinefile.$SLURM_JOB_ID -e 'using Distributed, Pkg; Pkg.precompile(); @everywhere using Pkg; @everywhere Pkg.activate("."); include("ex2_run_nb.jl") ' 

echo "Julia exited"
date

# Cleanup
rm machinefile.$SLURM_JOB_ID
