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

if length(ARGS) < 1
   @error "Usage: julia --project -- ex1_serial.jl num_throws"
   exit(1)
else
    n = parse(Int64,ARGS[1])
    @assert n >= 100
end

#n = 1_000_000_000;
calc_pi_monte_carlo(1)  # Force compile
GC.gc()     # Force garbage collection before timing
@time pi_estimate = calc_pi_monte_carlo(n)
println("# After ", n, " itterations, estimated pi to be...")
println(pi_estimate)
