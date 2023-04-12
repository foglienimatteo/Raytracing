# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#


module Raytracing

using Base: Bool, String, Int64
using Colors, Images, ImageIO, FileIO, Polynomials, Test, ArgParse
using ColorTypes:RGB
using LinearAlgebra, StaticArrays
using Printf, ProgressMeter
using Documenter, DocStringExtensions, JSON, Dates,  Intervals

import Base.:+; import Base.:-; import Base.:≈; import Base.:/; import Base.:*
import Base: write, read, print, println, copy, length;

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
# from ReadingWriting.jl
export load_image, ldr2pfm
# from RangeTesters.jl
export check_is_positive, check_is_uint64, check_is_even_uint64
export check_is_square, check_is_color, check_is_vector
export check_is_declare_float, check_is_one_of, check_is_iterable
export check_is_function, check_is_vec_variables
# from ParseSettings.jl
export parse_command_line, parse_demo_settings
export parse_tonemapping_settings, parse_demoanimation_settings
export parse_render_settings, parse_render_animation_settings
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
export demo, demo_animation
# from Pigment.jl
export get_color, evaluate
# from PCG.jl
export PCG, random
# from OrthoNormalBasis.jl
export create_onb_from_z
#from ScatterRay.jl
export scatter_ray
# from Interpreter.jl
# see the module Interpreter.jl
# from Render.jl
export render
# from RenderAnimation.jl
export render_animation
# from PrintFunctions.jl
export print_not_black
# from ArgParse_CLI.jl
export ArgParse_command_line, print_ArgParseSettings

CAMERAS = ["ort", "per"]
RENDERERS = ["onoff", "flat", "pathtracer", "pointlight"]
DEMO_WORLD_TYPES = ["A", "B", "C"]

SYM_NUM = Dict("e"=>ℯ, "pi"=>π)

# Base.:/(c::RGB{T}, scalar::Real) where {T} = RGB{T}(c.r/scalar , c.g/scalar, c.b/scalar)
SYM_COL = Dict(
    # "BLACK" => RGB{Float32}(0., 0., 0.),
    # "WHITE" => RGB{Float32}(255., 255., 255.)/255,
    "RED" => RGB{Float32}(255., 0., 0.)/255,
    "LIME" => RGB{Float32}(0., 255., 0.)/255,
    "BLUE" => RGB{Float32}(0., 0., 255.)/255,
    "YELLOW" => RGB{Float32}(255., 255., 0.)/255,
    "CYAN" => RGB{Float32}(0., 255., 255.)/255,
    "MAGENTA" => RGB{Float32}(255., 0., 255.)/255,
    "SYLVER" => RGB{Float32}(192., 192., 192.)/255,
    "GRAY" => RGB{Float32}(128., 128., 128.)/255,
    "MAROON" => RGB{Float32}(128., 0., 0.)/255,
    "OLIVE" => RGB{Float32}(128., 128., 0.)/255,
    "GREEN" => RGB{Float32}(0., 128., 0.)/255,
    "PURPLE" => RGB{Float32}(128., 0., 128.)/255,
    "TEAL" => RGB{Float32}(0., 128., 128.)/255,
    "NAVY" => RGB{Float32}(0., 0., 128.)/255,
    "ORANGE" => RGB{Float32}(255., 165., 0.)/255,
    "GOLD" => RGB{Float32}(255., 215., 0.)/255
)

export CAMERAS, RENDERERS, DEMO_WORLD_TYPES

include("PCG.jl")
include("Structs.jl")
include("Operations.jl")
include("ReadingWriting.jl")
include("RangeTesters.jl")
include("ParseSettings.jl")
include("ToneMapping.jl")
include("Transformations.jl")
include("ImageTracer.jl")
include("Shapes.jl")
include("Demo.jl")
include("Pigment.jl")
include("Renderers.jl")
include("OrthoNormalBasis.jl")
include("ScatterRay.jl")

include("Interpreter.jl")
using .Interpreter

include("Render.jl")
include("RenderAnimation.jl")
include("PrintFunctions.jl")
include("ArgParse_CLI.jl")

# Here is were you can define your own functions to be used in
# the scene-files!
include("YOUR_FUNCTIONS.jl")

end
