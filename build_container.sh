mkdir -p ~/container_home
apptainer build -B ~/container_home:/home julia.sif julia.def

