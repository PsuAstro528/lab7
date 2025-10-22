# Astro 528 Lab 7

For this lab, you need to submit jobs to the Lynx cluster and can't use your own computer.  While the class has already been using Lynx Collab in previous labs, we've used it mostly interactively using the JupyterLab environment and Pluto servers provided for the class.  These are very helpful for code development, data visualization, and small-scale tests of your code, including a few processors.  However, the real power of having access to a computer cluster is being able to access dozens or hundreds of processor cores.

A typical science application is to run dozens, hundreds, or even thousands of similar calculations.  For that, scientists need to be able to automate their calculations via scripts.  Those scripts will also tell the computer cluster (technically the *resource manager* and the *scheduler*) the information necessary to assign your jobs to a computer that has the requested configuration and to schedule that in a fair way, given all the other jobs that have been submitted.  

## Exercise 1:  Using an ICDS Clusters (Lynx or Roar Collab)
#### Goals:
- Submit a batch job via Slurm
- Read and write data from a batch job
- Run multiple jobs using a job array

#### Step-by-step Instructions:

Follow the directions below to practice submitting jobs and inspecting their results.

1.  From your web browser, look over [ex1_serial.jl](ex1_serial.jl) and [ex1_parallel.jl](ex1_parallel.jl).  The point is simply to see what this code does.

2.  For this lab, you'll mostly be using the command-line interface to submit jobs to Lynx.  You can get to a command line on Lynx by using:
   -  Clicking the terminal tile inside the JupyterLab Server Launcher that you've been using, or
   - `ssh feed.lynx.hpc.psu.edu` (I've found sometimes this is easier to copy/paste text across windows.)

Note that the number of cores you are allocated when using the JupyterLab Server or Interactive Desktop affects the number of cores for your interactive session, but does not prevent you from submitting batch jobs that use more (or fewer) cores.

3.  Clone your project repo, change into that directory, and test that the code for example 1 runs successfully.  E.g.,
```sh
git clone REPO_URL
cd REPO_DIR
julia --project deps/build.jl 
julia --project ex1_serial.jl 1000000000
```
### Submitting & Running a Serial Job

4.  Look over the file [ex1_serial.slurm](ex1_serial.slurm) to see what resources you are about to request.  Then submit a batch job using
 ```sh
sbatch ex1_serial.slurm
 ```

5.  Check on the status of the queue using `squeue`.  That's probably more information than you wanted about other people's jobs.  You can check only your own jobs by running `squeue -u YOUR_USER_ID`.  
In each line, the first column is the job id, the second column is the partition (which part of the cluster the job is being run on), the third column is the name of job, the fourth column is the the user name of the person who submitted the job, the next column is just one or two letters indicating the job status, the next column is the duration that the job has been running, the next-to-last column is the number of nodes the job is running on, and the final column is list of nodes that the job is running on.

Check on your job's status.  Common letters in the status column are PD for pending (i.e., waiting to start), R for running, and CG for completing (cleaning up after your job has finished).
The time required for your job to start depends on how many resources you've requested and how many resources have been consumed by other jobs that you've run recently.  It will likely take at a few seconds to start (but potentially longer, particularly during class when we might be collectively using our full allocation.  If it's taking a while to start, then you can skip ahead to step 7 (and come back to 6 later, after your job has completed).

Once your job starts, it should finish quickly.  At that point, the job status should change to 'CG' (completing), and a little while later, it will be removed from the list of jobs listed by `squeue`.

6. Once you're job is done, there should be a new file in the directory that you submitted the job from with a name like `ex1_serial_5946548.log`, where the number is the numerical portion of the Slurm JOB ID.
Inspect this file to make sure the job behaved as expected.  If so, use git to add, commit, and push it to your GitHub repository.  
If any of your attempts don't work, then fix the issue, try again.  Once you get it to work, delete the old output from the broken jobs and only add/commit/push the output once you've gotten it working.

### Submitting & Running a Parallel Job

7. Now, test the parallel code (first using just a few cores all on one compute node).  Look over the file [ex1_parallel_1node.slurm](ex1_parallel_1node.slurm) and note how it differs from [ex1_serial.slurm](ex1_serial.slurm).  Then submit a batch job using
 ```sh
 sbatch ex1_parallel_1node.slurm
 ```
Check on the job status, and once it's finished, inspect the output, and make sure it did what you expected.  

Once the parallel job runs successfully, use git to add, commit, and push it to your GitHub repository.
And if it's taking a while to start, then you can skip ahead to step 8 or 9 (and come back to finish this step later after your parallel job has completed).

8. Next, test the parallel code (using multiple cores, spanning multiple compute nodes).  Look over the file [ex1_parallel_multinode.slurm](ex1_parallel_multinode.slurm) and note how it differs from [ex1_serial.slurm](ex1_serial.slurm) and [ex1_parallel_1node.slurm](ex1_parallel_1node.slurm).  Then inspect [setup_slurm_manager.jl](setup_slurm_manager.jl) to see how we're adding the worker processors assigned by slurm. Then submit a batch job using
 ```sh
 sbatch ex1_parallel_multinode.slurm
 ```

If you're interested, you can try changing the number of cores or nodes requested or other Slurm job parameters.  

9. Next, test the parallel code using multiple processes on different nodes, but multiple threads within each node.  Look over the file [ex1_parallel_combo.slurm](ex1_parallel_combo.slurm) and note how it differs from [ex1_parallel_multinode.slurm](ex1_parallel_multinode.slurm).  Then submit a batch job using
 ```sh
 sbatch ex1_parallel_combo.slurm
 ```




### Submitting & Running a Job Array

Often, a scientist will want to run several jobs that do basically the same calculations, but using slightly different inputs.  Those could be as simple as different random seeds (so that you don't accidentally do exactly the same calculation twice in two different jobs).  Or each job could analyze data stored in different input files (e.g., a bunch of spectra in separate FITS files).  While you could submit each of these as an individual job, this can be tedious and error prone, so there's a convenient way to submit a "job array".  (If you're just submitting a dozen jobs, it's not hard to write your own scripts that are equally good.  But if you're submitting hundreds of jobs, then it's actually important to use job arrays, so as not to overload the scheduler.)  Submitting a job array is easy, you just add a line '#SBATCH --array=N-M' to the slurm script, where N and M are the lower and upper bounds of the job array ids.  If you're submitting a large number of jobs, then you can also specify a maximum number of jobs (P) that will be allowed to run at once using '#SBATCH --array=N-M%P'.

10.  In order for each job in the job array to do what we want (rather than the same thing each time), we'll need to add some code at the beginning of the program, so each job can figure out precisely what it should do.  In this example, we'll write the characteristics for each job to a file and then read that file in at the beginning of each job.  To create such a file, inspect and run the notebook [ex1_PrepareInputForJobArrays.jl](ex1_PrepareInputForJobArrays.jl).  You can either run it from the command line with
```sh
julia --project ex1_PrepareInputForJobArrays.jl
```
Verify that the file 'ex1_job_array_in.csv' was created and contains the values you expect.

10.  Inspect the script the slurm script [ex1_job_array.slurm](ex1_job_array.slurm) and compare it to [ex1_serial.slurm](ex1_serial.slurm).  Submit the job using
```sh
sbatch ex1_job_array.slurm
```
To check the status of each individual element of the job array, you can use `squeue` but add the '-r' option array like `squeue -r`.

11.  Check on the job status, and once they've finished, inspect the output, and make sure it did what you expected.  Then use git to add, commit, and push the output files to your GitHub repository.


## Exercise 2:  Parallel Programming for Distributed-Memory Model
#### Goals:
- Reinforce programming using [`Distributed Arrays`](https://juliaparallel.github.io/DistributedArrays.jl/latest/)
- Explain differences in performance when using multiple processor cores on the same node versus using multiple processor cores on different nodes

#### Step-by-step Instructions:

In this exercise, we'll perform the same calculations as in [exercise 2 of lab 6](https://github.com/PsuAstro528/lab6/blob/master/ex2.ipynb).  However, instead of using a shared-memory model (possible on a multi-core workstation) as in Lab 6, we will run the calculations on multiple compute nodes spread across the Lynx cluster using a distributed memory model.

You're welcome to inspect or even run the [ex2.ipynb notebook](ex2.ipynb) one cell at a time to see how it works.  However, the main point of this lab is to see how to run such a calculation in parallel over multiple processor cores that are not necessarily on the same processor.  (Then, you'll compare the performance depending on whether the processors assigned are on the same node or different nodes.)

1. Inspect [ex2_parallel_1node.slurm](ex2_parallel_1node.slurm) and [ex2_run_nb.jl](ex2_run_nb.jl).  Update the slurm script to include your email address.  Then submit the slurm script [ex2_parallel_1node.slurm](ex2_parallel_1node.slurm) using `sbatch`.  The email notifications are particularly useful for this exercise, as they'll tell you how long your job waited in the queue as well as how long it took to run.  Once the job completes, inspect the output files to make sure it performed as expected.  

2.  Inspect [ex2_parallel_multinode.slurm](ex2_parallel_multinode.slurm) and compare it to [ex2_parallel_1node.slurm](ex2_parallel_1node.slurm).  Submit this job via `sbatch`. Once the job completes, inspect the output log file to make sure it performed as expected.

3.  Inspect [ex2_parallel_combo.slurm](ex2_parallel_combo.slurm) and compare it to [ex2_parallel_multinode.slurm](ex2_parallel_multinode.slurm).  Submit this job via `sbatch`. Once the job completes, inspect the output log file to make sure it performed as expected.

4.  Modify [ex2_parallel_1node.slurm](ex2_parallel_1node.slurm) and [ex2_parallel_multinode.slurm](ex2_parallel_multinode.slurm) so that each of them uses 16 CPU cores.  Change the lines with SBATCH options '--nodes', '--ntasks-per-node', and '--ntasks' as needed, so that the first job uses 16 cores on one node, the second uses 16 cores spread across two nodes, and the third uses 8 cores on each of 2 nodes.  Submit all three as a job via `sbatch`.  Once the new jobs finish, inspect the output log files to make sure that they ran succesfully.  

5.  Compare and contrast the performance time required for various steps and add your responses to this README below.  

5a. How did the time required to perform the 'map(...)' calculations compare between when the assigned processors were on the same node versus on different nodes?  (Remember to ignore the first call in each set of calls due to compilation.)

INSERT RESPONSE

5b. How did the time required to perform the 'collect(map(...))' calculations compare between when the assigned processors were on the same node versus on different nodes?

INSERT RESPONSE

5c. How did the time required to perform the 'mapreduce(...)' calculations compare between when the assigned processors were on the same node versus on different nodes?

INSERT RESPONSE

5d. What explains differences in the relative timing of the three calculations discussed above?

INSERT RESPONSE

5e. At the end of the notebook, it gradually removed worker processes and benchmarked the function to compute the mean squared error.  Did the scaling of run time versus number of workers avaliable change depending on whether the processes were assigned to the same node or different nodes?

INSERT RESPONSE

5f. How did the time that your jobs waited in the queue before starting compare depending on whether you asked for all the processors to be on compute node?

INSERT RESPONSE

5g.  What is the ex2_parallel_combo.slurm script doing differently than ex2_parallel_multinode.slurm?  Why would that be important for using many CPU cores?

INSERT RESPONSE

## Exercise 3:  Run code using a container
#### Goals:
- Submit and run jobs using apptainer
- Compare wall time when using a generic container and one built specifically for your project.

1.  Inspect [julia_minimal.def](julia_minimal.def), [build_container_minimal.sh](build_container_minimal.sh), and [ex1_serial_apptainer_minimal.slurm](ex1_serial_apptainer_minimal.slurm).  Submit a job to be run within a container using `sbatch ex1_serial_apptainer_minimal.slurm`.  Check on the job status, and once it's finished, inspect the output, and make sure it did what you expected.

2.  Inspect [julia_lab7.def](julia_lab7.def), [build_container_lab7.sh](build_container_lab7.sh), and [ex1_serial_apptainer_lab7.slurm](ex1_serial_apptainer_lab7.slurm).  Submit a job to be run within a container using `sbatch ex1_serial_apptainer_lab7.slurm`.  Check on the job status, and once it's finished, inspect the output, and make sure it did what you expected.  

What is the lab7 version of the scripts doing differently than the minimal version?  
Why would it be worth creating a container built specifically for lab7 rather than using the generic Julia container?

INSERT RESPONSE


## Exercise 4:  Run your project code using the Cluster
#### Goals:
- Apply lessons learned in exercises 1 & 2 for your own class project

#### Step-by-step Instructions:

1.  Create a slurm script that successfully runs an example case using your project's serial code.  (If you don't have a working example yet, then you can have the script run your project's tests.)

2.  Create a new slurm script that runs and benchmarks your project's serial code for different problem sizes.  Depending on the details of your project, you might have one '.jl' or '.ipynb' file that performs all the benchmarks in sequence (like at the end of ex2), or you might have a separate slurm script for each problem size that you benchmark.

3.  I expect that some students will only get to this and subsequent steps after the due date for Lab 7.  It's fine if it takes a little longer before you're ready to benchmark your parallel code.  But I do want everyone to compare benchmarks as a function of problem size and number of processesor used in time to include in their project presentation.  Therefore, I'm including instructions here for whenever you're ready to start benchmarking your parallel code.  Once you have a parallel version of your project code working in an interactive environment, then make a Slurm script that runs the parallel version of your code.  Run the script, make sure that it gives the expected results and that it's actually using the processors its been assigned (as opposed to running in serial).

4.  Benchmark the performance of your code as a function of the number of processors used, keeping the problem size fixed.  Make a plot showing the *strong scaling* of the performance critical section of your code (i.e., run time as a function of problem size) as the number of processors varies from 1, 2, 4, 8, 12, 16, 20, 24, and 32.  How does the performance benefit compare to a linear scaling?  If your code is scaling well even at >16 processors (i.e., the run time continues to decrease nearly linearly with number of processors), then keep increasing the number of processors until the run time levels off (maximum of 48 cores for shared memory jobs, maximum of 96 cores for distributed memory jobs).

5.  Repeat the benchmarks from step 4, but using at least a few problem sizes (spanning at least two orders of magnitude if possible, i.e., big enough so that you can see the benefits of parallelism).

6. Benchmark the performance of your code as a function of the number of processors used, but now growing the problem size in proportion to the number of processors.  Make a plot showing the *weak scaling* of the performance critical section in your code (i.e., run time as a function of problem size) changing the problem size by at least a factor of 16.  How does the run time scale with the problem size (and number of processors)?

7.  Repeat step 6, but now compare the performance when using multiple processor cores on a single node versus the same number of processor cores spread across multiple nodes.  

8.  Save the scripts you use for this exercise.  You might even want to clean them up and document them.  Near the end of the semester, you'll repeat this process for both of the parallel versions of your code.  (Hopefully, the results may improve as you optimize your parallel code between now and then.)  Then, you'll show the resulting figures in your presentation and final report to help illustrate what you learned about how well your code parallelizes.

