@concrete struct Affine
    W
    b
end

function (aff::Affine)(x)
    return aff.W * x .+ aff.b
end

abstract type AbstractIFS{Dim,T} end

@concrete struct SigmaFactorIFS{Dim,T} <: AbstractIFS{Dim,T}
    transforms # Affine transforms
    catdist # Categorical distribution
end