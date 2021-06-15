# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#


module Raytracing

using Base: Bool
using Colors, Images, ImageIO, FileIO, Polynomials
using ColorTypes:RGB
using LinearAlgebra, StaticArrays
using Printf, ProgressBars
using Documenter, DocStringExtensions, Intervals

import Base.:+; import Base.:-; import Base.:≈; import Base.:/; import Base.:*
import Base: write, read, print, println, length;
import LinearAlgebra.:⋅; import LinearAlgebra.:×

# from Structs.jl
export BLACK, WHITE, mutable_for_test, to_RGB, HDRimage, get_matrix, Parameters
export Point, Vec, Normal, VEC_X, VEC_Y, VEC_Z, Transformation
export Ray, Camera, OrthogonalCamera, PerspectiveCamera, ImageTracer
export Pigment, UniformPigment, CheckeredPigment, ImagePigment
export BRDF, DiffuseBRDF, SpecularBRDF, Material
export Shape, Sphere, Plane, Torus, Triangle, Cube, AABB
export Vec2d, HitRecord, PointLight, World
export Renderer, OnOffRenderer, FlatRenderer, PathTracer, PointLightRenderer
# from Operations.jl
export are_close, squared_norm, norm, normalize #, normalized_dot
# from PrintFunctions.jl
export print_not_black
# from ReadingWriting.jl
export parse_command_line, parse_demo_settings
export parse_tonemapping_settings, parse_demoanimation_settings
export load_image, ldr2pfm
# from ToneMapping.jl
export normalize_image!,  clamp_image!, γ_correction!, tone_mapping
# from Transformations.jl
export rotation_x, rotation_y, rotation_z
export scaling, translation, inverse, is_consistent
# from ImageTracer.jl
export at, fire_ray, fire_all_rays!
# from Shapes.jl
export ray_intersection, add_shape!, add_light!
export is_point_visible, quick_ray_intersection
# from Demo.jl
export first_world, second_world, select_world
export demo, demo_animation
# from Pigment.jl
export get_color, evaluate
# from PCG.jl
export PCG, random
# from OrthoNormalBasis.jl
export create_onb_from_z
#from ScatterRay.jl
export scatter_ray

include("PCG.jl")
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
include("OrthoNormalBasis.jl")
include("ScatterRay.jl")


end  # module