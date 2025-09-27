using Distributed 
@everywhere using ParallelUtilities

@everywhere function calc_num_in_unit_circle(n::Integer)
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

if !isdefined(Main, :n) 
   if length(ARGS) < 1
      @error "Usage: julia --project -p num_workers -- ex1_parallel.jl num_throws"
      exit(1)
   else
       n = parse(Int64,ARGS[1])
   end
end
@assert n >= 100

n_per_worker = floor(Int64,n//nworkers())
n_actual = n_per_worker * nworkers()
# Run once to force compile of needed functions
calc_pi_monte_carlo(n_actual; n_in_circle = pmapreduce(calc_num_in_unit_circle, +, fill(1, nworkers()) ) ) 
GC.gc()     # Force garbage collection before timing

@time pi_estimate = calc_pi_monte_carlo(n_actual; n_in_circle = pmapreduce(calc_num_in_unit_circle, +, fill(n_per_worker, nworkers()) ) ) 
println("# After ", n_per_worker, " itterations on each of ", nworkers(), " workers, estimated pi to be...")
println(pi_estimate)
