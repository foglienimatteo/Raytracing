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
end

function fire_ray(Pcam::PerspectiveCamera, u::Float64, v::Float64)
    origin = Point(-Pcam.d, 0.0, 0.0)
    direction = Vec(Pcam.d, (1.0 - 2 * u) * Pcam.a,  2 * v - 1)
    return Pcam.T*Ray(origin, direction, 1.0)
end

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


function print_progress(row::Int64, col::Int64)
        println("Rendering row $((row + 1)/col)")
end

"""
    fire_all_rays!(
            ImTr::ImageTracer, 
            func::Function, 
            callback::Union{Nothing, Function} = nothing,
            callback_time_s::Float64 = 2.,
            callback_kwargs::String
            )
 
Shoot several light rays crossing each of the pixels in the `ImTr.img` image.

For each pixel in the `HDRimage` object fire one `Ray`, and pass it 
to the function `func`, which must:
- accept a `Ray` as its only parameter 
- return a `RGB{Float32}` color instance telling the color to 
  assign to that pixel in the image.

If `callback` is not `nothing`, it must be a function accepting at least two 
parameters named `col` and `row`.
This function is called periodically during the rendering, and the two mandatory 
arguments are the row and column number of the last pixel that has been traced. 

_**Pay Attention**_: Both the row and column are increased by one starting
from zero: first the row and then the column.

The time between two consecutive calls to the callback can be tuned using the 
parameter `callback_time_s`. Any keyword argument passed to `fire_all_rays` 
is passed to the callback.

See also: [`Ray`](@ref), [`HDRimage`](@ref), [`ImageTracer`](@ref)
"""
function fire_all_rays!(
            ImTr::ImageTracer,
            func::Function,
            callback::Union{Nothing, Function} = nothing,
            callback_time_s::Float64 = 2.,
            callback_kwargs::Union{Nothing, String} = nothing                
            )
    last_call_time = time()  # use if @elapsed doesn't work propely for our pourpose

    !isnothing(callback) || (callback = print_progress)
    
    for row in ImTr.img.height-1:-1:0, col in 0:ImTr.img.width-1
        cum_color = RGB{Float32}(0., 0., 0.)

        # need a command from line, remember must be a squared number
        ImTr.samples_per_side <= 0 ? smp4side = 0 : smp4side = ImTr.samples_per_side
       
        #t = @elapsed 
        if smp4side > 0
            for inter_pixel_row in 0:smp4side-1, inter_pixel_col in 0:smp4side-1
                u_pixel = (inter_pixel_col + random(ImTr.pcg)) / smp4side
                v_pixel = (inter_pixel_row + random(ImTr.pcg)) / smp4side
                ray = fire_ray(ImTr, col, row, u_pixel, v_pixel)
                cum_color += func(ray)
            end
            set_pixel(ImTr.img, col, row, cum_color / smp4side^2 )
        else
            ray = fire_ray(ImTr, col, row)
            set_pixel(ImTr.img, col, row, func(ray))
        end

        current_time = time() # use if @elapsed doesn't work propely for our pourpose
        t = current_time - last_call_time # use if @elapsed doesn't work propely for our pourpose

        if (callback ≠ nothing) && (t > callback_time_s)
            callback(col, row, callback_kwargs)
            last_call_time = current_time    # use if @elapsed doesn't work propely for our pourpose
        end

    end

    nothing
end
