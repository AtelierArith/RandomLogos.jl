module RandomLogos

using Random
using LinearAlgebra

using ConcreteStructs: @concrete
using Distributions
using ImageCore: N0f8
using Rotations
using StaticArrays
using ToStruct: tostruct
using VectorizedReduction: vvextrema

include("utils.jl")
include("types.jl")
include("config.jl")
include("ifs_sigma_factor.jl")
include("renderer.jl")

end
