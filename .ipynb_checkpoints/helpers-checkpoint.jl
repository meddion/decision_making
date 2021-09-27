module Helpers
using LinearAlgebra

create_realtions(A, B, f=tuple) = hcat([ [f(i, j)  for i in A] for j in B]...)

function r(A, R, k, method='+')
    idx = method == '+' ? 1 : 2
    values = method == '+' ? A[:, k] : A[k, :]
    map(e -> e[idx], filter(e -> R(e[1], e[2]) == 1,  values)) |> collect
end

const A = ['В', 'З', 'Л', 'О']
# відношення "так само" та "холодніше"
function colder_eq(a, b) 
    A = ['Л', 'В', 'О']
    a == 'О' && return b in A[1:end]
    a == 'В' && return b in A[1:end-1]
    a == 'Л' && return b in A[1:end-2]
    true
end

export create_realtions, r, colder_eq
end