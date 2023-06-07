function uniform(
    rng::AbstractRNG, a::T, b::T,
) where {T<:AbstractFloat}
    return (b - a) * rand(rng, T) + a
end

function uniform(rng::AbstractRNG, a::Real, b::Real)
    return uniform(rng, float.(promote(a, b))...)
end
