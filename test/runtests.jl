using LinearNovelty
using JuMP
using HiGHS
using LinearAlgebra
using Test
using Lazy
using Base.Iterators #for product

@testset "LinearNovelty" begin
    @test 5+5 == 10
    @test K(([5,5], [5,5])) ≈ 1
    @test sum(osmicka([1; 1; 1] * [1 1 1], [2,2,2], 2)) == 24
end;

@testset "fullexample" begin
    # defaults
    data = [[1,2,3],[4,5,6],[7,8,9]]
    kMat = @>> product(data, data) map(K)
    @test size(kMat) == (3,3)
    model = Model(HiGHS.Optimizer)
    #should define alpha variable
    @variable(model, 0<= alpha[j = 1:3])
    print(alpha)
    @test length(alpha) == 3
    @variable(model, b)
    
    osmres = osmicka(kMat, alpha, b)
    
    @constraint(model, c1, sum(alpha) == 1)
    @constraint(model, [i in 1:3], osmres[i]>= 0)
    
    @objective(model, Min, sum(osmres))

    optimize!(model)

    @test isapprox(objective_value(model),0; atol=0.01)

    print(value.(alpha))

end;

@testset "example" begin

    # pole alpha - z funkce get optimized - uceni bez novelty
    # pole inputů xj - nove inputy (regulary)
    # hodnotu kterou chces vedet jestli je novelty z
    print(get_optimized_values([[1,2,3],[4,5,6],[7,8,9]], osmicka))

end;

