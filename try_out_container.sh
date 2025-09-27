mkdir -p ~/container_home
apptainer shell -H ~/container_home -B $PWD:/work julia.sif

