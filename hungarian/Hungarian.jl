module Hungarian

using LinearAlgebra
using SparseArrays

# Zero markers used in hungarian algorithm
# 0 => NON   => Non-zero
# 1 => Z     => ordinary zero
# 2 => STAR  => starred zero
# 3 => PRIME => primed zero
const NON = Int8(0)
const Z = Int8(1)
const STAR = Int8(2)
const PRIME = Int8(3)

include("Munkres.jl")

"""
    hungarian(costMat) -> (assignment, cost)

"""
function hungarian(costMat::AbstractMatrix)
    rowNum, colNum = size(costMat)
    # currently, the function `hungarian` automatically transposes `cost matrix` when there are more workers than jobs.
    costMatrix = rowNum ≤ colNum ? costMat : copy(transpose(costMat))
    matching = munkres(costMatrix)
    assignment = zeros(Int, rowNum)
    rows = rowvals(matching)
    for c = 1:size(matching,2), i in nzrange(matching, c)
        r = rows[i]
        if matching[r,c] == STAR
            if rowNum ≤ colNum
                assignment[r] = c
            else
                assignment[c] = r
            end
        end
    end
    # calculate minimum cost
    cost = sum(costMat[i...] for i in zip(1:rowNum, assignment) if i[2] != 0)
    return assignment, cost
end

export hungarian

end 
