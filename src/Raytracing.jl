# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


module Raytracing

using Colors, Images, ImageIO, LinearAlgebra, StaticArrays
using ColorTypes:RGB
import Base.:+; import Base.:-; import Base.:≈; import Base.:/; import Base.:*
import Base: write, read, print, println;
import LinearAlgebra.:⋅; import LinearAlgebra.:×

# from Structs.jl
export BLACK, WHITE, HDRimage, Parameters
export Point, Vec, Normal,VEC_X, VEC_Y, VEC_Z, Transformation
export Ray, OrthogonalCamera, PerspectiveCamera, ImageTracer
export Sphere, Vec2d, HitRecord, World
# from Operations.jl
export squared_norm, norm, normalize
# from ReadingWriting.jl
export parse_command_line, parse_demo_settings, parse_tonemapping_settings
# from ToneMapping.jl
export normalize_image!,  clamp_image!, γ_correction!, get_matrix, tone_mapping
# from Transformations.jl
export rotation_x, rotation_y, rotation_z, scaling, translation, inverse
# from ImageTracer.jl
export at, fire_ray, fire_all_rays!
# from Shapes.jl
export ray_intersection, sphere_point_to_uv, sphere_normal, add_shape
# from Demo.jl
export demo


include("Structs.jl")
include("Operations.jl")
include("PrintFunctions.jl")
include("ReadingWriting.jl")
include("ToneMapping.jl")
include("Transformations.jl")
include("ImageTracer.jl")
include("Shapes.jl")
include("Demo.jl")


end  # module