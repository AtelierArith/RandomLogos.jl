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
    return xs, ys
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

function render!(
    rng::AbstractRNG,
    canvas::Matrix{C},
    xs::Vector{T}, ys::Vector{T},
    ifs::AbstractIFS{2,T},
) where {C,T<:AbstractFloat}
    H, W = size(canvas)
    generate_points!(rng, xs, ys, ifs, H, W)
    c = rand(rng, JULIA_COLORS)
    for (x, y) in zip(xs, ys)
        canvas[trunc(Int, y), trunc(Int, x)] = c
    end
    canvas
end

function render(rng::AbstractRNG, ifs::AbstractIFS{2,T}, config::Config) where {T}
    (; npoints, H, W) = config
    canvas = zeros(RGB{N0f8}, H, W)
    xs = Vector{T}(undef, npoints)
    ys = Vector{T}(undef, npoints)
    render!(rng, canvas, xs, ys, ifs)
end

function render(ifs::AbstractIFS, config::Config)
    render(Random.default_rng(), ifs, config)
end

function render(config::Config)
    (; rngname, seed, ifsname, ndims) = config
    rng = eval(Symbol(rngname))(seed)
    IFSType = toifstype(ifsname, ndims)
    ifs = rand(rng, IFSType)
    render(rng, ifs, config)
end

function render(configpath::AbstractString)
    config = Config(configpath)
    render(config)
end
