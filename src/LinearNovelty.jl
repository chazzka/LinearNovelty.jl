module LinearNovelty
using JuMP
using HiGHS
using LinearAlgebra

export K, osmicka

K((x,y), euler = 2.7182818, sigma=100) = euler^(-norm(x-y)^2/(2*sigma^2))

osmicka(mat, alpha, b) = mat * alpha .+ b

end
