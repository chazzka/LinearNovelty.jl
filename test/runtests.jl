using LinearNovelty
using JuMP
using HiGHS
using LinearAlgebra
using Test
using Lazy
using Base.Iterators #for product
using CSV
using DataFrames
using Downloads

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
    @test length(alpha) == 3
    @variable(model, b)
    
    osmres = osmicka(kMat, alpha, b)
    
    @constraint(model, c1, sum(alpha) == 1)
    @constraint(model, [i in 1:3], osmres[i]>= 0)
    
    @objective(model, Min, sum(osmres))

    optimize!(model)

    @test isapprox(objective_value(model),0; atol=0.01)


end;

@testset "get_optimized_values_test" begin

    (alphas, bias) = get_optimized_values([[1,2,3],[4,5,6],[7,8,9]],K, osmicka)
    @test alphas == [0.5, 0, 0.5]
    @test isapprox(bias, -1; atol=0.01)

end;

@testset "jejich_example" begin

    # pole alpha - z funkce get optimized - uceni bez novelty
    # pole inputů xj - nove inputy (regulary)
    # hodnotu kterou chces vedet jestli je novelty z
    # learning phase

    data = [[1,2,3],[4,5,6],[7,8,9],[1,2,5]]
    test_regular = [1,2,4]
    novelty = [99,88,77]
    (alphas, bias) = get_optimized_values(data,K, osmicka)
    # predict phase
    
    kMat(f,s) = @>> product(f, s) map(K)
    @show kMat(data, [novelty])

    @show osmicka(kMat(data, [novelty])', alphas, bias)
    @show osmicka(kMat(data, [test_regular])', alphas, bias)
    @show osmicka(kMat(data, data), alphas, bias)
    @show osmicka(kMat(data, [data[2]])', alphas, bias)

end;

@testset "jejich_example_mene_D" begin

    # pole alpha - z funkce get optimized - uceni bez novelty
    # pole inputů xj - nove inputy (regulary)
    # hodnotu kterou chces vedet jestli je novelty z
    # learning phase

    data = [[0,0],[2,2],[0,2],[2,0]]
    test_regular = [1,1]
    novelty = [100,100]
    (alphas, bias) = get_optimized_values(data,K, osmicka)
    # predict phase
    
    kMat(f,s) = @>> product(f, s) map(K)
    @show kMat(data, [novelty])

    @show osmicka(kMat(data, [novelty])', alphas, bias)
    @show osmicka(kMat(data, [test_regular])', alphas, bias)
    @show osmicka(kMat(data, data), alphas, bias)
    @show osmicka(kMat(data, [data[2]])', alphas, bias)

end;

@testset "test_predict" begin

    data = [[1,2,3],[4,5,6],[7,8,9],[1,2,5]]
    novelty = [[99,88,77], [100,200,300]]
    (alphas, bias) = get_optimized_values(data,K, osmicka)
    # predict phase
    res = @>> alphas map(≉(0)) BitVector
    normalized_res = predict(data[res], novelty, alphas[res], bias, K)
    #test that the desired points are indeed novelties == 1
    @test normalized_res == [1,1]

end;

@testset "clanek" begin
    train = CSV.read(Downloads.download("https://raw.githubusercontent.com/chazzka/novelties_datasets/main/clicked/csv/data_novelties_clicked_train.csv"), DataFrame; header=false)
    test = CSV.read(Downloads.download("https://raw.githubusercontent.com/chazzka/novelties_datasets/main/clicked/csv/data_novelties_clicked_test.csv"), DataFrame; header=false)

    # remove class column
    select!(train, Not([:Column3]))
    select!(test, Not([:Column3]))

    #convert to vector of vectors idk
    trainVV = Vector{Float64}[eachcol(Matrix(train)')...]
    testVV = Vector{Float64}[eachcol(Matrix(test)')...]

    (alphas, bias) = get_optimized_values(trainVV, K, osmicka)
    res = @>> alphas map(≉(0;atol=0.01)) BitVector
    @show length(trainVV)
    @show length(testVV)
    @show length([trainVV; testVV])

    @show predict(trainVV[res], [trainVV; testVV], alphas[res], bias, K)

end;
