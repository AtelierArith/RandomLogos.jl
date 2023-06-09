"""
    render!
In-place version of [`render`](@ref)
"""
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

"""
    render(rng::AbstractRNG, ifs::AbstractIFS{2,T}, config::Config) where {T}

Generates a graphical rendering of 2D points based on a given Iterated Function System (IFS)
and configuration. The rendering is created within the bounds defined by the height `H` and
width `W` parameters provided in `config`.

# Arguments
- `rng::AbstractRNG`: An object that generates random numbers.
- `ifs::AbstractIFS{2,T}`: An Iterated Function System (IFS) to be used in generating points.
- `config::Config`: A configuration object with the following properties:
    - `npoints::Integer`: The number of points to generate for the rendering.
    - `H::Integer`: The height of the output space (canvas).
    - `W::Integer`: The width of the output space (canvas).

# Returns
- `canvas`: The generated image as an array of RGB values.
"""
function render(rng::AbstractRNG, ifs::AbstractIFS{2,T}, config::Config) where {T}
    (; npoints, H, W) = config
    canvas = zeros(RGB{N0f8}, H, W)
    xs = Vector{T}(undef, npoints)
    ys = Vector{T}(undef, npoints)
    render!(rng, canvas, xs, ys, ifs)
    return canvas
end

function render(ifs::AbstractIFS, config::Config)
    render(Random.default_rng(), ifs, config)
end

"""
    render(config::Config)

Generates a geometry object according to `config` to be used in generating one.
"""
function render(config::Config)
    (; rngname, seed, ifsname, ndims) = config
    rng = eval(Symbol(rngname))(seed)
    IFSType = toifstype(ifsname, ndims)
    ifs = rand(rng, IFSType)
    render(rng, ifs, config)
end

"""
    render(configpath::AbstractString)

Load TOML configuration file from `configpath` and convert to `config::Config`.
Then call `render(config)`
"""
function render(configpath::AbstractString)
    config = Config(configpath)
    render(config)
end
