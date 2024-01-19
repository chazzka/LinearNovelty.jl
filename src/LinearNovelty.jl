module LinearNovelty
using JuMP
using HiGHS
using LinearAlgebra

export K

K((x,y), euler = 2.7182818, sigma=100) = euler^(-norm(x-y)^2/(2*sigma^2))

# osmicka later v testech

# initModel() = Model(HiGHS.Optimizer)

# # registers variable automaically
# set_var!(model, condition) = @variable(model, condition)

# set_constraints!(model, loop, condition) = @constraint(model, loop, condition)

# set_objective!(model, minormax, fun) = @objective(model, minormax, fun)


end
