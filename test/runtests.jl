using LinearAlgebra: det
using Random

using RandomLogos
using RandomLogos: Affine
using RandomLogos: uniform, render, generate_points!

using StableRNGs
using StaticArrays

using Test
using JET

@testset "utils.jl: uniform" begin
    rng = StableRNG(0)
    o = @inferred uniform(rng, 1, 2)
    @test typeof(o) == Float64
    o = @inferred uniform(rng, 1.0, 2)
    @test typeof(o) == Float64
    o = @inferred uniform(rng, 1.0, 2.0)
    @test typeof(o) == Float64
    o = @inferred uniform(rng, 1.0, 2)
    @test typeof(o) == Float64

    o = @inferred uniform(rng, 1, 2f0)
    @test typeof(o) == Float32
    o = @inferred uniform(rng, 1f0, 2f0)
    @test typeof(o) == Float32
    o = @inferred uniform(rng, 1f0, 2)
    @test typeof(o) == Float32
end

@testset "types.jl: Affine" begin
    rng = StableRNG(0)
    W = SMatrix{2, 2}(rand(rng, 2, 2))
    b = SVector{2}(rand(rng, 2))
    aff = Affine(W, b)
    x = SVector{2}(rand(rng, 2))
    @test typeof(aff(x)) == SVector{2, Float64}
    @test_call aff(x)
    @test_opt aff(x)
    @test aff(x) == [1.1638974950254997, 0.23737849333751335]
end

@testset "ifs_sigma_factor.jl: samplve_svs" begin
    rng = StableRNG(0)
    for T in [Float32, Float64]
        @testset "T = $T" begin
            N = 4
            sigma_factor = T(uniform(rng, 0.5(N+5), 0.5(N+6)))
            svs = @inferred RandomLogos.sample_svs(rng, sigma_factor, N)
            @test sum(svs[:, 1] .+ 2svs[:, 2]) ≈ sigma_factor
            @test_call RandomLogos.sample_svs(rng, sigma_factor, N)
            @test_opt RandomLogos.sample_svs(rng, sigma_factor, N)
        end
    end
end

@testset "ifs_sigma_factor.jl: SamplerType" begin
    rng = StableRNG(0)
    ifs = rand(rng, Random.SamplerType{RandomLogos.SigmaFactorIFS{2,Float64}}())
    @test length(ifs.transforms) == length(ifs.catdist.p)
    tot = sum(ifs.transforms) do t
        abs(det(t.W))
    end
    for (t, w) in zip(ifs.transforms, ifs.catdist.p)
        @test abs(det(t.W))/tot ≈ w
    end

    @testset "with JET" begin
        rng = StableRNG(0)
        @test_call rand(rng, Random.SamplerType{RandomLogos.SigmaFactorIFS{2}}())
        @test_opt rand(rng, Random.SamplerType{RandomLogos.SigmaFactorIFS{2}}())
        @test_call rand(rng, Random.SamplerType{RandomLogos.SigmaFactorIFS{2,Float32}}())
        @test_opt rand(rng, Random.SamplerType{RandomLogos.SigmaFactorIFS{2,Float32}}())
        @test_call rand(rng, Random.SamplerType{RandomLogos.SigmaFactorIFS{2,Float64}}())
        @test_opt rand(rng, Random.SamplerType{RandomLogos.SigmaFactorIFS{2,Float64}}())
    end
end

@testset "renderer.jl: generate_points" begin
    @testset "SigmaFactorIFS{2}" begin
        rng = StableRNG(0)
        npoints = 10
        xs = Vector{Float64}(undef, npoints)
        ys = Vector{Float64}(undef, npoints)
        ifs = rand(rng, RandomLogos.SigmaFactorIFS{2})
        H = 100
        W = 120
        generate_points!(
            rng,
            xs, ys,
            ifs,
            H, W
        )
        @test xs == [87.86124394400032, 56.88580848676319, 94.03089491005606, 60.54790528091046, 9.667567091220251, 66.13154891373554, 60.38763427738387, 115.0, 5.0, 25.821379866267705]
        @test ys == [60.713016405498564, 32.7280286460874, 15.29731836164603, 76.42553398093975, 32.755569573958056, 5.0, 70.73361735722611, 95.0, 51.72369693064062, 11.212286003138006]
    end
end

@testset "config.jl: Config" begin
    configpath = joinpath(@__DIR__, "examples", "config.toml")
    config = RandomLogos.Config(configpath)
    (; H, W, npoints, ifsname, ndims, rngname, seed) = config
    @test H == 384
    @test W == 384
    @test npoints == 100_000
    @test ifsname == "SigmaFactorIFS"
    @test ndims == 2
    @test rngname == "StableRNGs"
    @test seed == 1
end

@testset "renderer.jl: render" begin
    @testset "SigmaFactorIFS{2}" begin
        configpath = joinpath(@__DIR__, "examples", "config.toml")
        config = RandomLogos.Config(configpath)
        rng = StableRNG(config.seed)
        IFSType = RandomLogos.toifstype(config.ifsname, config.ndims)
        ifs = rand(rng, IFSType)
        canvas = render(rng, ifs, config)
        H, W = size(canvas)
        @test H == config.H
        @test W == config.W
    end
end
