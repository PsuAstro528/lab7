#!/bin/bash 
## Submit job to our class's allocation
#SBATCH --partition=standard
#SBATCH --account=hpc4astro_crch_fall2025

## Time requested: 0 hours, 5 minutes, 0 seconds
#SBATCH --time=0:15:00 

## Ask for eight CPU cores on each of two nodes
#SBATCH --nodes=2 
#SBATCH --ntasks-per-node=4
####SBATCH --ntasks=8   

## Promise that each processor will use no more than 4GB of RAM
#SBATCH --mem-per-cpu=4GB
## OR 
## Promise that each processor will use no more than 8GB of RAM
##SBATCH --mem=16GB

## Save STDOUT and STDERR into one file (%j will expand to become the SLURM job id)
#SBATCH --output=ex2_parallel_combo_%j.log
## Optionally could uncomment line below to write STDERR to a separate file
##SBATCH --error=ex2_parallel_combo_%j.stderr  

## Specificy job name, so easy to find using squeue –u
#SBATCH --job-name=ex2_parallel_combo

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

echo "Activing environment with that provides Julia 1.11.2"
source /storage/ehome/ebf11/hpc4astro/astro_528/scripts/env_setup

echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR            # Change into directory where job was submitted from

export JULIA_PROJECT=`pwd`
export JULIA_NUM_THREADS=$SLURM_NTASKS_PER_NODE
# Repeat nodes if setting ntasks, since likely uneven distribution of tasks across nodes
srun -l /usr/bin/hostname | sort | awk '{print $2}' > machinefile.$SLURM_JOB_ID   
# Don't repeat nodes if setting ntasks-per-node and using multiple threads per node
#scontrol show hostnames | sed -e s/^/$SLURM_NTASKS_PER_NODE*/ > machinefile.$SLURM_JOB_ID   


date
echo "About to start Julia, using machine file to ssh to each of $SLURM_NNODES nodes, starting $SLURM_NTASKS_PER_NODE threads on each."
julia --project=. --machine-file machinefile.$SLURM_JOB_ID   ex2_run_nb.jl
#julia --project=. -t $SLURM_NTASKS_PER_NODE --machine-file machinefile.$SLURM_JOB_ID   ex2_run_nb.jl
#echo "About to start Julia, using Slurm Cluster Manager to connect to $SLURM_NTASKS_PER_NODE worker procesess on each of $SLURM_NNODES nodes."
#julia --project=. -e 'using Distributed, ClusterManagers; addprocs(SlurmManager(parse(Int,ENV["SLURM_NNODES"])*parse(Int,ENV["SLURM_NTASKS_PER_NODE"])), exeflags=["--project=.",], );   include("ex2_run_nb.jl") '  
#julia --project=. -e 'using Distributed, SlurmClusterManager; addprocs(SlurmManager(), exeflags=["--project=.",], );   include("ex2_run_nb.jl") '  
#julia --project=. -e 'include("setup_slurm_manager.jl"); include("ex2_run_nb.jl") '  
echo "Julia exited"
date
