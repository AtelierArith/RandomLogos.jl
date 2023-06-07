module RandomLogos

using Random
using LinearAlgebra

using ConcreteStructs: @concrete
using Distributions
using Images
using Rotations
using StaticArrays
using VectorizedReduction: vvextrema

include("utils.jl")
include("types.jl")
include("ifs_sigma_factor.jl")
include("renderer.jl")
include("config.jl")

end
