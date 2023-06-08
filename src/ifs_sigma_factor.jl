@concrete struct SigmaFactorIFS{Dim,T} <: AbstractIFS{Dim,T}
    transforms # Affine transforms
    catdist # Categorical distribution
end

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

function Base.rand(rng::AbstractRNG, ::Random.SamplerType{SigmaFactorIFS{2}})
    rand(rng, SigmaFactorIFS{2,Float64})
end
