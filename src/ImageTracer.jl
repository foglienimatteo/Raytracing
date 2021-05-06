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

"""
    at(r::Ray, t::Float64) -> Point

    Compute the point along the ray's path at some distance from the origin.

    Return a `Point` object representing the point in 3D space whose distance from the
    ray's origin is equal to `t`, measured in units of the length of `Vec.dir`.
"""
at(r::Ray, t::Float64) = r.origin + r.dir * t

##########################################################################################92

"""
    fire_ray(Ocam::OrthogonalCamera, u::Float64, v::Float64) -> Ray

    Shoot a ray through the orthogonal camera's screen.

    The coordinates (u, v) specify the point on the screen where the ray crosses it. 
    Coordinates (0, 0) represent the bottom-left corner, (0, 1) the top-left corner, 
    (1, 0) the bottom-right corner, and (1, 1) the top-right corner, as in the 
    following diagram:
    ```ditaa
    (0, 1)                          (1, 1)
        +------------------------------+
        |                              |
        |                              |
        |                              |
        +------------------------------+
    (0, 0)                          (1, 0)
    ```
"""
function fire_ray(Ocam::OrthogonalCamera, u::Float64, v::Float64)
    origin = Point(-1.0, (1.0 - 2 * u) * Ocam.a, 2 * v -1)
    direction = Vec(1.0, 0.0, 0.0)
    return Ocam.T*Ray(origin, direction, 1.0)
end

##########################################################################################92

"""
    fire_ray(Pcam::PerspectiveCamera, u::Float64, v::Float64) -> Ray

    Shoot a ray through the perspective camera's screen.

    The coordinates (u, v) specify the point on the screen where the ray crosses it. 
    Coordinates (0, 0) represent the bottom-left corner, (0, 1) the top-left corner, 
    (1, 0) the bottom-right corner, and (1, 1) the top-right corner, as in the 
    following diagram:
    ```ditaa
    (0, 1)                          (1, 1)
        +------------------------------+
        |                              |
        |                              |
        |                              |
        +------------------------------+
    (0, 0)                          (1, 0)
    ```
"""
function fire_ray(Pcam::PerspectiveCamera, u::Float64, v::Float64)
    origin = Point(-Pcam.d, 0.0, 0.0)
    direction = Vec(Pcam.d, (1.0 - 2 * u) * Pcam.a,  2 * v - 1)
    return Pcam.T*Ray(origin, direction, 1.0)
end

##########################################################################################92

"""
    fire_ray(ImTr::ImageTracer, col::Int64, row::Int64, 
                u_px::Float64=0.5, v_px::Float64=0.5) -> Ray

    Shoot one light `Ray` through the pixel (`col`, `row`) of `ImTr.img` image. 
    The parameters (`col`, `row`) are measured in the same way as they are in the 
    [`HDRimage`](@ref) struct : the bottom left corner is placed at `(0, 0)``.

    The optional values`u_px` and `v_px` specify where the ray should cross the pixel; 
    the convenction for their values are represented in the following 
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
"""
function fire_ray(ImTr::ImageTracer, col::Int64, row::Int64, 
                    u_px::Float64=0.5, v_px::Float64=0.5)
    u = (col + u_px) / (ImTr.img.width)
    v = 1. - (row + v_px) / (ImTr.img.height)
    return fire_ray(ImTr.cam, u, v)
end # fire_ray

##########################################################################################92

"""
    fire_all_rays!(ImTr::ImageTracer, func::Function)
 
    Shoot several light rays crossing each of the pixels in the `ImTr.img` image.

    For each pixel in the [`HDRimage`](@ref) object fire one [`Ray`](@ref), and pass it to
    the function `func`, which must accept a `Ray` as its only parameter and must return 
    a `:RGB{Float32}` color instance telling the color to assign to that pixel in the image.
"""
function fire_all_rays!(ImTr::ImageTracer, func::Function)
    for row in ImTr.img.height-1:-1:0, col in 0:ImTr.img.width-1
        ray = fire_ray(ImTr, col, row)
        color::RGB{Float32} = func(ray)
        set_pixel(ImTr.img, col, row, color)
    end
    nothing
end
