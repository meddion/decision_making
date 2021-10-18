module Helpers
using LinearAlgebra, LightGraphs, GraphPlot, Colors

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

function plot_graph(R::Matrix{Bool}, nodelabel = [])
    g = SimpleDiGraph(R)
    nodesize = [LightGraphs.outdegree(g, v) for v in LightGraphs.vertices(g)]
    alphas = nodesize/maximum(nodesize)
    nodefillc = [RGBA(0.9,0.7,0.7,i) for i in alphas*1.5]
    if isempty(nodelabel)
        nodelabel = [i for i in 1:size(R)[1]]
    end
    gplot(g,  layout=circular_layout, linetype="straight", nodelabel=nodelabel, nodefillc=nodefillc) |> display
end

#consistency_check(R1::Matrix{Bool}, R2::Matrix{Bool}) = @assert size(R1) == size(R2) "size(R1) must equal size(R2)" 
consistency_check(R1, R2) = ()
"""
R1 = Bool[1 1 1 1; 0 1 1 1; 0 1 0 0; 1 0 1 0]
R2 = Bool[0 1 0 1; 0 0 0 1; 0 1 0 0; 0 0 1 0]
r_mult(R1, R2) |> display

4×4 Matrix{Bool}:
 0  1  1  1
 0  1  1  1
 0  0  0  1
 0  1  0  1
"""
function matrix_op(relation)
    return function r_union(R1, R2)
        consistency_check(R1, R2)
        new_R = copy(R1)
        map(arg -> relation(R2[arg[1]], arg[2]), enumerate(new_R))
    end
end

# добуток/композиція
function r_mult(R1::Matrix{Bool}, R2::Matrix{Bool})
    consistency_check(R1, R2)
    r, c = size(R1)
    R_new = zeros(Bool, r, c)
    for i in 1:r, j in 1:c
        R_new[i, j] = any(R1[i, :] .& R2[:, j])
    end
    R_new
end
    
# об'єднання
r_union = matrix_op(|)
# перетин
r_intersec = matrix_op(&)
# обернене
r_rotated(R::Matrix) = transpose(R)
# доповнення
r_inverse(R::Matrix) = map(!, R)

export create_realtions, r, colder_eq, plot_graph, r_intersec, r_inverse, r_mult, r_union, r_rotated
end