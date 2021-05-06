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

##########################################################################################92

BLACK = RGB{Float32}(0.0, 0.0, 0.0)
WHITE = RGB{Float32}(1.0, 1.0, 1.0)

##########################################################################################92

""" 
    This type defines a image in format High-Dynamic-Range 2D image; has three members:
    - `width`
    - `height`
    - array containing `RGB` color, it's a 2linearized" matrix; the first
      element is the one in the bottom-left of the matrix, then the line
      is read left-to-right and going to the upper row.
    Has two constructors:
    - HDRimage(width, height)
    - HDRimage(width, height, RGB-array)
"""
struct HDRimage
    width::Int64
    height::Int64
    rgb_m::Array{RGB{Float32}}
    HDRimage(w,h) = new(w,h, fill(RGB(0.0, 0.0, 0.0), (w*h,)) )
    function HDRimage(w,h, rgb_m) 
        @assert size(rgb_m) == (w*h,)
        new(w,h, rgb_m)
    end
end # HDRimage

##########################################################################################92

""" 
    Type used to save (passed from command line):
    - input file name (must be a .pfm)
    - output file name (must be a .png)
    - parameter a for (optional)
    - parameter γ for screen correction (optional)
"""
struct Parameters
    infile::String
    outfile::String
    a::Float64
    γ::Float64
    Parameters(in, out, a=0.18, γ=1.0) = new(in, out, a, γ)
end

##########################################################################################92

struct Point
    x::Float64
    y::Float64
    z::Float64
    Point(x, y, z) = new(x, y, z)
    Point() = new(0., 0. ,0.)
end

##########################################################################################92

struct Vec
    x::Float64
    y::Float64
    z::Float64
    Vec(x, y, z) = new(x, y, z)
    Vec()=new(0.0, 0.0, 0.0)
    Vec(P::Point) = new(P.x, P.y, P.z)
end

##########################################################################################92

VEC_X = Vec(1.0, 0.0, 0.0) # ̂x
VEC_Y = Vec(0.0, 1.0, 0.0) # ̂y
VEC_Z = Vec(0.0, 0.0, 1.0) # ̂z

##########################################################################################92

"""
    Is a normalized vector, you can give three components and its struct normalize them.
"""
struct Normal
    x::Float64
    y::Float64
    z::Float64
    function Normal(x, y, z)
        m = √(x^2+y^2+z^2)
        new(x/m, y/m, z/m)
    end
end

##########################################################################################92

"""
    Contains two matrices 4x4 of ::Float64, one the inverse of the other.
    It's used to implement rotations, scaling and translationscin 3D with homogenous
    formalism.
"""
struct Transformation
    M::SMatrix{4,4,Float64}
    invM::SMatrix{4,4,Float64}
    Transformation(m, invm) = new(m, invm)
    Transformation() = new( SMatrix{4,4}( Diagonal(ones(4)) ),  SMatrix{4,4}( Diagonal(ones(4)) ) )
end

##########################################################################################92

"""
    A ray of light propagating in space
    The class contains the following members:
    -   `origin` (``Point``): the 3D point where the ray originated
    -   `dir` (``Vec``): the 3D direction along which this ray propagates
    -   `tmin` (`Float64`): the minimum distance travelled by the ray is this number times `dir`
    -   `tmax` (`Float64`): the maximum distance travelled by the ray is this number times `dir`
    -   `depth` (`Int64`): number of times this ray was reflected/refracted
"""
struct Ray
    origin::Point
    dir::Vec
    tmin::Float64
    tmax::Float64
    depth::Int64
    Ray(o, d, m=1e-5, M=Inf, n=0) = new(o, d, m, M, n)
end

##########################################################################################92

abstract type Camera end

##########################################################################################92

"""
    # A camera implementing an orthogonal 3D → 2D projection
    # This class implements an observer seeing the world through an orthogonal projection.

    Create a new orthographic camera
    The parameter `aspect_ratio` defines how larger than the height is the image. For fullscreen
    images, you should probably set `aspect_ratio` to 16/9, as this is the most used aspect ratio
    used in modern monitors.
    The `transformation` parameter is an instance of the :class:`.Transformation` class.

    Implements the point of view of an observator, in the
    negative part of the x-axis; used for orthogonal projection.
    Needs only the aspect ratio a (by default a=1.0) of the
    screen(/image) and possible transformation.
"""
struct OrthogonalCamera <: Camera
    a::Float64 # aspect ratio
    T::Transformation
    OrthogonalCamera(a=1., T=Transformation()) = new(a, T)
end

##########################################################################################92

"""
    Implements the point of view of an observator, in the
   negative part of the x-axis (-d, 0, 0); used for perspective
   projection.
   Needs the aspect ratio a (by default a=1.0) of the screen(/image),
   distance d from it and possible transformation.
"""
struct PerspectiveCamera <: Camera
    d::Float64 # distance from the screen
    a::Float64 # aspect ratio
    T::Transformation
    PerspectiveCamera(d=1., a=1., T=Transformation()) = new(d, a, T)
end

##########################################################################################92

"""
    Used for implement the "screen": has a `HDRimage` and a `Camera`.
"""
struct ImageTracer
    img::HDRimage
    cam::Camera
end

##########################################################################################92

abstract type Shape end

##########################################################################################92

"""
    A 3D unit sphere centered on the origin of the axes
"""
struct Sphere <: Shape
    T::Transformation
    Sphere(T=Transformation()) = new(T)
end

##########################################################################################92

"""
    A 2D vector used to represent a point on a surface.
    The fields are named `u` and `v` to distinguish them
    from the usual 3D coordinates `x`, `y`, `z`.
"""
struct Vec2d
    u::Float64
    v::Float64
end

##########################################################################################92

"""
    A struct holding information about a ray-shape intersection
    The parameters defined in this struct are the following:
    -   `world_point`: a :struct:`Point` object holding the world coordinates of the hit point
    -   `normal`: a :struct:`Normal` object holding the orientation of the normal to the
        surface where the hit happened
    -   `surface_point`: a :struct:`Vec2d` object holding the position of the hit point
        on the surface of the object
    -   `t`: a floating-point value specifying the distance from the origin of the ray where
        the hit happened
    -   `ray`: the ray that hit the surface
"""
struct HitRecord
    world_point::Point # obserator frame sistem
    normal::Normal
    surface_point::Vec2d
    t::Float64
    ray::Ray
end

##########################################################################################92

"""
    A class holding a list of shapes, which make a «world»
    You can add shapes to a world using `.World.add`.
    Typically, you call `.World.ray_intersection`
    to check whether a light ray intersects any of the
    shapes in the world.
"""
struct World
    shapes::Array{Shape}
    World(s::Shape) = new(s)
    World() = new( Array{Shape,1}() )
end