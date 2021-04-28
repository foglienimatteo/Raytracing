""" This type defines a image in format HDR; has three members:
    - width
    - height
    - array containing RGB color, it's a 2linearized" matrix; the first element is the one in the bottom-left of the matrix, then the line is read left-to-right and going to the upper row.
    Has two constructors:
    - HDRimage(width, height)
    - HDRimage(width, height, RGB-array)"""
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

""" Type used to save (passed from command line):
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

struct Point
    x::Float64
    y::Float64
    z::Float64
    Point(x, y, z) = new(x, y, z)
    Point() = new(0., 0. ,0.)
end

struct Normal
    x::Float64
    y::Float64
    z::Float64
    function Normal(x, y, z)
        m = √(x^2+y^2+z^2)
        new(x/m, y/m, z/m)
    end
end

struct Vec
    x::Float64
    y::Float64
    z::Float64
    Vec(x, y, z) = new(x, y, z)
    Vec()=new(0.0, 0.0, 0.0)
end

struct Transformation
    M::SMatrix{4,4,Float64}
    invM::SMatrix{4,4,Float64}
    Transformation(m, invm) = new(m, invm)
    Transformation() = new( SMatrix{4,4}( Diagonal(ones(4)) ),  SMatrix{4,4}( Diagonal(ones(4)) ) )
end

struct Ray
    origin::Point
    dir::Vec
    tmin::Float64
    tmax::Float64
    depth::Int64
    Ray(o, d, m=1e-5, M=Inf, n=0) = new(o, d, m, M, n)
end

abstract type Camera end

struct OrthogonalCamera <: Camera
    a::Float64 # aspect ratio
    T::Transformation
    OrthogonalCamera(a=1., T=Transformation()) = new(a, T)
end 

struct PerspectiveCamera <: Camera
    d::Float64 # distance from the screen
    a::Float64 # aspect ratio
    T::Transformation
    PerspectiveCamera(d=1., a=1., T=Transformation()) = new(d, a, T)
end 

struct ImageTracer
    img::HDRimage
    cam::Camera
end