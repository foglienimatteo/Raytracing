# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

@doc raw"""
    scatter_ray(
        ::Type{DiffuseBRDF},
        pcg::PCG, 
        incoming_dir::Vec, 
        interaction_point::Point, 
        normal::Normal, 
        depth::Int64,
        ) :: Ray

Return a `Ray` scattered by a material with a `DiffuseBRDF`.

A `DiffuseBRDF` has a uniform BRDF, i.e. 
``f_r(\mathbf{x}, \mathbf{\Psi}\rightarrow\mathbf{\Theta}) = \rho_d / \pi``;
the importance sampling for the `PathTracer` algorithm use consequently the 
following PDF:

```math
p(\omega) \propto 
    f_r(\mathbf{x}, \mathbf{\Psi}\rightarrow\mathbf{\Theta}) \, \cos(\vartheta)
    = \frac{\rho_d}{\pi} \, \cos(\vartheta) 
    \propto \cos(\vartheta)
```
```math
    \Rightarrow \quad
p(\omega) = \frac{\cos(\vartheta)}{\pi} 
    \quad \Rightarrow \quad
p(\vartheta ,\varphi) = \frac{\cos(\vartheta) \, \sin(\vartheta) }{2\pi}
```
```math
\Rightarrow \quad
\begin{aligned}
    &p(\vartheta) = 2 \, \cos(\vartheta) \, \sin(\vartheta) \\
    &p(\varphi | \vartheta) = \frac{1}{2 \pi}
\end{aligned}
```

See also: [`DiffuseBRDF`](@ref), [`Ray`](@ref), [`Vec`](@ref), 
[`Point`](@ref), [`Normal`](@ref), [`PCG`](@ref)
"""
function scatter_ray(
            ::Type{DiffuseBRDF},
            pcg::PCG, 
            incoming_dir::Vec, 
            interaction_point::Point, 
            normal::Normal, 
            depth::Int64,
            )
            
    e1, e2, e3 = create_onb_from_z(normal)
    cos_θ_sq = random(pcg)
    cos_θ, sin_θ = √(cos_θ_sq) , √(1.0 - cos_θ_sq)
    ϕ = 2.0 * pi * random(pcg)

    return Ray(
                interaction_point,
                e1*cos(ϕ)*cos_θ + e2*sin(ϕ)*cos_θ + e3*sin_θ,
                1.0e-3,   # tmin, be generous here
                Inf,
                depth
            )
end


@doc raw"""
    scatter_ray(
        ::Type{SpecularBRDF},
        pcg::PCG, 
        incoming_dir::Vec, 
        interaction_point::Point, 
        normal::Normal, 
        depth::Int64,
        ) :: Ray

Return a `Ray` scattered by a material with a `SpecularBRDF`.

A `SpecularBRDF` has a Dirac delta BRDF, i.e.:

```math
f_r(\mathbf{x}, \mathbf{\Psi} \rightarrow \mathbf{\Theta}) 
    \propto 
\frac{\delta(\sin^2\theta_r - \sin^2\theta) \, 
    \delta(\psi_r \pm \pi - \psi)}{\cos\theta},
```

The importance sampling for the `PathTracer` algorithm use consequently the 
following PDF:

```math
p(\omega) \propto 
    f_r(\mathbf{x}, \mathbf{\Psi}\rightarrow\mathbf{\Theta}) \, \cos(\vartheta)
    \propto \frac{1}{\cos(\vartheta)} \, \cos(\vartheta) 
    \propto cost
```

See also: [`SpecularBRDF`](@ref), [`Ray`](@ref), [`Vec`](@ref), 
[`Point`](@ref), [`Normal`](@ref), [`PCG`](@ref)
"""
function scatter_ray(
            ::Type{SpecularBRDF},
            pcg::PCG, 
            incoming_dir::Vec, 
            interaction_point::Point, 
            normal::Normal, 
            depth::Int64,
            ) 
    #ray_dir = normalize(Vec(incoming_dir.x, incoming_dir.y, incoming_dir.z))
    ray_dir = normalize(incoming_dir)

    return Ray(
                interaction_point,
                ray_dir - normal*2.0*(Vec(normal) ⋅ ray_dir),
                1e-3,
                Inf,
                depth
            )
end

#=
scatter_ray(
            b::BRDF,
            pcg::PCG, 
            incoming_dir::Vec, 
            interaction_point::Point, 
            normal::Normal, 
            depth::Int64,
        ) =
        scatter_ray(
            typeof(b),
            pcg, 
            incoming_dir, 
            interaction_point, 
            normal, 
            depth,
        )
=#
