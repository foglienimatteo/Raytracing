# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


function scatter_ray(pcg::PCG, incoming_dir::Vec, interaction_point::Point, normal::Normal, depth::Int64, ::DiffuseBRDF)
    e1, e2, e3 = create_onb_from_z(normal)
    cos_θ_sq = random_float(pcg)
    cos_θ = √(cos_θ_sq)
    sin_θ = √(1.0 - cos_θ_sq)
    ϕ = 2.0 * pi * pcg.random_float()

    return Ray(interaction_point,
                e1 * cos(ϕ) * cos_θ + e2 * sin(ϕ) * cos_θ + e3 * sin_θ,
                1.0e-3,   # tmin, be generous here
                Inf,
                depth)
end

function scatter_ray(pcg: PCG, incoming_dir::Vec, interaction_point::Point, normal::Normal, depth::int, ::SpecularBRDF)
    ray_dir = normalize(Vec(incoming_dir.x, incoming_dir.y, incoming_dir.z))
    normal = Vec(normal)

    return Ray(interaction_point,
               ray_dir - normal * 2 * (normal ⋅ ray_dir),
               1e-3,
               Inf,
               depth)
end