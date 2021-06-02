# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


"""
    at(r::Ray, t::Float64) :: Point

Compute the point along the ray's path at some distance from the origin.

Return a [`Point`](@ref) object representing the point in 3D space whose distance
from the ray's origin is equal to `t`, measured in units of the length of `Vec.dir`.

See also: [`Ray`](@ref), [`Point`](@ref), [`Vec`](@ref)
"""
at(r::Ray, t::Float64) = r.origin + r.dir * t

##########################################################################################92

function fire_ray(Ocam::OrthogonalCamera, u::Float64, v::Float64)
    origin = Point(-1.0, (1.0 - 2 * u) * Ocam.a, 2 * v -1)
    direction = Vec(1.0, 0.0, 0.0)
    return Ocam.T*Ray(origin, direction, 1.0)
end # fire_ray

function fire_ray(Pcam::PerspectiveCamera, u::Float64, v::Float64)
    origin = Point(-Pcam.d, 0.0, 0.0)
    direction = Vec(Pcam.d, (1.0 - 2 * u) * Pcam.a,  2 * v - 1)
    return Pcam.T*Ray(origin, direction, 1.0)
end # fire_ray

function fire_ray(
                ImTr::ImageTracer, 
                col::Int64, row::Int64, 
                u_px::Float64=0.5, v_px::Float64=0.5
            )
    u = (col + u_px) / (ImTr.img.width)
    v = 1. - (row + v_px) / (ImTr.img.height)
    return fire_ray(ImTr.cam, u, v)
end

"""
    fire_ray(Ocam::OrthogonalCamera, u::Float64, v::Float64) :: Ray
    fire_ray(Pcam::PerspectiveCamera, u::Float64, v::Float64) :: Ray
    fire_ray(
            ImTr::ImageTracer, 
            col::Int64, row::Int64, 
            u_px::Float64=0.5, v_px::Float64=0.5
        ) :: Ray

Shoot one light `Ray` through the pixel (`col`, `row`) of `ImTr.img` image. 
The parameters (`col`, `row`) are measured in a diffetent way compared to the
`HDRimage` struct: here, the bottom left corner is placed at `(0, 0)`.
The following diagram shows the convenction for an image with dimensions (`w`,`h`):
```ditaa
| (h,0)  (h,1)  (h,2)  ...  (h,w) |
|  ...    ...    ...   ...   ...  |
| (1,0)  (1,1)  (1,2)  ...  (1,w) |
| (0,0)  (0,1)  (0,2)  ...  (0,w) |
```

The optional values `u_px` and `v_px` specify where the ray should cross
the pixel; the convenction for their values are represented in the following 
diagram as `(u_px, v_px)`:
```ditaa
(0, 1)                          (1, 1)
    +------------------------------+
    |                              |
    |                              |
    |                              |
    +------------------------------+
(0, 0)                          (1, 0)
```

See also: [`OrthogonalCamera`](@ref), [`PerspectiveCamera`](@ref),
[`Ray`](@ref), [`HDRimage`](@ref), [`ImageTracer`](@ref)
"""
fire_ray

##########################################################################################92

"""
    fire_all_rays!(ImTr::ImageTracer, func::Function)
 
Shoot several light rays crossing each of the pixels in the `ImTr.img` image.

For each pixel in the `HDRimage` object fire one `Ray`, and pass it 
to the function `func`, which must:
- accept a `Ray` as its only parameter 
- return a `RGB{Float32}` color instance telling the color to 
  assign to that pixel in the image.

See also: [`Ray`](@ref), [`HDRimage`](@ref), [`ImageTracer`](@ref)
"""
function fire_all_rays!(ImTr::ImageTracer, func::Function)
    for row in ImTr.img.height-1:-1:0, col in 0:ImTr.img.width-1
        ray = fire_ray(ImTr, col, row)
        color::RGB{Float32} = func(ray)
        set_pixel(ImTr.img, col, row, color)
    end
    nothing
end # fire_all_rays!
