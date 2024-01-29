module LinearNovelty
using JuMP
using HiGHS
using LinearAlgebra
using Lazy
using Base.Iterators #for product

export K, osmicka, get_optimized_values

K((x,y); sigma=100) = ℯ^(-norm(x-y)^2/(2*sigma^2))

osmicka(mat, alpha, b) = mat * alpha .+ b


# optimalizace alpha bez novelty (faze uceni)
get_optimized_values(input, osmicka) = begin
    model = Model(HiGHS.Optimizer)
    #this defines alpha variable
    @variable(model, 0<= alpha[j = 1:length(input)])
    @variable(model, b)
    
    kMat = @>> product(input, input) map(K)

    osmres = osmicka(kMat, alpha, b)
    
    @constraint(model, c1, sum(alpha) == 1)
    @constraint(model, [i in 1:length(input)], osmres[i]>= 0)
    
    @objective(model, Min, sum(osmres))

    optimize!(model)

    return value.(alpha)
end

end
