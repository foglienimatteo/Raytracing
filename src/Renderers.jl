# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

"""
    (renderer::OnOffRenderer)(ray::Ray) :: RGB{Float32}

Return the `renderer` color (default WHITE) if the ray hit an object, 
else return the `renderer` background color (default BLACK).

See also: [`OnOffRenderer`](@ref), [`Ray`](@ref)
"""
function (renderer::OnOffRenderer)(ray::Ray) 
    ray_intersection(renderer.world, ray) ≠ nothing ? 
        renderer.color : 
        renderer.background_color
end

"""
    (renderer::FlatRenderer)(ray::Ray) :: RGB{Float32}

Return the `renderer` background color (default BLACK) if ray 
doesn't hit any objects, else evaluate the color depending on 
the material and the self luminosity.

See also: [`FlatRenderer`](@ref), [`Ray`](@ref)
"""
function (renderer::FlatRenderer)(ray::Ray)
    hit = ray_intersection(renderer.world, ray)
    !(isnothing(hit)) || (return renderer.background_color)

    mat = hit.shape.Material
    col1 = get_color(mat.brdf.pigment, hit.surface_point)
    col2 = get_color(mat.emitted_radiance, hit.surface_point)

    return (col1 + col2)
end

"""
    (renderer::PathTracer)(ray::Ray) :: RGB{Float32}

A simple path-tracing renderer.

Given the `renderer` parameters (`world`, `background_color`, `pcg`, 
`num_of_rays`, `max_depth` and `russian_roulette_limit`) evaluate the 
radiance contribute for each secondary `Ray` according to them.

See also: [`PathTracer`](@ref), [`Ray`](@ref)
"""
function (renderer::PathTracer)(ray::Ray)
    !(ray.depth > renderer.max_depth) || (return BLACK)

    hit_record = ray_intersection(renderer.world, ray)
    !isnothing(hit_record) || (return renderer.background_color)

    hit_material = hit_record.shape.Material
    hit_surface_point = hit_record.surface_point
    hit_color = get_color(hit_material.brdf.pigment, hit_surface_point)
    emitted_radiance = get_color(hit_material.emitted_radiance, hit_surface_point)
    hit_color_lum = max(hit_color.r, hit_color.g, hit_color.b)

    # Russian Roulette
    if ray.depth >= renderer.russian_roulette_limit
        if random(renderer.pcg) > hit_color_lum
            # Keep the recursion going, but compensate 
            # for other potentially discarded rays
            hit_color *= 1.0 / (1.0 - hit_color_lum)
        else
            # Terminate prematurely
            return emitted_radiance
        end
    end

    # Monte Carlo integration
    
    cum_radiance =  RGB{Float32}(0.0, 0.0, 0.0)
    num_of_rays = renderer.num_of_rays
    # Only do costly recursions if it's worth it
    if hit_color_lum > 0.0
        for ray_index in 1:num_of_rays
            new_ray = scatter_ray(
                            typeof(hit_material.brdf),
                            renderer.pcg,
                            hit_record.ray.dir,
                            hit_record.world_point,
                            hit_record.normal,
                            ray.depth + 1,
                        )
            
            # Recursive call
            new_radiance = renderer(new_ray)

            cum_radiance += hit_color * new_radiance
        end
    end

    return emitted_radiance + cum_radiance * (1.0 / num_of_rays)
end

function (renderer::PointLightRenderer)(ray::Ray)
    hit_record = ray_intersection(renderer.world, ray)
    !isnothing(hit_record) || (return renderer.background_color)

    hit_material = hit_record.shape.Material
    flag_bg = hit_record.shape.flag_background
    flag_pl = hit_record.shape.flag_pointlight
    result_color = renderer.ambient_color 

    for cur_light in renderer.world.point_lights
        if is_point_visible(renderer.world, cur_light.position, hit_record.world_point) && flag_bg==false && flag_pl==false
            distance_vec = hit_record.world_point - cur_light.position
            distance = norm(distance_vec)
            in_dir = distance_vec * (1.0 / distance)
            #cos_theta = max(0.0, -normalize(ray.dir)⋅hit_record.normal) 
            cos_theta = max(0.0, -normalize(distance_vec)⋅hit_record.normal) 

            distance_factor =  
                (cur_light.linear_radius > 0) ? 
                (cur_light.linear_radius / distance)^2 : 
                1.0

            emitted_color = get_color(hit_material.emitted_radiance, hit_record.surface_point)
            brdf_color = evaluate(
                            hit_material.brdf,
                            hit_record.normal,
                            in_dir,
                            -ray.dir,
                            hit_record.surface_point,
                        )
            result_color += (emitted_color + brdf_color) * cur_light.color * cos_theta * distance_factor

        elseif flag_pl==true && flag_bg==false
            distance_vec = hit_record.world_point - cur_light.position
            distance = norm(distance_vec)
            in_dir = distance_vec * (1.0 / distance)
            cos_theta = max(0.0, -normalize(ray.dir)⋅hit_record.normal) 
            #cos_theta = max(0.0, -normalize(distance_vec)⋅hit_record.normal) 

            distance_factor =  
                (cur_light.linear_radius > 0) ? 
                (cur_light.linear_radius / distance)^2 : 
                1.0

            emitted_color = get_color(hit_material.emitted_radiance, hit_record.surface_point)
            brdf_color = evaluate(
                            hit_material.brdf,
                            hit_record.normal,
                            in_dir,
                            -ray.dir,
                            hit_record.surface_point,
                        )
            result_color += (emitted_color + brdf_color) * cur_light.color * cos_theta * distance_factor

        elseif flag_bg==true
            result_color += get_color(hit_material.brdf.pigment, hit_record.surface_point)

        else
            result_color += renderer.dark_parameter*get_color(hit_material.brdf.pigment, hit_record.surface_point)
        end
    end

    return result_color 
end
