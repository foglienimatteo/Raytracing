# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



"""
    call(::OnOffRenderer, ::Ray) -> RGB{Float32}

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

"""
    call(::PathTracer, ::Ray) -> RGB{Float64}
"""
function call(PT::PathTracer, r::Ray)
    if r.depth > PT.max_depth
        return BLACK
    end

    hit_record = ray_intersection(PT.world, r)
    if hit_record == nothing
        return PT.background_color
    end

    hit_material = hit_record.material
    hit_color = get_color(hit_material.brdf.pigment, hit_record.surface_point)
    emitted_radiance = get_color(hit_material.emitted_radiance, hit_record.surface_point)
    hit_color_lum = max(hit_color.r, hit_color)

    # Russian Roulette
    if r.depth >= PT.russian_roulette_limit
        if random(PT.pcg) > hit_color_lum
            hit_color *= 1.0 / (1.0 - hit_color_lum)
        else
            # Terminate prematurely
            return emitted_radiance
        end
    end

    cum_radiance = BLACK
    if hit_color_lum > 0.0
        for ray_index ∈ 0:PT.N
            new_ray = scatter_ray(PT.pcg,
                                  hit_record.ray.dir,
                                  hit_record.world_point,
                                  hit_record.normal, 
                                  ray.depth + 1,
                                  hit.material.brdf
            )
            new_radiance = call(PT, new_ray)
            cum_radiance = hit_color * new_radiance
        end
    end

    return emitted_radiance + cum_radiance / PT.N
end