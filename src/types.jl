"""
Type for an affine transformation
"""
@concrete struct Affine
    W
    b
end

function (aff::Affine)(x)
    return aff.W * x .+ aff.b
end

abstract type AbstractIFS{Dim,T} end
