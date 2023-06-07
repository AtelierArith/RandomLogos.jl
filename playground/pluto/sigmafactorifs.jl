### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# ╔═╡ 054dce6a-04cb-11ee-2a16-45c1afdc7094
begin
    using Pkg
    Pkg.activate(Base.current_project())
end

# ╔═╡ df934706-6a1b-4e9b-893e-47bbcefe0e71
begin
    using Random
    using LinearAlgebra

    using ConcreteStructs
    using Distributions
    using Images
    using Rotations
    using StaticArrays
    using VectorizedReduction
end

# ╔═╡ d12cdcd3-b810-44b1-a3c2-a91235d8c7e2
begin
    using BenchmarkTools
end

# ╔═╡ a8b071a1-d8b5-4aaf-a330-6140274f1fea
begin
    @concrete struct Affine
        W
        b
    end

    function (aff::Affine)(x)
        return aff.W * x .+ aff.b
    end
end

# ╔═╡ 2f17f0cc-995a-4512-b8af-40c1e3a898a8
begin
    abstract type AbstractIFS{Dim,T} end

    @concrete struct SigmaFactorIFS{Dim,T} <: AbstractIFS{Dim,T}
        transforms
        catdist
    end
end

# ╔═╡ b2fa4245-4714-40f7-8e91-e53b7954fbf2
begin
    function uniform(
        rng::AbstractRNG, a::T, b::T,
    ) where {T<:AbstractFloat}
        return (b - a) * rand(rng, T) + a
    end

    function uniform(rng::AbstractRNG, a::Real, b::Real)
        return uniform(rng, float.(promote(a, b))...)
    end

    #=
    	function uniform(a::Real, b::Real)
    		return uniform(Random.default_rng(), a, b)
    	end
    	=#
end

# ╔═╡ 1743156b-a841-4672-b67e-b0242824cb64
function sample_svs(
    rng::AbstractRNG,
    σfactor::T, N::Integer,
) where {T<:AbstractFloat}
    Σ = zeros(T, N, 2)
    # sampling lower bound
    bₗ = σfactor - 3N + 3
    # sampling upper bound
    bᵤ = σfactor
    half = T(0.5)
    third = T(3)
    for k in 1:(N-1)
        # define σₖ₁
        σₖ₁ = uniform(
            rng,
            max(zero(T), bₗ / third),
            min(one(T), bᵤ),
        )
        bₗ = bₗ - σₖ₁
        bᵤ = bᵤ - σₖ₁
        # define σₖ₂
        σₖ₂ = uniform(rng,
            max(zero(T), half * bₗ),
            min(σₖ₁, half * bᵤ),
        )
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

# ╔═╡ a482cf7f-2c1c-47bc-b3fb-e386982aed71
let
    rng = Xoshiro(999)
    T = Float32
    N = 4
    αₗ::T = 0.5(5 + N)
    αᵤ::T = 0.5(6 + N)
    σfactor = uniform(rng, αₗ, αᵤ)
    @assert typeof(σfactor) == T
    svs = sample_svs(rng, σfactor, N)
    @assert sum(svs[:, 1] + 2svs[:, 2]) ≈ σfactor
end

# ╔═╡ 0bb29079-59be-415c-b1cc-c0a1edd811b4
begin
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
        SigmaFactorIFS{2,T}(transforms, catdist)
    end
end

# ╔═╡ da2240db-86b2-47b0-9754-52daa635f8bd
begin
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

        @. xs = (((W - 5) - 5) / (Mx - mx)) * (xs - mx) + 5
        @. ys = (((H - 5) - 5) / (My - my)) * (ys - my) + 5
        return (xs, ys)
    end

    function generate_points(
        rng::AbstractRNG, ifs::SigmaFactorIFS{2,T},
        npoints::Integer, H::Integer, W::Integer,
    ) where {T<:AbstractFloat}
        xs = Vector{T}(undef, npoints)
        ys = Vector{T}(undef, npoints)
        generate_points!(rng, xs, ys, ifs, H, W)
        return xs, ys
    end
end

# ╔═╡ 4dc249ad-0322-4e62-be39-69ff34eec06b
begin
    rng = Xoshiro(4)
    T = Float64
    ifs = rand(rng, SigmaFactorIFS{2,T})
    @show ifs.transforms |> length
    H = 384
    W = 384
    npoints = 100_000
    xs = Vector{T}(undef, npoints)
    ys = Vector{T}(undef, npoints)
    canvas = zeros(Gray{N0f8}, H, W)
    @time generate_points!(rng, xs, ys, ifs, H, W)
    for (x, y) in zip(xs, ys)
        canvas[trunc(Int, y), trunc(Int, x)] = N0f8(0.5)
    end
    canvas
end

# ╔═╡ 2cd8c100-b478-4f91-95bb-a71529f50f2c
let
    rng = Xoshiro(66)
    T = Float64
    ifs = rand(rng, SigmaFactorIFS{2,T})
    H = 384
    W = 384
    npoints = 100_000
    xs = Vector{T}(undef, npoints)
    ys = Vector{T}(undef, npoints)
    canvas = zeros(Gray{N0f8}, H, W)
    @time generate_points!(rng, xs, ys, ifs, H, W)
end

# ╔═╡ 0cd54687-eb40-4497-92b5-5a2c5e18b6fb
function render!(
    rng::AbstractRNG, canvas::Matrix,
    xs::Vector{T}, ys::Vector{T}, ifs::AbstractIFS{2,T}, H::Integer, W::Integer,
) where {T<:AbstractFloat}
    generate_points!(rng, xs, ys, ifs, H, W)
    for (x, y) in zip(xs, ys)
        canvas[trunc(Int, y), trunc(Int, x)] = N0f8(0.5)
    end
    canvas
end

# ╔═╡ 9a61c0be-0c8c-40c5-98a3-a39ec336be21
function render()
    rng = Xoshiro(4)
    T = Float64
    ifs = rand(rng, SigmaFactorIFS{2,T})
    H = 384
    W = 384
    npoints = 100_000
    xs = Vector{T}(undef, npoints)
    ys = Vector{T}(undef, npoints)
    canvas = zeros(Gray{N0f8}, H, W)
    render!(rng, canvas, xs, ys, ifs, H, W)
end

# ╔═╡ 14916c09-ebaa-45bf-be42-cfd1b705e137
begin
    @benchmark render()
end

# ╔═╡ 10033038-c892-4515-9333-67dc66938cf2
let
    rng = Xoshiro(4)
    T = Float64
    ifs = rand(rng, SigmaFactorIFS{2,T})
    H = 384
    W = 384
    npoints = 100_000
    xs = Vector{T}(undef, npoints)
    ys = Vector{T}(undef, npoints)
    canvas = zeros(Gray{N0f8}, H, W)
    @benchmark render!($rng, $canvas, $xs, $ys, $ifs, $H, $W)
end

# ╔═╡ Cell order:
# ╠═054dce6a-04cb-11ee-2a16-45c1afdc7094
# ╠═df934706-6a1b-4e9b-893e-47bbcefe0e71
# ╠═d12cdcd3-b810-44b1-a3c2-a91235d8c7e2
# ╠═a8b071a1-d8b5-4aaf-a330-6140274f1fea
# ╠═2f17f0cc-995a-4512-b8af-40c1e3a898a8
# ╠═b2fa4245-4714-40f7-8e91-e53b7954fbf2
# ╠═1743156b-a841-4672-b67e-b0242824cb64
# ╠═a482cf7f-2c1c-47bc-b3fb-e386982aed71
# ╠═0bb29079-59be-415c-b1cc-c0a1edd811b4
# ╠═da2240db-86b2-47b0-9754-52daa635f8bd
# ╠═4dc249ad-0322-4e62-be39-69ff34eec06b
# ╠═2cd8c100-b478-4f91-95bb-a71529f50f2c
# ╠═0cd54687-eb40-4497-92b5-5a2c5e18b6fb
# ╠═9a61c0be-0c8c-40c5-98a3-a39ec336be21
# ╠═14916c09-ebaa-45bf-be42-cfd1b705e137
# ╠═10033038-c892-4515-9333-67dc66938cf2
