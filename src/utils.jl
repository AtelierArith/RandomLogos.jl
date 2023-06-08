function uniform(
    rng::AbstractRNG, a::T, b::T,
) where {T<:AbstractFloat}
    return (b - a) * rand(rng, T) + a
end

function uniform(rng::AbstractRNG, a::Real, b::Real)
    return uniform(rng, float.(promote(a, b))...)
end

# https://github.com/JuliaLang/julia-logo-graphics
const JULIA_BLUE = RGB{N0f8}(0.251, 0.388, 0.847)
const JULIA_GREEN = RGB{N0f8}(0.22, 0.596, 0.149)
const JULIA_RED = RGB{N0f8}(0.796, 0.235, 0.2)
const JULIA_PURPLE = RGB{N0f8}(0.584, 0.345, 0.698)
const JULIA_WHITE = RGB{N0f8}(1,1,1)
const JULIA_COLORS = @SVector [JULIA_RED, JULIA_GREEN, JULIA_BLUE, JULIA_PURPLE]