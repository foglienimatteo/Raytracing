# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#


module Raytracing

using Colors, Images, ImageIO, FileIO
using ColorTypes:RGB
using LinearAlgebra, StaticArrays
using Printf, ProgressBars

import Base.:+; import Base.:-; import Base.:≈; import Base.:/; import Base.:*
import Base: write, read, print, println;
import LinearAlgebra.:⋅; import LinearAlgebra.:×

# from Structs.jl
export BLACK, WHITE, HDRimage, Parameters
export Point, Vec, Normal,VEC_X, VEC_Y, VEC_Z, Transformation
export Ray, OrthogonalCamera, PerspectiveCamera, ImageTracer
export Shape, Sphere, Plane, Vec2d, HitRecord, World
export Pigment, UniformPigment, CheckeredPigment, ImagePigment
export BRDF, DiffuseBRDF, SpecularBRDF, Material
export Renderer, OnOffRenderer, FlatRenderer, PathTracer
# from Operations.jl
export are_close, squared_norm, norm, normalize
# from PrintFunctions.jl
export print_not_black
# from ReadingWriting.jl
export parse_command_line, parse_demo_settings
export parse_tonemapping_settings, parse_demoanimation_settings
# from ToneMapping.jl
export normalize_image!,  clamp_image!, γ_correction!, get_matrix, tone_mapping
# from Transformations.jl
export rotation_x, rotation_y, rotation_z, scaling, translation, inverse
# from ImageTracer.jl
export at, fire_ray, fire_all_rays!
# from Shapes.jl
export ray_intersection, sphere_point_to_uv, sphere_normal, add_shape
# from Demo.jl
export demo, demo_animation
# from Renderers.jl
export choose_renderer, call
# from Pigment.jl
export get_color, eval
# from PCG.jl
export PCG, random
# from OrthoNormalBasis.jl
export create_onb_from_z
#from ScatterRay.jl
export scatter_ray


include("Structs.jl")
include("Operations.jl")
include("PrintFunctions.jl")
include("ReadingWriting.jl")
include("ToneMapping.jl")
include("Transformations.jl")
include("ImageTracer.jl")
include("Shapes.jl")
include("Demo.jl")
include("Pigment.jl")
include("Renderers.jl")
include("PCG.jl")
include("OrthoNormalBasis.jl")
include("ScatterRay.jl")


end  # module