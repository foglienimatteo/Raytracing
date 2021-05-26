# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#


"""
Return the color of the pigment at the specified coordinates
"""
get_color(p::Pigment, uv::Vec2d) = ErrorExpectation("struct Pigment is abstract and cannot be used in get_color()")

get_color(p::UniformPigment, uv::Vec2d) = p.color

function get_color(p::CheckeredPigment, uv::Vec2d)
    u = floor(uv.u * p.num_steps)
    v = floor(uv.v * p.num_steps)
    ( (u%2) == (v%2) ) ? p.color1 : p.color2
end

function get_color(p::ImagePigment, uv::Vec2d)
    col = floor(uv.u * p.image.width)
    row = floor(uv.v * p.image.height)
    (col < p.image.width) || (col = p.image.width - 1)
    (row < p.image.height) || (row = p.image.height - 1)

    return get_pixel(p.image, convert(Int64, col), convert(Int64, row))
end

##########################################################################################92

evaluate(b::BRDF, n::Normal, in_dir::Vec, out_dit::Vec, uv::Vec2d) = BLACK

evaluate(   b::DiffuseBRDF, 
            n::Normal, 
            in_dir::Vec, 
            out_dit::Vec, 
            uv::Vec2d
            ) = get_color(b.pigment, uv) * (p.reflectance / pi)