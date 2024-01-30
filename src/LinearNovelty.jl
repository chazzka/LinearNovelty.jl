module LinearNovelty
using JuMP
using HiGHS
using LinearAlgebra
using Lazy
using Base.Iterators #for product

export K, osmicka, get_optimized_values, predict

K((x,y); sigma=100) = ℯ^(-norm(x-y)^2/(2*sigma^2))

osmicka(mat, alpha, b) = mat * alpha .+ b


# optimalizace alpha bez novelty (faze uceni)
get_optimized_values(input, K::Function, osmicka::Function) = begin
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

    return (value.(alpha), value(b))
end

normalize(arr) = begin
    return @>> begin
        arr
        map(x -> x < 0.0 ? 1 : 0)
    end
end

"""
Predict method return 1 if novelty, 0 otherwise
# Arguments
- `regular`: Array of arrays of regular points [[1],[1.1],[1.05]].
- `novelty`: Array of arrays of points we wish to evaluate [[100],[101]].
- `alphas, bias`: you get these from get_optimized_values function.
"""
predict(regular::AbstractArray, novelty::AbstractArray, alphas::AbstractArray, bias::AbstractFloat, K::Function) = begin
    return @>> begin
        novelty 
        product(regular) 
        map(K)
        res -> osmicka(res', alphas, bias)
        normalize
    end
end

end
