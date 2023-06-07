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
