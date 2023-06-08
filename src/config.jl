struct Config
    H::Int
    W::Int
    npoints::Int
    ifsname::String
    ndims::Int
    rngname::String
    seed::Int
end

function toifstype(name::AbstractString, vargs...; kwargs...)
    toifstype(Val{Symbol(name)}(), vargs...; kwargs...)
end

for IFSType in [:SigmaFactorIFS,]
    @eval function toifstype(::Val{nameof($IFSType)}, ndims::Integer, ::Type{T}=Float64) where {T<:AbstractFloat}
        return $IFSType{ndims, T}
    end
end

