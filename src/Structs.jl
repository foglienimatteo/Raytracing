# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

const BLACK = RGB{Float32}(0.0, 0.0, 0.0)
const WHITE = RGB{Float32}(1.0, 1.0, 1.0)

function to_RGB(r::Int64, g::Int64, b::Int64)
    return RGB{Float32}(r/255., g/255., b/255.)
end

function to_RGB(r::Float64, g::Float64, b::Float64)
    return RGB{Float32}(r/255., g/255., b/255.)
end


mutable struct mutable_for_test
    num_rays::Int64
end

"""
    to_RGB(r::Int64, g::Int64, b::Int64) :: RGB{Float32}
    to_RGB(r::Float64, g::Float64, b::Float64) :: RGB{Float32}

Return the RGB color with values inside the `[0,1]` interval.
"""
to_RGB


##########################################################################################92


""" 
    HDRimage(
        width::Int64
        height::Int64
        rgb_m::Array{RGB{Float32}} = fill(RGB(0.0, 0.0, 0.0), (width*height,))
        )

Define a image in the format 2D  High-Dynamic-Range.

## Arguments

- `width::Float64` : width pixel number of the image

- `height::Float64` : height pixel number of the image

- `rgb_m::Array{RGB{Float32}}` : linearized color matrix; 
  the first element is the one in the bottom-left of the matrix, 
  then the line is read left-to-right and going to the upper row.
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
end 

"""
    get_matrix(img::HDRimage) :: Matrix{RGB{Float32}}

Return the color matrix of the input `img`.
The order of the pixel as they are stored in the `HDRimage` format is
corrected in order to get the "natural" pixel matrix. 

See also: [`HDRimage`](@ref)
"""
function get_matrix(img::HDRimage)
    m = permutedims(reshape(img.rgb_m, (img.width,img.height)))
    return m
end


##########################################################################################92


""" 
    Parameters(
        infile::String, 
        outfile::String,
        a::Float64 = 0.18,
        γ::Float64 = 1.0
        )

Parameters passed from command line for the tone mapping.

## Arguments

- `infile::String` : input file name (must be a pfm)

- `outfile::String` : output file name (must be a png)

- `a::Float64` : parameter a for luminosity correction

- `γ::Float64` : parameter γ for screen correction

See also: [`tone_mapping`](@ref)
"""
struct Parameters
    infile::String
    outfile::String
    a::Float64
    γ::Float64
    Parameters(in, out, a=0.18, γ=1.0) = new(in, out, a, γ)
end


##########################################################################################92


"""
    Point(x::Float64, y::Float64, z::Float64)

A point in 3D space.

## Constructors

- `Point() = new(0., 0. ,0.)`

- `Point(x, y, z) = new(x, y, z)`

- `Point(v::SVector{4, Float64}) = new(v[1], v[2], v[3])`
"""
struct Point
    x::Float64
    y::Float64
    z::Float64
    Point(x, y, z) = new(x, y, z)
    Point() = new(0., 0. ,0.)
    Point(v::SVector{4, Float64}) = new(v[1], v[2], v[3])
end

"""
    Vec(x::Float64, y::Float64, z::Float64)

A 3D Vector

## Constructors

- `Vec() = new(0., 0. ,0.)`

- `Vec(x, y, z) = new(x, y, z)`

- `Vec(P::Point) = new(P.x, P.y, P.z)`

- `Vec(v::SVector{4, Float64}) = new(v[1], v[2], v[3])`

- `Vec(N::Normal) = Vec(N.x, N.y, N.z)`

See also: [`Normal`](@ref)
"""
struct Vec
    x::Float64
    y::Float64
    z::Float64
    Vec(x::Float64, y::Float64, z::Float64) = new(x, y, z)
    Vec() = new(0.0, 0.0, 0.0)
    Vec(P::Point) = new(P.x, P.y, P.z)
    Vec(v::SVector{4, Float64}) = new(v[1], v[2], v[3])
    function Vec(x::T1, y::T2, z::T3) where {T1<:Number,T2<:Number, T3<:Number}
        Vec(convert(Float64, x), convert(Float64, y), convert(Float64, z))
    end
end
Point(v::Vec) = Point(v.x, v.y, v.z)

length(::Vec) = 3

const VEC_X = Vec(1.0, 0.0, 0.0)
const VEC_Y = Vec(0.0, 1.0, 0.0)
const VEC_Z = Vec(0.0, 0.0, 1.0)

"""
    Normal(x::Float64, y::Float64, z::Float64)

A normal vector in 3D space, you can give three components 
and its struct normalize them.

## Constructors

- `Normal(x,y,z) = new(x, y ,z)`

- `Normal(v::Vec) = new(v[1]/m, v[2]/m, v[3]/m)`

- `Normal(v::Vector{Float64}) = new(v[1]/m, v[2]/m, v[3]/m)`

- `Normal(v::SVector{4,Float64}) = new(v[1]/m, v[2]/m, v[3]/m)`

(`m` indicates the norm of the input vector)

See also: [`Vec`](@ref)
"""
struct Normal
    x::Float64
    y::Float64
    z::Float64
    function Normal(x, y, z)
        m = √(x^2+y^2+z^2)
        new(x/m, y/m, z/m)
    end
    function Normal(v::Vec)
        m = √(v.x^2+v.y^2+v.z^2)
        new(v.x/m, v.y/m, v.z/m)
    end
    function Normal(v::Vector{Float64})
        @assert length(v) == 3
        m = √(v[1]^2+v[2]^2+v[3]^2)
        new(v[1]/m, v[2]/m, v[3]/m)
    end
    function Normal(v::SVector{4,Float64})
        m = √(v[1]^2+v[2]^2+v[3]^2)
        new(v[1]/m, v[2]/m, v[3]/m)
    end
end
Vec(N::Normal) = Vec(N.x, N.y, N.z)


##########################################################################################92


"""
    Transformation(M::SMatrix{4,4,Float64}, invM::SMatrix{4,4,Float64})

Contain two matrices 4x4 of `Float64`, one the inverse of the other.
It's used to implement rotations, scaling and translations in 3D space 
with homogenous formalism.

**NOTE**: It does not check if `invM` is the inverse matrix of `M`, for
computational efficiency purposes!
In order to do that, looks at `is_consistent(T::Transformation)` function.


## Constructors

- `Transformation(m, invm) = new(m, invm)`

- `Transformation() = new( 
            SMatrix{4,4}( Diagonal(ones(4)) ),  
            SMatrix{4,4}( Diagonal(ones(4)) ) 
        )`

See also: [`is_consistent`](@ref)
"""
struct Transformation
    M::SMatrix{4,4,Float64}
    invM::SMatrix{4,4,Float64}
    Transformation(m, invm) = new(m, invm)
    Transformation() = 
        new( 
            SMatrix{4,4}( Diagonal(ones(4)) ),  
            SMatrix{4,4}( Diagonal(ones(4)) ) 
        )
end


##########################################################################################92


"""
    Ray(
        origin::Point,
        dir::Vec,
        tmin::Float64 = 1e-5,
        tmax::Float64 = Inf,
        depth::Int64 = 0,
        )

A ray of light propagating in space.

## Arguments

- `origin::Point` : origin of the ray

- `dir::Vec` : 3D direction along which this ray propagates

- `tmin::Float64` : minimum distance travelled by the ray is this number times `dir`

- `tmax::Float64` : maximum distance travelled by the ray is this number times `dir`

- `depth::Int64` : number of times this ray was reflected/refracted

See also: [`Point`](@ref), [`Vec`](@ref)
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


"""
    abstract type Camera end

An abstract type with the following concrete sub-types,
defining different types of perspective projections:

- [`OrthogonalCamera`](@ref)

- [`PerspectiveCamera`](@ref)
"""
abstract type Camera end

"""
    OrthogonalCamera <: Camera (
        a::Float64 = 1.0,
        T::Transformation = Transformation()
    )

A camera implementing an orthogonal 3D → 2D projection.
This class implements an observer seeing the world through an orthogonal projection.

## Arguments

- `a::Float64` : aspect ratio, defines how larger than the height is the image. 
  For fullscreen images, you should probably set `a` to 16/9, as this is the 
  most used aspect ratio used in modern monitors.

- `T::Transformation` : transformation that defines the position of the observer.

See also: [`Transformation`](@ref), [`Camera`](@ref)
"""
mutable struct OrthogonalCamera <: Camera
    a::Float64  # aspect ratio
    T::Transformation
    # OrthogonalCamera(a::Float64=1., T::Transformation=Transformation()) = new(a, T)
    OrthogonalCamera(a::Float64, T::Transformation) = new(a, T)
    OrthogonalCamera(T::Transformation) = new(1.0, T)
    OrthogonalCamera(a::Float64) = new(a, Transformation())
end

"""
    PerspectiveCamera <: Camera (
        d::Float64 = 1.0,
        a::Float64 = 1.0,
        T::Transformation = Transformation()
        )

A camera implementing a perspective 3D → 2D projection.
This class implements an observer seeing the world through a perspective projection.

## Arguments

- `d::Float64`: distance between the observer and the screen, it influences 
  the so-called «aperture» (the field-of-view angle along the horizontal direction).

- `a::Float64` : aspect ratio, defines how larger than the height is the image. 
  For fullscreen images, you should probably set `a` to 16/9, as this is the 
  most used aspect ratio used in modern monitors.

- `T::Transformation` : transformation that defines the position of the observer.

See also: [`Transformation`](@ref), [`Camera`](@ref)
"""
mutable struct PerspectiveCamera <: Camera
    d::Float64
    a::Float64
    T::Transformation
    PerspectiveCamera(d=1., a=1., T=Transformation()) = new(d, a, T)
end


##########################################################################################92


"""
    ImageTracer(
        img::HDRimage,
        cam::Camera,
        samples_per_side::Int64 = 0,
        pcg::PCG = PCG()
        )

Implement the "screen" of the observer.

Trace an image by shooting light rays through each of its pixels.

## Arguments

- `img::HDRimage` : the image that will be rendered (required)

- `cam::Camera` : camera type of the observer (required)

- `samples_per_side::Int64 = 0` : if it is larger than zero, stratified sampling will 
  be applied to each pixel in the image, using the random number generator 
  `pcg`; if not, antialiasing will be ignored in `fire_all_rays!`

- `pcg::PCG = PCG()` : PCG random number generator

See also: [`HDRimage`](@ref),[`Camera`](@ref), [`PCG`](@ref),
[`fire_ray`](@ref), [`fire_all_rays!`](@ref)
"""
struct ImageTracer
    img::HDRimage
    cam::Camera
    samples_per_side::Int64
    pcg::PCG

    ImageTracer(img::HDRimage, cam::Camera, s::Int64, p::PCG) = new(img, cam, s, p)
    ImageTracer(img::HDRimage, cam::Camera, s::Int64) =  new(img, cam, s, PCG())
    ImageTracer(img::HDRimage, cam::Camera) =  new(img, cam, 0, PCG()) 
end


##########################################################################################92


"""
    abstract type Pigment end

This abstract class represents a pigment, i.e., a function that associates 
a color with each point on a parametric surface (u,v). Call the function
`get_color` to retrieve the color of the surface given a `Vec2d` object.

The concrete sub-types of this abstract class are:

- [`UniformPigment`](@ref)

- [`CheckeredPigment`](@ref)

- [`ImagePigment`](@ref)

See also: [`Vec2d`](@ref), [`get_color`](@ref)
"""
abstract type Pigment end

"""
    UniformPigment <: Pigment(
        color::RGB{Float32} = RGB{Float32}(0.0, 0.0, 0.0)
    )

A uniform pigment.
This is the most boring pigment: a uniform hue over the whole surface.

See also: [`Pigment`](@ref)
"""
struct UniformPigment <: Pigment
    color::RGB{Float32}
    UniformPigment(c = BLACK) = new(c)
end

"""
    CheckeredPigment <: Pigment
        color1::RGB{Float32} = RGB{Float32}(1.0, 1.0, 1.0),
        color2::RGB{Float32} = RGB{Float32}(0.0, 0.0, 0.0),
        num_steps::Int64 = 2
    )

A checkered pigment.
The number of rows/columns in the checkered pattern is tunable through the
integer value `num_steps`, but you cannot have a different number of 
repetitions along the u/v directions.

See also: [`Pigment`](@ref)
"""
struct CheckeredPigment <: Pigment
    color1::RGB{Float32}
    color2::RGB{Float32}
    num_steps::Int64
    CheckeredPigment(c1 = WHITE, c2 = BLACK, n = 2) = new(c1, c2, n)
end

"""
    ImagePigment <: Pigment(
        image::HDRimage = HDRimage(3, 2, fill( BLACK, (6,) ) )
    )

A textured pigment.
The texture is given through a PFM image.

See also: [`Pigment`](@ref), [`HDRimage`](@ref)
"""
struct ImagePigment <: Pigment
    image::HDRimage
    ImagePigment(img = HDRimage(3, 2, fill(BLACK, (6,)))) = new(img)
end


##########################################################################################92


"""
    abstract type BRDF end

An abstract class representing a Bidirectional Reflectance Distribution Function.
The concrete sub-types of this abstract class are:

- [`DiffuseBRDF`](@ref)

- [`SpecularBRDF`](@ref)
"""
abstract type BRDF end

"""
    DiffuseBRDF <: BRDF(
        pigment::Pigment = UniformPigment(RGB{Float32}(1.0, 1.0, 1.0)),
        reflectance::Float64 = 1.0
    )

A class representing an ideal diffuse BRDF (also called «Lambertian»).

See also: [`Pigment`](@ref), [`UniformPigment`](@ref)
"""    
struct DiffuseBRDF <: BRDF
    pigment::Pigment
    reflectance::Float64
    DiffuseBRDF(pig = UniformPigment(WHITE), r=1.0) = new(pig, r)
end

"""
    DiffuseBRDF <: BRDF(
        pigment::Pigment = UniformPigment(RGB{Float32}(1.0, 1.0, 1.0)),
        theresold_angle_rad::Float64 = π/180.
    )

A class representing an ideal mirror BRDF.

See also: [`Pigment`](@ref), [`UniformPigment`](@ref)
"""
struct SpecularBRDF <: BRDF
    pigment::Pigment
    theresold_angle_rad::Float64
    SpecularBRDF(p=UniformPigment(WHITE), thAngle = π/180.) = new(p, thAngle)
end

"""
    Material(
        brdf::BRDF = DiffuseBRDF(),
        emitted_radiance::Pigment = UniformPigment()
    )

A struct representing a material.

See also: [`BRDF`](@ref), [`DiffuseBRDF`](@ref), 
[`Pigment`](@ref), [`UniformPigment`](@ref) 
"""
struct Material
    brdf::BRDF
    emitted_radiance::Pigment
    Material(brdf = DiffuseBRDF(), er = UniformPigment()) = new(brdf, er)
end


##########################################################################################92


"""
    abstract type Shape end

An abstract type with the following concrete sub-types,
defining different types of shapes that can be created:

- [`Sphere`](@ref)
- [`Plane`](@ref)
- [`Cube`](@ref)
- [`Triangle`](@ref)
- [`AABB`](@ref) (only for optimization purposes, it must not considered a real shape)
"""
abstract type Shape end




"""
    AABB <: Shape(
        vertexes::SVector{6, Float32}
    )

An Axis-Aligned Boundary Box.

This shape is not conceived to be rendered in the image, it has the only purpose
to optimize the various `ray_intersection` functions.

## Arguments

- `vertexes::SVector{6, Float32}` : the 6 coordinates of the exterior vertexes
  defining the AABB


See also: [`Shape`](@ref), [`ray_intersection`](@ref)
"""
struct AABB <: Shape
    m::Point
    M::Point
    AABB(P1::Point, P2::Point) = new(P1, P2)
    AABB(p1x::Float64, p1y::Float64, p1z::Float64, p2x::Float64, p2y::Float64, p2z::Float64) = 
        new(Point(p1x, p1y, p1z), Point(p2x, p2y, p2z))
    AABB() = new(Point(-1.0, -1.0, -1.0), Point(1.0, 1.0, 1.0))
end


"""
    Sphere <: Shape(
        T::Transformation = Transformation(),
        Material::Material = Material()
        flag_pointlight::Bool = false,
        flag_background::Bool = false,
        AABB::AABB = AABB(Sphere, T)
    )

A 3D unit sphere, i.e. centered on the origin of the axes
and with radius 1.0.

## Arguments

- `T::Transformation` : transformation associated to the sphere.

- `Material::Material` : material that constitutes the sphere.

- `flag_pointlight::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  a light ray can cross this shape as it would be transparent. It's perfect when a 
  point-light source is centered in a shape (as the Sun...)

- `flag_background::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  it does not matter if a point on this shape is seen or not from the point-light
  source. It's perfect to render the background of an image (as the Milky Way...)

- `AABB::AABB` : the Axis Aligned Bounding Box that contains this shape; it is 
  automatically inferred from the shape itself (i.e. from the input transoformation)
  through an appropriate contructor of `AABB`, and cannot be manually modified.

See also: [`Shape`](@ref), [`Transformation`](@ref), [`Material`](@ref)
"""
struct Sphere <: Shape
    T::Transformation
    Material::Material
    flag_pointlight::Bool
    flag_background::Bool
    AABB::AABB
    
    Sphere(T::Transformation, M::Material, b1::Bool=false,  b2::Bool=false) = new(T,M,b1,b2,AABB(Sphere, T))
    Sphere(M::Material, T::Transformation, b1::Bool=false, b2::Bool=false) = new(T,M,b1,b2,AABB(Sphere, T))
    Sphere(T::Transformation, b1::Bool=false, b2::Bool=false) = new(T, Material(), b1, b2, AABB(Sphere, T))
    Sphere(M::Material, b1::Bool=false, b2::Bool=false) = new(Transformation(), M, b1, b2, AABB(Sphere, Transformation()))
    Sphere(b1::Bool=false, b2::Bool=false) = new(Transformation(), Material(), b1, b2, AABB(Sphere, Transformation()) )
end

function AABB(::Type{Sphere}, T::Transformation)
    v1 = SVector{8, Point}(
        Point(1.0, 1.0, 1.0),
        Point(-1.0, 1.0, 1.0),
        Point(1.0, -1.0, 1.0),
        Point(1.0, 1.0, -1.0),
        Point(1.0, -1.0, -1.0),
        Point(-1.0, 1.0, -1.0),
        Point(-1.0, -1.0, 1.0),
        Point(-1.0, -1.0, -1.0),
    )

    v2 = SVector{8, Point}([T*p for p in v1])
    P2 = Point(
        maximum([v2[i].x for i in eachindex(v2)]),
        maximum([v2[i].y for i in eachindex(v2)]),
        maximum([v2[i].z for i in eachindex(v2)]) 
    )
    P1 = Point(
        minimum([v2[i].x for i in eachindex(v2)]),
        minimum([v2[i].y for i in eachindex(v2)]),
        minimum([v2[i].z for i in eachindex(v2)]) 
    )
    AABB(P1, P2)

end

"""
    Plane <: Shape(
        T::Transformation = Transformation(),
        Material::Material = Material()
    )

A 3D unit plane, i.e. the x-y plane (set of 3D points with z=0).

## Arguments

- `T::Transformation` : transformation associated to the plane.

- `Material::Material` : material that constitutes the plane.

- `flag_pointlight::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  a light ray can cross this shape as it would be transparent. It's perfect when a 
  point-light source is centered in a shape (as the Sun...)

- `flag_background::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  it does not matter if a point on this shape is seen or not from the point-light
  source. It's perfect to render the background of an image (as the Milky Way...)


See also: [`Shape`](@ref), [`Transformation`](@ref), [`Material`](@ref)
"""
struct Plane <: Shape
    T::Transformation
    Material::Material
    flag_pointlight::Bool
    flag_background::Bool

    Plane(T::Transformation, M::Material, b1::Bool=false,  b2::Bool=false) = new(T,M,b1,b2)
    Plane(M::Material, T::Transformation, b1::Bool=false, b2::Bool=false) = new(T,M,b1,b2)
    Plane(T::Transformation, b1::Bool=false, b2::Bool=false) = new(T, Material(), b1, b2)
    Plane(M::Material, b1::Bool=false, b2::Bool=false) = new(Transformation(), M, b1, b2)
    Plane(b1::Bool=false, b2::Bool=false) = new(Transformation(), Material(), b1, b2)
end


"""
    Cube <: Shape(
        T::Transformation = Transformation(),
        Material::Material = Material()
    )

A 3D unit cube, i.e. an axis aligned cube with side 1 centered in the origin.

## Arguments

- `T::Transformation` : transformation associated to the cube.

- `Material::Material` : material that constitutes the cube.

- `flag_pointlight::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  a light ray can cross this shape as it would be transparent. It's perfect when a 
  point-light source is centered in a shape (as the Sun...)

- `flag_background::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  it does not matter if a point on this shape is seen or not from the point-light
  source. It's perfect to render the background of an image (as the Milky Way...)

- `AABB::AABB` : the Axis Aligned Bounding Box that contains this shape; it is 
  automatically inferred from the shape itself (i.e. from the input transoformation)
  through an appropriate contructor of `AABB`, and cannot be manually modified.

See also: [`Shape`](@ref), [`Transformation`](@ref), [`Material`](@ref)
"""
struct Cube <: Shape
    T::Transformation
    Material::Material
    flag_pointlight::Bool
    flag_background::Bool
    AABB::AABB

    Cube(T::Transformation, M::Material, b1::Bool=false, b2::Bool=false) = new(T,M,b1,b2,AABB(Cube, T))
    Cube(M::Material, T::Transformation, b1::Bool=false, b2::Bool=false) = new(T,M,b1,b2,AABB(Cube, T))
    Cube(T::Transformation, b1::Bool=false, b2::Bool=false) = new(T, Material(), b1, b2, AABB(Cube, T))
    Cube(M::Material, b1::Bool=false, b2::Bool=false) = new(Transformation(), M, b1, b2, AABB(Cube, Transformation()))
    Cube(b1::Bool=false, b2::Bool=false) = new(Transformation(), Material(), b1, b2, AABB(Cube, Transformation()) )
end


function AABB(::Type{Cube}, T::Transformation)
    v1 = SVector{8, Point}(
        Point(0.5, 0.5, 0.5),
        Point(-0.5, 0.5, 0.5),
        Point(0.5, -0.5, 0.5),
        Point(0.5, 0.5, -0.5),
        Point(0.5, -0.5, -0.5),
        Point(-0.5, 0.5, -0.5),
        Point(-0.5, -0.5, 0.5),
        Point(-0.5, -0.5, -0.5),
    )

    v2 = SVector{8, Point}([T*p for p in v1])
    P2 = Point(
        maximum([v2[i].x for i in eachindex(v2)]),
        maximum([v2[i].y for i in eachindex(v2)]),
        maximum([v2[i].z for i in eachindex(v2)]) 
    )
    P1 = Point(
        minimum([v2[i].x for i in eachindex(v2)]),
        minimum([v2[i].y for i in eachindex(v2)]),
        minimum([v2[i].z for i in eachindex(v2)]) 
    )
    AABB(P1, P2)
end



VERTEXES = SVector{3}(Point(√3/2, 0, 0), Point(0, 0.5, 0), Point(0, -0.5, 0))
        
"""
    Triangle <: Shape(
        vertexes::SVector{3, Point} = 
            SVector{3, Point}(Point(√3/2, 0, 0), Point(0, 0.5, 0), Point(0, -0.5, 0)),
        Material::Material = Material()
    )

A 3D triangle.

## Arguments

- `vertexes::SVector{3, Point}` : points associated to the triangle.

- `Material::Material` : material that constitutes the triangle.

- `flag_pointlight::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  a light ray can cross this shape as it would be transparent. It's perfect when a 
  point-light source is centered in a shape (as the Sun...)

- `flag_background::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  it does not matter if a point on this shape is seen or not from the point-light
  source. It's perfect to render the background of an image (as the Milky Way...)

- `AABB::AABB` : the Axis Aligned Bounding Box that contains this shape; it is 
  automatically inferred from the shape itself (i.e. from the input transoformation)
  through an appropriate contructor of `AABB`, and cannot be manually modified.

See also: [`Shape`](@ref), [`Material`](@ref)
"""
struct Triangle <: Shape
    vertexes::SVector{3, Point}
    Material::Material
    flag_pointlight::Bool
    flag_background::Bool
    
    Triangle(v::SVector{3, Point}, M::Material, b1::Bool=false, b2::Bool=false) = new(v, M, b1, b2)
    Triangle(M::Material, v::SVector{3, Point}, b1::Bool=false, b2::Bool=false) = new(v, M, b1, b2)
    Triangle(P1::Point, P2::Point, P3::Point,  M::Material=Material(), b1::Bool=false, b2::Bool=false) = new(SVector{3}(P1,P2,P3), M, b1, b2)
    Triangle(v::SVector{3, Point}, b1::Bool=false, b2::Bool=false) = new(v, Material(), b1, b2)
    Triangle(M::Material, b1::Bool=false, b2::Bool=false) = new(VERTEXES, M, b1, b2)
    Triangle(b1::Bool=false, b2::Bool=false) = new(VERTEXES, Material(),b1, b2)

    function Triangle(
        P1::Union{Point,Vec}, 
        P2::Union{Point,Vec}, 
        P3::Union{Point,Vec},  
        M::Material=Material(), 
        b1::Bool=false, 
        b2::Bool=false
        ) 
        p1 = typeof(P1) == Vec ? Point(P1) : P1
        p2 = typeof(P2) == Vec ? Point(P2) : P2
        p3 = typeof(P3) == Vec ? Point(P3) : P3
        
        new(SVector{3}(p1,p2,p3), M, b1, b2)
    end
end

"""
    Torus <: Shape(
        T::Transformation = Transformation()
        Material::Material = Material()
        r::Float64 = 1.0
        R::Float64 = 3.0
        flag_pointlight::Bool
        flag_background::Bool
        AABB::AABB
    )

A 3D unit torus, a ring with circular section; has origin 
in `(0, 0, 0)` and axis parallel to the y-axis.

## Arguments

- `T::Transformation`: transformation associated to the torus.

- `Material::Material` : material that constitutes the torus.

- `r::Float64` : radius of the circular section.

- `R::Float64` : distance between the torus center and the section center.

- `flag_pointlight::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  a light ray can cross this shape as it would be transparent. It's perfect when a 
  point-light source is centered in a shape (as the Sun...)

- `flag_background::Bool` : flag for the [`PointLightRenderer`](@ref); if `true`,
  it does not matter if a point on this shape is seen or not from the point-light
  source. It's perfect to render the background of an image (as the Milky Way...)

```ditaa
^ ̂y                __-__
|                 /     \\ 
|---O------------(---o---)
|                 \\__ __/
|                    -
      <--------R------><-r->
```

See also: [`Shape`](@ref), [`Transformation`](@ref), [`Material`](@ref)
"""
struct Torus <: Shape
    T::Transformation
    Material::Material
    r::Float64
    R::Float64
    flag_pointlight::Bool
    flag_background::Bool
    AABB::AABB

    Torus(T::Transformation, M::Material, b1::Bool = false, b2::Bool = false) = new(T, M, 1.0, 3.0, b1, b2, AABB(Torus, T, 1.0, 3.0))
    Torus(T::Transformation, b1::Bool = false, b2::Bool = false) = new(T, Material(), 1.0, 3.0, b1, b2, AABB(Torus, T, 1.0, 3.0))
    Torus(M::Material, b1::Bool = false, b2::Bool = false) = new(Transformation(), M, 1.0, 3.0, b1, b2, AABB(Torus, T, 1.0, 3.0))
    Torus(b1::Bool = false, b2::Bool = false) = new(Transformation(), Material(), 1.0, 3.0, b1, b2, AABB(Torus, T, 1.0, 3.0))
    Torus(T::Transformation, M::Material, r::Float64, b1::Bool = false, b2::Bool = false) = new(T, M, r, 3*r, b1, b2, AABB(Torus, T, r, 3*r))
    Torus(T::Transformation, M::Material, r::Float64, R::Float64, b1::Bool = false, b2::Bool = false) = new(T, M, r, R, b1, b2, AABB(Torus, T, r, R))

    # Torus(T::Transformation = Transformation(), M::Material = Material(), b1::Bool = false, b2::Bool = false) = new(T, M, 1.0, 3.0, b1, b2, AABB(Torus, T, 1.0, 3.0))
    # Torus(r::Float64, T::Transformation = Transformation(), M::Material = Material(), b1::Bool = false, b2::Bool = false) = new(T, M, r, 3*r, b1, b2, AABB(Torus, T, r, 3*r))
    # Torus(T::Transformation = Transformation(), M::Material = Material(), r::Float64 = 1.0, R::Float64 = 3.0) = new(T, M, r, R, false, false, AABB(Torus, T, r, R))
    # Torus(r::Float64, R::Float64, T::Transformation = Transformation(), M::Material = Material(), b1::Bool = false, b2::Bool = false) = new(T, M, r, R, b1, b2, AABB(Torus, T, r, R))
    # # function Torus(
    #     T::Transformation = Transformation(),
    #     Material::Material = Material(),
    #     r::Float64 = 0.5,
    #     R::Float64 = 3*r,
    #     b1::Bool = false,
    #     b2::Bool = false
    #     )
    #     #    @assert r<R
    #     new(T, M, r, R, b1, b2, AABB(Torus, T, r, R), b1, b2)
    # end
end


function AABB(::Type{Torus}, T::Transformation, r::Float64, R::Float64)
    S = R + r
    v1 = SVector{8, Point}(
        Point(S, r, S),
        Point(S, -r, S),
        Point(-S, r, S),
        Point(-S, -r, S),
        Point(S, r, -S),
        Point(S, -r, -S),
        Point(-S, r, -S),
        Point(-S, -r, -S),
    )

    v2 = SVector{8, Point}([T*p for p in v1])

    P2 = Point(
        maximum([v2[i].x for i in eachindex(v2)]),
        maximum([v2[i].y for i in eachindex(v2)]),
        maximum([v2[i].z for i in eachindex(v2)]) 
    )
    P1 = Point(
        minimum([v2[i].x for i in eachindex(v2)]),
        minimum([v2[i].y for i in eachindex(v2)]),
        minimum([v2[i].z for i in eachindex(v2)]) 
    )

    AABB(P1, P2)
end


##########################################################################################92


"""
    Vec2d(u::Float64, v::Float64)

A 2D vector used to represent a point on a surface.
The fields are named `u` and `v` to distinguish them
from the usual 3D coordinates `x`, `y`, `z`.
"""
struct Vec2d
    u::Float64
    v::Float64
end

"""
    HitRecord(
        world_point::Point,
        normal::Normal,
        surface_point::Vec2d,
        t::Float64,
        ray::Ray,
        shape::Union{Shape, Nothing} = nothing
        )

A struct holding information about a ray-shape intersection.

## Arguments

- `world_point::Point `: world coordinates of the hit point

- `normal::Normal`: orientation of the normal to the surface where the hit happened

- `surface_point::Vec2d` : position of the hit point on the surface of the object

- `t::Float64` : distance from the origin of the ray where the hit happened

- `ray::Ray` : the `ray` that hit the surface

- `shape::Union{Shape, Nothing}`: shape on which the hit happened, or `nothing`
  if no intersection happened

See also: [`Point`](@ref), [`Normal`](@ref), [`Vec2d`](@ref)
[`Ray`](@ref), [`Shape`](@ref)
"""
struct HitRecord
    world_point::Point
    normal::Normal
    surface_point::Vec2d
    t::Float64
    ray::Ray
    shape::Union{Shape, Nothing}

    HitRecord(w,n,s,t,r, shp=nothing) =  new(w,n,s,t,r, shp)
end

"""
    PointLight(p::Point, c::Color, r::Float64 = 0.0)

A point light (used by the point-light renderer).
This class holds information about a point light (a Dirac's delta in the 
rendering equation).

## Arguments

- `position::Point` : position of the point light in 3D space

- `color::RGB{Float32}` : color of the point light

- `linear_radius::Float64`: if non-zero, this «linear radius» `r` is 
  used to compute the solid angle subtended by the light at a given 
  distance `d` through the formula ``(r / d)^2``.

See also: [`Point`](@ref), [`PointLightRenderer`](@ref)
"""
struct PointLight
    position::Point
    color::RGB{Float32}
    linear_radius::Float64
    PointLight(p::Point, c::Color, r::Float64 = 0.0) = new(p, c, r)
end

"""
    World(
        shapes::Array{Shape} = Array{Shape,1}(),
        point_lights::Array{PointLight} = Array{PointLight,1}()
    )

A struct holding a list of shapes, which make a «world».

You can add shapes to a world using `add_shape!`, and call 
`ray_intersection` to check whether a light ray intersects any of 
the shapes in the world.

For the `PointLightRenderer` algorithm, you can also add point-lights source
using `add_light!`, and `world` will keep a list of all of them.

See also: [`Shape`](@ref), [`add_shape!`](@ref),
[`PointLight`](@ref), [`add_light!`](@ref), [`PointLightRenderer`](@ref)
[`ray_intersection`](@ref), [`Ray`](@ref)
"""
struct World
    shapes::Array{Shape}
    point_lights::Array{PointLight}

    World(s::Shape, pl::PointLight) = new(s, pl)
    World(pl::PointLight) = new( Array{Shape,1}(), pl)
    World(s::Shape) = new(s, Array{PointLight,1}())
    World() = new( Array{Shape,1}(),  Array{PointLight,1}() )
end


##########################################################################################92


"""
    abstract type Renderer <: Function end

An abstract class implementing a solver of the rendering equation.
The concrete sub-types of this abstract class are:

- [`OnOffRenderer`](@ref)

- [`FlatRenderer`](@ref)

- [`PathTracer`](@ref)

- [`PointLightRenderer`](@ref)
"""
abstract type Renderer <: Function end

"""
    OnOffRenderer <: Renderer(
        world::World = World()
        background_color::RGB{Float32} = RGB{Float32}(0.0, 0.0, 0.0)
        color::RGB{Float32} = RGB{Float32}(1.0, 1.0, 1.0)
    )

A on/off renderer.
If the ray intersecty anyone of the shape inside the given
`world`, the returned color will be `color`; otherwise, if no shape
is intersected, the returned color will be `background_color`.

This renderer is mostly useful for debugging purposes, 
as it is really fast, but it produces boring images.

See also: [`Renderer`](@ref), [`World`](@ref)
"""
mutable struct OnOffRenderer <: Renderer
    world::World
    background_color::RGB{Float32}
    color::RGB{Float32}
    OnOffRenderer(w = World(), bc = BLACK, c = WHITE) = new(w, bc, c)
end

function copy(renderer::OnOffRenderer)
    return OnOffRenderer(World(), renderer.background_color, renderer.color)
end

"""
    FlatRenderer <: Renderer(
        world::World = World()
        background_color::RGB{Float32} = RGB{Float32}(0.0, 0.0, 0.0)
    )

A «flat» renderer.
This renderer estimates the solution of the rendering equation by neglecting 
any contribution of the light. It just uses the pigment of each surface to 
determine how to compute the final radiance.

See also: [`Renderer`](@ref), [`World`](@ref)
"""
mutable struct FlatRenderer <: Renderer
    world::World
    background_color::RGB{Float32}
    FlatRenderer(w = World(), bc = BLACK) = new(w, bc)
end

function copy(renderer::FlatRenderer)
    return FlatRenderer(World(), renderer.background_color)
end

"""
    PathTracer <: Renderer(
            world::World, 
            background_color::RGB{Float32} = RGB{Float32}(0.0, 0.0, 0.0),
            pcg::PCG = PCG(),
            num_of_rays::Int64 = 10,
            max_depth::Int64 = 2,
            russian_roulette_limit::Int64 = 3
        )

A simple path-tracing renderer.

The algorithm implemented here allows the caller to tune number 
of rays thrown at each iteration, as well as the maximum depth. 
It implements Russian roulette, so in principle it will take a 
finite time to complete the calculation even if you set 
max_depth to `Inf`.

## Arguments

- `world::World` : the world to be rendered

- `background_color::RGB{Float32}` : default background color 
  if the Ray doesn-t hit anything

- `pcg::PCG` : PCG random number generator for evaluating integrals

- `num_of_rays::Int64` : number of `Ray`s generated for each integral evaluation

- `max_depth::Int64` : maximal number recursive integrations; if a ray intersecting
  a surface has `depth>max_depth`, the returned color is `RGB{Float32}(0,0,0)`

- `russian_roulette_limit::Int64`: depth at whitch the Russian 
  Roulette algorithm begins

See also: [`Renderer`](@ref), [`Ray`](@ref), [`World`](@ref), [`PCG`](@ref)
"""
mutable struct PathTracer <: Renderer
    world::World
    background_color::RGB{Float32}
    pcg::PCG
    num_of_rays::Int64
    max_depth::Int64
    russian_roulette_limit::Int64
    PathTracer(w::World = World(), bc=BLACK, pcg=PCG(), n=10, md=2, RRlim=3) = 
        new(w, bc, pcg, n, md, RRlim)
end

function copy(renderer::PathTracer)
    return PathTracer(
        World(), 
        renderer.background_color, 
        PCG(renderer.pcg.state, renderer.pcg.inc),
        renderer.num_of_rays,
        renderer.max_depth,
        renderer.russian_roulette_limit,
    )
end

"""
    PointLightRenderer <: Renderer (
        world::World,
        background_color::RGB{Float32} = RGB{Float32}(0., 0., 0.),
        ambient_color::RGB{Float32} = RGB{Float32}(0.1, 0.1, 0.1)
        dark_parameter::Float64 = 0.05
    )

A simple point-light tracing renderer.

## Arguments

- `world::World` : the world to be rendered

- `background_color::RGB{Float32}` : default background color 
  if the Ray doesn-t hit anything

- `ambient_color::RGB{Float32}` : default ambient color 

- `dark_parameter::Float64` : float that defines the retuned percentage
  of the hit point color if it is not visible from any of the point-light
  source of the image; a non-zero value allows to see also the not-directly
  illuminated parts of the image.

See also: [`Renderer`](@ref), [`World`](@ref)
"""
mutable struct PointLightRenderer <: Renderer
    world::World
    background_color::RGB{Float32}
    ambient_color::RGB{Float32}
    dark_parameter::Float64    
    PointLightRenderer(
            w::World = World(), 
            bc=RGB{Float32}(0., 0., 0.), 
            ac=RGB{Float32}(0.1, 0.1, 0.1),
            dp=0.05
        ) = new(w, bc, ac, dp)
end

function copy(renderer::PointLightRenderer)
    return PointLightRenderer(
        World(), 
        renderer.background_color, 
        renderer.ambient_color, 
        renderer.dark_parameter
    )
end

##########################################################################################92
