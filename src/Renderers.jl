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
    call(::FloatRenderer, ::Ray) -> RGB{Float32}

give WHITE if the ray hit the object, else BLACK
"""
function call(OnOffR::OnOffRenderer, r::Ray) 
    ray_intersection(OnOffR.world, r) ≠ nothing ? OnOffR.color : OnOffR.background_color
end

"""
    call(::FlatRenderer, ::Ray) -> RGB{Float32}

give BLACK if ray doesn't hit any objects, else evaluate the color depending on the material and the self luminosity
"""
function call(FlatR::FlatRenderer, r::Ray)
    hit = ray_intersection(FlatR.world, r)
    !(isnothing(hit)) || (return FlatR.background_color)

    mat = hit.shape.Material
    col1 = get_color(mat.brdf.pigment, hit.surface_point)
    col2 = get_color(mat.emitted_radiance, hit.surface_point)

    return (col1 + col2)
end