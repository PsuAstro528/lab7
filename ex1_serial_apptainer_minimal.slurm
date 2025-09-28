#!/bin/bash 
## Submit job to our class's allocation
#SBATCH --partition=standard
#SBATCH --account=hpc4astro_crch_fall2025

## Time requested: 0 hours, 30 minutes, 0 seconds
#SBATCH --time=0:30:00 

## Ask for one core on one node
#SBATCH --nodes=1 
#SBATCH --ntasks=1 

## Promise that each processor will use no more than 1GB of RAM
#SBATCH --mem-per-cpu=8GB

## Save STDOUT and STDERR into one file (%j will expand to become the SLURM job id)
#SBATCH --output=ex1_apptainer_%j.log
## Optionally could uncomment line below to write STDERR to a separate file
##SBATCH --error=ex1_apptainer_%j.stderr  

## Specificy job name, so easy to find using squeue –u
#SBATCH --job-name=ex1_apptainer_min

## Uncomment next two lines (by removing one of #'s in each line) and replace with your email if you want to be notifed when jobs start and stop
##SBATCH --mail-user=YOUR_EMAIL_HERE@psu.edu
## Ask for emails when jobs begins, ends or fails (options are ALL, NONE, BEGIN, END, FAIL)
#SBATCH --mail-type=ALL

echo "Starting job $SLURM_JOB_NAME"
echo "Job id: $SLURM_JOB_ID"
date

#echo "Activing environment with that provides Julia 1.11.2"
#source /storage/ehome/ebf11/hpc4astro/astro_528/scripts/env_setup

echo "About to change into $SLURM_SUBMIT_DIR"
cd $SLURM_SUBMIT_DIR            # Change into directory where job was submitted from

date
echo "About to ensure Julia has access to the dependencies it needs when running from the minimal julia container (by installing them in your julia depot outside the container)."
apptainer run -H ~/container_home -B $PWD:/work ~/hpc4astro/containers/julia_minimal.sif julia --project=/work -e 'import Pkg; Pkg.instantiate(); Pkg.precompile()'
date
echo "About to run Julia"
apptainer run -H ~/container_home -B $PWD:/work ~/hpc4astro/containers/julia_minimal.sif julia --project=/work  -- /work/ex1_serial.jl 1000000000
echo "Julia exited"
date

