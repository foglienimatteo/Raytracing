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
function (renderer::OnOffRenderer)(ray::Ray, a::Bool=false) 
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
function (renderer::FlatRenderer)(ray::Ray, a::Bool=false)
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
function (renderer::PathTracer)(ray::Ray, a::Bool=false)
    !(ray.depth > renderer.max_depth) || (return BLACK)

    hit_record = ray_intersection(renderer.world, ray)
    !isnothing(hit_record) || (return renderer.background_color)

    hit_material = hit_record.shape.Material
    hit_surface_point = hit_record.surface_point
    hit_color = get_color(hit_material.brdf.pigment, hit_surface_point)
    emitted_radiance = get_color(hit_material.emitted_radiance, hit_surface_point)
    hit_color_lum = max(hit_color.r, hit_color.g, hit_color.b)
#=    if ray ≈ Ray(Point(-2.0, 0.0, 1.0), Vec(1.0, 1.2083333333333333, 0.4750000000000001), 1, Inf, 0)
        # printstyled("\nnumber ray  ", ray_index, " : ", " dir - ", new_ray.dir, "\t obj - ", hit_record.shape, color=:light_blue)
        printstyled("\n\t hit color (0): ", hit_color, "\n",color=:light_blue)
        
        println(hit_material)
        println(hit_record)
        println(hit_surface_point)
        println(hit_color)
        println(emitted_radiance)
        println(hit_color_lum)
        print("\n\n", renderer.background_color, "\n", renderer.max_depth, "\n", renderer.num_of_rays, "\n", renderer.russian_roulette_limit, "\n")
    end =#

    (a==true) ? (b = true) : (b = false)

    # Russian Roulette
    if ray.depth >= renderer.russian_roulette_limit
        if ray ≈ Ray(Point(-2.0, 0.0, 1.0), Vec(1.0, 1.2083333333333333, 0.4750000000000001), 1, Inf, 0)
            # printstyled("\nnumber ray  ", ray_index, " : ", " dir - ", new_ray.dir, "\t obj - ", hit_record.shape, color=:light_blue)
            printstyled("\t hit color (0.5): ", hit_color, "\n",color=:light_blue)
        end
        if random(renderer.pcg) > hit_color_lum
            # Keep the recursion going, but compensate 
            # for other potentially discarded rays
            hit_color *= 1.0 / (1.0 - hit_color_lum)
            printstyled("\nB\n", color=:light_blue)
            if a == true
                printstyled("\t hit color (1): ", hit_color, "\n",color=:light_blue)
            end
            if ray ≈ Ray(Point(-2.0, 0.0, 1.0), Vec(1.0, 1.2083333333333333, 0.4750000000000001), 1, Inf, 0)
                # printstyled("\nnumber ray  ", ray_index, " : ", " dir - ", new_ray.dir, "\t obj - ", hit_record.shape, color=:light_blue)
                printstyled("\t hit color (1): ", hit_color, "\n",color=:light_blue)
            end

        else
            if a == true
                printstyled("\t hit color (2): ", hit_color, "\n",color=:light_blue)
            end
            if ray ≈ Ray(Point(-2.0, 0.0, 1.0), Vec(1.0, 1.2083333333333333, 0.4750000000000001), 1, Inf, 0)
                # printstyled("\nnumber ray  ", ray_index, " : ", " dir - ", new_ray.dir, "\t obj - ", hit_record.shape, color=:light_blue)
                printstyled("\t hit color (1): ", hit_color, "\n",color=:light_blue)
            end
            # Terminate prematurely
            return emitted_radiance
        end
    end

    # Monte Carlo integration
    
    cum_radiance =  RGB{Float32}(0.0, 0.0, 0.0)
    num_of_rays = renderer.num_of_rays
    # Only do costly recursions if it's worth it
    if hit_color_lum > 0.0
#=        if a == true
            printstyled("\n\t hit color (3): ", hit_color, "\n", color=:light_blue)
        end
        if ray ≈ Ray(Point(-2.0, 0.0, 1.0), Vec(1.0, 1.2083333333333333, 0.4750000000000001), 1, Inf, 0)
            printstyled("\nnumber ray  ", ray_index, " : ", " dir - ", new_ray.dir, "\t obj - ", hit_record.shape, color=:light_blue)
            printstyled("\t hit color (1): ", hit_color, "\n",color=:light_blue)
        end
=#        for ray_index in 1:num_of_rays
            new_ray = scatter_ray(
                            typeof(hit_material.brdf),
                            renderer.pcg,
                            hit_record.ray.dir,
                            hit_record.world_point,
                            hit_record.normal,
                            ray.depth + 1,
                        )
        #    printstyled(a, color=:light_blue)
            if b == true
                printstyled("\nnumber ray  ", ray_index, " : ", " dir - ", new_ray.dir, "\t obj - ", hit_record.shape, "\n", color=:light_blue)
            end
            # Recursive call
            new_radiance = renderer(new_ray, b)

            cum_radiance += hit_color * new_radiance
        end
    end

    return emitted_radiance + cum_radiance * (1.0 / num_of_rays)
end

function (renderer::PointLightRenderer)(ray::Ray, a::Bool=false)
    hit_record = ray_intersection(renderer.world, ray)
    !isnothing(hit_record) || (return renderer.background_color)

    hit_material = hit_record.shape.Material
    result_color = renderer.ambient_color

    for cur_light in renderer.world.point_lights
        if is_point_visible(renderer.world, cur_light.position, hit_record.world_point)
            distance_vec = hit_record.world_point - cur_light.position
            distance = norm(distance_vec)
            in_dir = distance_vec * (1.0 / distance)
            cos_theta = max(0.0, -normalize(ray.dir)⋅hit_record.normal) 

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
        end
    end

    return result_color 
end
