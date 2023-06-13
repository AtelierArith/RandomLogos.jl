"""
Type for sampling IFS based on SVD approach proposed
on [this page](https://catalys1.github.io/fractal-pretraining/)

# Examples

```julia-repl
julia> using RandomLogos: SigmaFactorIFS
julia> using RandomLogos: generate_points, render!
julia> using Random, ImageInTerminal, ImageCore
julia> rng = Xoshiro(0)
julia> ifs = rand(rng, SigmaFactorIFS{2}) # create an instance of SigmaFactorIFS
julia> npoints = 100_000; H = W = 384
julia> xs, ys = generate_points(rng, ifs, npoints, H, W)
julia> canvas = zeros(RGB{N0f8}, H, W)
julia> render!(rng, canvas, xs, ys, ifs)
```

See also [`generate_points`](@ref), [`generate_points!`](@ref), [`render`](@ref) and [`render!`](@ref)
"""
@concrete struct SigmaFactorIFS{Dim,T} <: AbstractIFS{Dim,T}
    transforms # Affine transforms
    catdist # Categorical distribution
end

"""
    sample_svs(rng::AbstractRNG, α::T, N::Integer) where {T <: AbstractFloat}
Given α so called σ-factor, create `N` tuples in the form of (σₖ₁, σₖ₂) for k ∈ 1:N such that

``\\alpha = \\sum_{k=1}^N \\sigma_{k1} + 2\\sigma_{k2}``

Returns N by 2 matrix Σ::Matrix{T}(N, 2) that satisfies Σ[k, 1] is σₖ₁ and Σ[k, 2] is σₖ₂.
"""
function sample_svs(rng::AbstractRNG, α::T, N::Integer) where {T<:AbstractFloat}
    Σ = zeros(T, N, 2)
    # sampling lower bound
    bₗ = α - 3N + 3
    # sampling upper bound
    bᵤ = α
    half = T(0.5)
    third = T(3)
    for k in 1:(N-1)
        # define σₖ₁
        σₖ₁ = uniform(rng, max(zero(T), bₗ / third), min(one(T), bᵤ))
        bₗ = bₗ - σₖ₁
        bᵤ = bᵤ - σₖ₁
        # define σₖ₂
        σₖ₂ = uniform(rng, max(zero(T), half * bₗ), min(σₖ₁, half * bᵤ))
        bₗ = bₗ - 2σₖ₂ + 3
        bᵤ = bᵤ - 2σₖ₂
        Σ[k, 1] = σₖ₁
        Σ[k, 2] = σₖ₂
    end
    σ₂ = uniform(
        rng,
        max(zero(T), half * (bᵤ - one(T))),
        bᵤ / third,
    )
    σ₁ = bᵤ - 2σ₂
    Σ[N, 1] = σ₁
    Σ[N, 2] = σ₂
    return Σ
end

function Base.rand(
    rng::AbstractRNG,
    ::Random.SamplerType{SigmaFactorIFS{2,T}},
) where {T<:AbstractFloat}
    N = rand(rng, (2, 3, 4))
    αₗ::T = 0.5(5 + N)
    αᵤ::T = 0.5(6 + N)
    σfactor = uniform(rng, αₗ, αᵤ)
    svs = sample_svs(rng, σfactor, N)
    WType = SMatrix{2,2,T,4}
    bType = SVector{2,T}
    transforms = Affine{WType,bType}[]
    for k in axes(svs, 1)
        σ₁, σ₂ = svs[k, 1], svs[k, 2]
        Rθ = rand(rng, RotMatrix{2,T})
        Rϕ = rand(rng, RotMatrix{2,T})
        Σ = diagm(SVector{2,T}([σ₁, σ₂]))
        D = diagm(SVector{2,T}(2rand(rng, Bool, 2) .- 1))
        W = Rθ * Σ * Rϕ * D
        b₁ = uniform(rng, -one(T), one(T))
        b₂ = uniform(rng, -one(T), one(T))
        b = @SVector [b₁, b₂]
        push!(transforms, Affine(W, b))
    end

    probability_vector = [abs(det(t.W)) for t in transforms]
    probability_vector ./= sum(probability_vector)
    catdist = Categorical(probability_vector)
    return SigmaFactorIFS{2,T}(transforms, catdist)
end

function Base.rand(rng::AbstractRNG, ::Random.SamplerType{SigmaFactorIFS{2}})
    return rand(rng, SigmaFactorIFS{2,Float64})
end

"""
    generate_points!(rng::AbstractRNG, xs::Vector, ys::Vector, ifs::SigmaFactorIFS{2,T}, H::Integer, W::Integer) where {T<:AbstractFloat}

In-place version of [`generate_points`](@ref)
"""
function generate_points!(
    rng::AbstractRNG, xs::Vector, ys::Vector,
    ifs::SigmaFactorIFS{2,T}, H::Integer, W::Integer,
) where {T<:AbstractFloat}
    pt = @SVector zeros(T, 2)
    for i in eachindex(xs, ys)
        aff = ifs.transforms[rand(rng, ifs.catdist)]
        pt = aff(pt)
        x, y = pt
        xs[i] = x
        ys[i] = y
    end
    # normalize
    mx, Mx = vvextrema(xs)
    my, My = vvextrema(ys)

    # To prevent bounds errors when drawing points on a canvas,
    # an offset value of 5 is used.
    @. xs = (((W - 5) - 5) / (Mx - mx)) * (xs - mx) + 5
    @. ys = (((H - 5) - 5) / (My - my)) * (ys - my) + 5
    return xs, ys
end

"""
    generate_points(rng::AbstractRNG, ifs::SigmaFactorIFS{2,T}, n::Integer, H::Integer, W::Integer) where {T<:AbstractFloat}

Generate a sequence of 2D points based on a given Iterated Function System (IFS)
and return the coordinates in two separate arrays, `xs` and `ys`. The function uses
the provided random number generator `rng`, IFS object `ifs`, and three integer
parameters: `n` (the number of points to generate), `H` (height), and `W` (width).

# Arguments
- `rng::AbstractRNG`: An object that generates random numbers.
- `ifs::SigmaFactorIFS{2,T}`: An Iterated Function System (IFS) to be used in generating points.
- `n::Integer`: The number of points to generate.
- `H::Integer`: The height of the output space.
- `W::Integer`: The width of the output space.

# Returns
- `xs`: The x-coordinates of the generated points.
- `ys`: The y-coordinates of the generated points.
"""
function generate_points(
    rng::AbstractRNG, ifs::SigmaFactorIFS{2,T},
    n::Integer, H::Integer, W::Integer,
) where {T<:AbstractFloat}
    xs = Vector{T}(undef, n)
    ys = Vector{T}(undef, n)
    generate_points!(rng, xs, ys, ifs, H, W)
    return xs, ys
end