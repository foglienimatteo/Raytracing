# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


function catter_ray(pcg::PCG, incoming_dir::Vec, interaction_point::Point, normal::Normal, depth::Int64)
    e1, e2, e3 = create_onb_from_z(normal)
    cos_theta_sq = random_float(pcg, Float46)
    cos_theta, sin_theta = sqrt(cos_theta_sq), sqrt(1.0 - cos_theta_sq)
    phi = 2.0 * pi * pcg.random_float()

    return Ray(origin=interaction_point,
               dir=e1 * cos(phi) * cos_theta + e2 * sin(phi) * cos_theta + e3 * sin_theta,
               tmin=1.0e-3,   # Be generous here
               tmax=inf,
               depth=depth)
end

function scatter_ray(self, pcg: PCG, incoming_dir: Vec, interaction_point: Point, normal: Normal, depth: int)
    ray_dir = Vec(incoming_dir.x, incoming_dir.y, incoming_dir.z).normalize()
    normal = normal.to_vec().normalize()

    return Ray(origin=interaction_point,
               dir=ray_dir - normal * 2 * normal.dot(ray_dir),
               tmin=1e-3,
               tmax=inf,
               depth=depth)
end