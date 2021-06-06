# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni.
#

get_color(p::Pigment, uv::Vec2d) = throw(MethodError(get_color, p))
#"struct Pigment is abstract and cannot be used in get_color()"

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


"""
    get_color(p::UniformPigment, uv::Vec2d) :: RGB{Float32}
    get_color(p::CheckeredPigment, uv::Vec2d) :: RGB{Float32}
    get_color(p::ImagePigment, uv::Vec2d) :: RGB{Float32}

Return the RGB color of the pigment `p` at the specified (`u`,`v`) coordinates.

See also: [`Pigment`](@ref), [`UniformPigment`](@ref), 
[`CheckeredPigment`](@ref), [`ImagePigment`](@ref), [`Vec2d`](@ref)
"""
get_color

##########################################################################################92

evaluate(b::BRDF, n::Normal, in::Vec, out::Vec, uv::Vec2d) = BLACK

evaluate(b::DiffuseBRDF, n::Normal, in::Vec, out::Vec, uv::Vec2d) = 
    get_color(b.pigment, uv) * (b.reflectance / pi)

function evaluate(b::SpecularBRDF, n::Normal, in::Vec, out::Vec, uv::Vec2d)
    θ_in = acos(n ⋅ normalize(in))
    θ_out = acos(n ⋅ normalize(out))

    if abs(θ_in - θ_out) < b.theresold_angle_rad
        return get_color(b.pigment, uv)
    else
        return BLACK
    end
end


"""
    evaluate(b::BRDF, n::Normal, in::Vec, out::Vec, uv::Vec2d) :: RGB{Float32}
    evaluate(b::DiffuseBRDF, n::Normal, in::Vec, out::Vec, uv::Vec2d) :: RGB{Float32}
    evaluate(b::SpecularBRDF, n::Normal, in::Vec, out::Vec, uv::Vec2d) :: RGB{Float32}

Return the RGB color with the specified BRDF `b` and spatial 
configuation of durface normal `n`, incident ray direction `in`, 
leaving ray direction `out`, (`u`,`v`) coordinates on surface.

See also: [`BRDF`](@ref), [`DiffuseBRDF`](@ref), [`SpecularBRDF`](@ref)
[`Normal`](@ref), [`Vec`](@ref), [`Vec2d`](@ref)
"""
evaluate