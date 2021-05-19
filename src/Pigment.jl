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

"""
Return the color of the pigment at the specified coordinates
"""
get_color(p::Pigment, uv::Vec2d) = ErrorExpectation("struct Pigment is abstract and cannot be used in get_color()")

get_color(p::UniformPigment, uv::Vec2d) = p.color

function get_color(p::CheckeredPigment, uv::Vec2d)
    u = floor(uv.u * p.num_steps)
    v = floor(uv.v * p.num_steps)
    if (u%2) == (v%2)
        return p.color1
    else
        return p.color2
    end
end

function get_color(p::ImagePigment, uv::Vec2d)
    col = uv.u * p.image.width
    row = uv.v * p.image.height
    (col >= p.image.width) || (col = p.image.width - 1)
    (row >= p.image.heigh) || (row = p.image.heigh - 1)

    return get_pixel(p.image, col, row)
end

##########################################################################################92

eval(b::BRDF, n::Normal, in_dir::Vec, out_dit::Vec, uv::Vec2d) = BLACK

eval(b::DiffuseBRDF, n::Normal, in_dir::Vec, out_dit::Vec, uv::Vec2d) = get_color(b.pigment, uv) * (p.reflectance / pi)