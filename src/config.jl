struct Config
    H::Int
    W::Int
    npoints::Int
    ifsname::String
    ndims::Int
    rngname::String
    seed::Int
end

function Config(configpath::AbstractString)
    tostruct(Config, TOML.parsefile(configpath))
end

for IFSType in [:SigmaFactorIFS,]
    @eval function toifstype(::Val{nameof($IFSType)}, ndims::Integer, ::Type{T}=Float64) where {T<:AbstractFloat}
        return $IFSType{ndims, T}
    end
end

function toifstype(name::AbstractString, vargs...; kwargs...)
    toifstype(Val{Symbol(name)}(), vargs...; kwargs...)
end

function toifstype(config::Config)
    (; ifsname, ndims) = config
    toifstype(ifsname, ndims)
end
