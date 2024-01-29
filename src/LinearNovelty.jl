module LinearNovelty
using JuMP
using HiGHS
using LinearAlgebra

export K, osmicka

K((x,y); sigma=100) = ℯ^(-norm(x-y)^2/(2*sigma^2))

osmicka(mat, alpha, b) = mat * alpha .+ b

end
