using CSV, DataFrames, Printf
using Random

function calc_num_in_unit_circle(n::Integer)
   num_in_unit_circle = 0
   for in in 1:n
      x = rand()
      y = rand()
      if x*x+y*y < 1
        num_in_unit_circle += 1
      end
   end
   return num_in_unit_circle
end


function calc_pi_monte_carlo(n_throws::Integer; n_in_circle::Integer = calc_num_in_unit_circle(n))
   4 * (n_in_circle/n_throws)
end

if length(ARGS) < 2
   @error "Usage: julia --project -- script.jl input_filename job_id"
   exit(1)
end
filename_job_array_inputs = ARGS[1]  # "ex1_job_array_in.csv"
job_array_data = CSV.read(filename_job_array_inputs, DataFrame)
job_arrayid = parse(Int64,ARGS[2])


idx = findfirst(x-> x==job_arrayid, job_array_data[!,:array_id] )
@assert !isnothing(idx)
@assert 1 <= idx  <= size(job_array_data, 1)

n = job_array_data[idx,:n]
s = job_array_data[idx,:seed]

Random.seed!(s)

# Run once to force compile of needed functions
calc_pi_monte_carlo(1)
stats = @timed pi_estimate = calc_pi_monte_carlo(n)
println("# After ", n, " itterations, array_id= ", job_arrayid, " estimated pi to be...")
println(pi_estimate)

# Write output to file to be analyzed later
output_filename = @sprintf("ex1_out_%02d.csv",job_arrayid)
df_out = DataFrame(result = [pi_estimate], walltime = [stats.time])
CSV.write(output_filename, df_out)
