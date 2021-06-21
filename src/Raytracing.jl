# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#


module Raytracing

using Base: Bool, String, Int64
using Colors, Images, ImageIO, FileIO, Polynomials, Test
using ColorTypes:RGB
using LinearAlgebra, StaticArrays
using Printf, ProgressBars
using Documenter, DocStringExtensions, JSON

import Base.:+; import Base.:-; import Base.:≈; import Base.:/; import Base.:*
import Base: write, read, print, println, copy;
import LinearAlgebra.:⋅; import LinearAlgebra.:×

# from Structs.jl
export BLACK, WHITE, to_RGB, HDRimage, get_matrix, Parameters
export Point, Vec, Normal, VEC_X, VEC_Y, VEC_Z, Transformation
export Ray, Camera, OrthogonalCamera, PerspectiveCamera, ImageTracer
export Pigment, UniformPigment, CheckeredPigment, ImagePigment
export BRDF, DiffuseBRDF, SpecularBRDF, Material
export Shape, Sphere, Plane, Torus
export Vec2d, HitRecord, PointLight, World
export Renderer, OnOffRenderer, FlatRenderer, PathTracer, PointLightRenderer
# from Operations.jl
export are_close, squared_norm, norm, normalize #, normalized_dot
# from ReadingWriting.jl
export parse_command_line, parse_demo_settings
export parse_tonemapping_settings, parse_demoanimation_settings
export load_image, ldr2pfm
# from RangeTesters.jl
export check_is_uint64, check_is_square
export check_is_color, check_is_declare_float
# from ParseSettings.jl
export parse_render_settings 
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
#from SceneFiles.jl
export KeywordEnum, GrammarError, InputStream
export Token, KeywordToken, IdentifierToken, StringToken
export LiteralNumberToken, SymbolToken, StopToken
export read_token, skip_whitespaces_and_comments
export Scene, parse_scene
#from Render.jl
export render
# from PrintFunctions.jl
export print_not_black

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
include("SceneFiles.jl")
include("Render.jl")
include("PrintFunctions.jl")

end
