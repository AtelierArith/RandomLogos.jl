module RandomLogos

using LinearAlgebra
using Random
using TOML

using ConcreteStructs: @concrete
using Distributions
using ImageCore: N0f8, RGB, Gray
using Rotations
using StaticArrays
using ToStruct: tostruct
using VectorizedReduction: vvextrema

include("utils.jl")
include("types.jl")
include("ifs_sigma_factor.jl")
include("config.jl")
include("renderer.jl")

end
