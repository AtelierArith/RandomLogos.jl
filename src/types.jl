"""
Type for an affine transformation

``
\\textrm{Affine}(x) = Wx + b
``

# Example

```julia-repl
julia> using RandomLogos: Affine
julia> using StaticArrays
julia> W = @SMatrix rand(2, 2)
julia> b = @SVector rand(2)
julia> aff = Affine(W, b)
julia> x = @SVector rand(2)
julia> aff(x)
```
"""
@concrete struct Affine
    W
    b
end

function (aff::Affine)(x)
    return aff.W * x .+ aff.b
end

abstract type AbstractIFS{Dim,T} end
