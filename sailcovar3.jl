import Pkg;
Pkg.add("JuMP")
Pkg.add("Clp")
Pkg.add("Printf")

using JuMP, Clp, Printf

d = [40 60 75 25] 

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:5] <= 40 )    # boats produced with regular labor
@variable(m, y[1:5] >= 0)           # boats produced with overtime labor
@variable(m, ih[1:5] >= 0)            # increase //  boats held in inventory
@variable(m, dh[1:5] >= 0)            #decrease  // boats held in inventory
@variable(m, decre[1:4] >= 0)              #decrease replace
@variable(m, incre[1:4] >= 0)              #increase replace 
@constraint(m, ih[5] >= 10)  
@constraint(m, dh[5] <= 0)  
@constraint(m, ih[1] == 10) 
@constraint(m, x[1] == 40)          #maximum value for x is 40
@constraint(m, y[1] == 10)

@constraint(m, flowincdecc[i in 1:4], x[i+1]+y[i+1]-(x[i]+y[i])==incre[i]-decre[i])
@constraint(m, flowincdech[i in 1:4], x[i+1]+y[i+1]+ih[i]-dh[i]==ih[i+1]-dh[i+1]+d[i])


@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(ih) + 400*sum(incre) + 500*sum(decre) + 100*sum(dh))     # minimize costs

optimize!(m)

@printf("Boats to build regular labor: %d %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]), value(x[5]))
@printf("Boats to build extra labor: %d %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]), value(y[5])) 
@printf("increase replace in production: %d %d %d %d\n", value(incre[1]), value(incre[2]), value(incre[3]), value(incre[4]))
@printf("decrease replace in production: %d %d %d %d\n", value(decre[1]), value(decre[2]), value(decre[3]), value(decre[4]))
@printf("increase replace in boats ready: %d %d %d %d %d\n", value(ih[1]), value(ih[2]), value(ih[3]), value(ih[4]), value(ih[5]))
@printf("decrease replace in boats ready: %d %d %d %d %d\n", value(dh[1]), value(dh[2]), value(dh[3]), value(dh[4]), value(dh[5]))


@printf("Objective cost: %f\n", objective_value(m))