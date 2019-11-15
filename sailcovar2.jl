import Pkg;
Pkg.add("JuMP")
Pkg.add("Clp")
Pkg.add("Printf")

using JuMP, Clp, Printf

d = [40 60 75 25]    

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40 )       # boats produced with regular labor
@variable(m, y[1:4] >= 0)              # boats produced with overtime labor
@variable(m, h[1:5] >= 0)              # boats held in inventory
@variable(m, decre[1:4] >= 0)             #Decrease replace
@variable(m, incre[1:4] >= 0)             #Increase replace 
@constraint(m, h[4] >= 10)  
@constraint(m, h[1] == 10)
@constraint(m, flow[i in 1:4], h[i]+x[i]+y[i]==d[i]+h[i+1])    # protect of boats
@constraint(m, flow[i in 1:4], x[i]+y[i]-(x[i-1]+y[i-1])==ci[i]+decre[i])
@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h) + 400*sum(ci) + 500*sum(decre))         # minimize costs

optimize!(m)

@printf("Boats to build regular labor: %d %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("increase replace in production: %d %d %d %d %d\n", value(incre[1]), value(incre[2]), value(incre[3]), value(incre[4]))
@printf("decrease replace in production: %d %d %d %d %d\n", value(decre[1]), value(decre[2]), value(decre[3]), value(decre[4]))

@printf("Objective cost: %f\n", objective_value(m))