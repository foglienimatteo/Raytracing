# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni

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