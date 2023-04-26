# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

##########################################################################################92

@doc raw"""
    sphere_point_to_uv(point::Point) :: Vec2d

Convert a 3D `point` ``P = (P_x, P_y, P_z)`` on the surface of the unit sphere
into a 2D `Vec2d` using the following spherical coordinates:

```math
u = \frac{\phi}{2\pi} = \frac{\arctan (P_y / P_x)}{2\pi}, 
    \quad 
v = \frac{\theta}{\pi} = \frac{\arccos (P_z)}{\pi}
```

See also: [`Point`](@ref), [`Vec2d`](@ref), [`Sphere`](@ref)
"""
function sphere_point_to_uv(point::Point)
    v = acos(point.z) / π
    u = atan(point.y, point.x) / (2.0 * π)
    u = u>=0 ? u : u + 1.0
    return Vec2d(u,v)
end

@doc raw"""
    plane_point_to_uv(point::Point) :: Vec2d

Convert a 3D `point` ``P = (P_x, P_y, P_z)`` on the surface of the unit plane
into a 2D `Vec2d` using the following periodical coordinates:

```math
u = P_x - \lfloor P_x \rfloor,
    \quad 
v = P_y - \lfloor P_y \rfloor,
```
    
where ``\lfloor \cdot \rfloor`` indicates the rounding down approximation,
in order to guarantee that ``u, v \in [0, 1)``.

See also: [`Point`](@ref), [`Vec2d`](@ref), [`Plane`](@ref)
"""
function plane_point_to_uv(point::Point)
    u = point.x - floor(point.x)
    v = point.y - floor(point.y)
    return Vec2d(u,v)
end

@doc raw"""
    cube_point_to_uv(point::Point) :: Vec2d

Convert a 3D `point` ``P = (P_x, P_y, P_z)`` on the surface of the unit cube
into a 2D `Vec2d` using the following  coordinates:

```math
P_x = \frac{1}{2} \lor P_x = -\frac{1}{2} 
\quad \Rightarrow \quad 
u = P_y +  \frac{1}{2} \; , \;   v = P_z +  \frac{1}{2}
```
```math
P_y = \frac{1}{2} \lor P_y = -\frac{1}{2} 
\quad \Rightarrow \quad 
u = P_x +  \frac{1}{2} \; , \;   v = P_z +  \frac{1}{2}
```
```math
P_z = \frac{1}{2} \lor P_z = -\frac{1}{2} 
\quad \Rightarrow \quad 
u = P_x +  \frac{1}{2} \; , \;   v = P_y +  \frac{1}{2}
```
```math
P_x \neq \frac{1}{2},  -\frac{1}{2} \land
P_y \neq \frac{1}{2},  -\frac{1}{2} \land
P_z \neq \frac{1}{2},  -\frac{1}{2} 
\quad \Rightarrow \quad 
\mathrm{throw Exception}
```

See also: [`Point`](@ref), [`Vec2d`](@ref), [`Cube`](@ref)
"""
function cube_point_to_uv(point::Point)
    if (point.x ≈ 0.5 || point.x ≈ -0.5)
        u, v  = point.y + 0.5, point.z + 0.5
    elseif (point.y ≈ 0.5 || point.y ≈ -0.5)
        u, v  = point.x + 0.5, point.z + 0.5
    elseif (point.z ≈ 0.5 || point.z ≈ -0.5) 
        u, v  = point.x + 0.5, point.y + 0.5 
    else
        throw(ArgumentError("the given point do not belong to the unit cube."))
    end   

    return Vec2d(u,v)
end

@doc raw"""
    plane_point_to_uv(P::Point) :: Vec2d
Convert a 3D `point` ``P = (P_x, P_y, P_z)`` on the surface of the torus
into a 2D `Vec2d` using the following periodical coordinates:
```math
u = 2\frac{\arctan \bigg( P_y/( r + \sqrt(P.x^2+P.z^2) -R ) \bigg)+ \frac{\pi}{2}}{2\pi}, 
    \quad 
v = \frac{\arctan \bigg(P_z / (P.x + r + R)}\bigg)+ \frac{\pi}{2}}{2\pi}
```
See also: [`Point`](@ref), [`Vec2d`](@ref), [`Plane`](@ref)
"""
# function torus_point_to_uv(P::Point, r::Float64, R::Float64)

#     # # if (x^2+z^2 >= R^2)
#     # #     #u = asin(y/r)
#     # #     u = acos(y/r)
#     # # else
#     # #     u = 2*π - acos(y/r)
#     # #     #u = π - asin(y/r)
#     # # end

#     # # if x>=0
#     # #     v = atan(z/x)
#     # # else
#     # #     v = π - atan(z/r)
#     # # end

#     # # METHOD 1
#     x = P.x
#     y = P.y
#     z = P.z

#     # (x^2+z^2 >= R^2) ? u = asin(y/r) : u = π - asin(y/r)
    
#     if abs(y/r) <= 1
#         (x^2+z^2 >= R^2) ? u = asin(y/r) : u = π/2 - asin(y/r)
#     else
#         (x^2+z^2 >= R^2) ? u = asin(1) : u = π/2 - asin(1)
#     end
    
#     # x >= 0 ? v = atan(z/x) : v = π - atan(z/r)
#     # if abs(z/(r*cos(u)+R)) > 1
#     #     println("z = ", z, "    r = ", r, "\nu = ", u, "    cos(u) = ", cos(u), "\nR = ", R, "    op: ", z/(r*cos(u)+R))
#     #     exit()
#     # end

#     if abs(z/(r*cos(u)+R)) <= 1
#         x >= 0 ? v = asin(z/(r*cos(u)+R)) : v = π - asin(z/(r*cos(u)+R))
#     # elseif abs(x/(r*cos(u)+R)) < 1
#     #     x >= 0 ? v = acos(x/(r*cos(u)+R)) : v = π - acos(x/(r*cos(u)+R))
#     else
#         x >= 0 ? v = asin(1) : v = π - asin(1)
#     end
#     # # METHOD 2
#     # x = P.x
#     # y = P.y
#     # z = P.z

#     # (x^2+z^2 >= R^2) ? u = acos(y/r) : u = 2*π - acos(y/r)
#     # x >= 0 ? v = atan(z/x) : v = π - atan(z/r)

#     # u < 0 ? u += 1 : nothing
#     # v < 0 ? v += 1 : nothing
#     println(P)
#     println("\nu: ",u,"    v:", v)
    
#     a = Vec2d(u, v) / (2*π)
#     @assert 0 <= a.u <= 1
#     @assert 0 <= a.v <= 1

#     return a
# end

function torus_point_to_uv(P::Point, r::Float64, R::Float64)

    x = P.x
    y = P.y
    z = P.z
    
    if abs(z/r) <= 1
        (x^2+y^2 >= R^2) ? u = asin(z/r) : u = π - asin(z/r)
    elseif z > 0
        u = π/2
    elseif z < 0
        u = 1.5*π
    else
        @assert false "This line should be unreachable, problem in estimating 'torus_point_to_uv', 'u' variable"
    end

    if abs(x/(r*cos(u)+R)) <= 1
        y >= 0 ? v = acos(x/(r*cos(u)+R)) : v = 2*π - acos(x/(r*cos(u)+R))
    elseif x > 0
        v = 0
    elseif x < 0
        v = π
    else
        @assert false "This line should be unreachable, problem in estimating 'torus_point_to_uv', 'v' variable"
    end

    # if abs(y/(r*cos(u)+R)) <= 1
    #     y >= 0 ? v = π/2 + asin(y/(r*cos(u)+R)) : v = π - acos(y/(r*cos(u)+R))
    # elseif y > 0
    #     v = π/2
    # elseif y < 0
    #     v = 1.5 * π
    # else
    #     @assert false "This line should be unreachable, problem in estimating 'torus_point_to_uv', 'v' variable"
    # end
    
    a = Vec2d(u, v) / (2*π)
    @assert 0 <= a.u <= 1
    @assert 0 <= a.v <= 1

    return a
end

@doc raw"""
    triangle_point_to_uv(triangle::Triangle, point::Point) :: Vec2d

Return the barycentic coordinates of the given `point` for the input
`triangle`.

If the triangle is made of the vertexes ``(A,B,C)`` (memorized in this order),
then the point ``P`` has coordinates ``(u,v) = (\beta, \gamma)`` such that:
```math
    P(\beta, \gamma) = A + \beta \,(B - A) + \gamma \,(C-A)
```
The analitic resolution of this linear system is:
```math
\begin{aligned}
&\beta = \frac{
            (P_x - A_x)(C_y - A_y) - (P_y - A_y)(C_x - A_x)
        }{
            (B_x - A_x)(C_y - A_y) - (B_y - A_y)(C_x - A_x)
        } \\
&\gamma = \frac{
            (P_x - A_x)(B_y - A_y) - (P_y - A_y)(B_x - A_x)
        }{
            (C_x - A_x)(B_y - A_y) - (C_y - A_y)(B_x - A_x)
        }
\end{aligned}
```

**NOTE**: this function do not check if ``P`` is on the plane defined by ``(A,B,C)``, 
neither if ``P`` is inside the triangle made of them!

See also: [`Triangle`](@ref), [`Vec2d`](@ref), [`Point`](@ref)
"""
function triangle_point_to_uv(triangle::Triangle, point::Point)
    A, B, C = Tuple(P for P in triangle.vertexes)
    P = point
    
    β_num = (P.x - A.x)*(C.y - A.y) - (P.y - A.y)*(C.x - A.x)
    β_den = (B.x - A.x)*(C.y - A.y) - (B.y - A.y)*(C.x - A.x)
    β = β_num/β_den

    γ_num = (P.x - A.x)*(B.y - A.y) - (P.y - A.y)*(B.x - A.x)
    γ_den = (C.x - A.x)*(B.y - A.y) - (C.y - A.y)*(B.x - A.x)
    γ = γ_num/γ_den

    Vec2d(β, γ)
end

##########################################################################################92

@doc raw"""
    sphere_normal(point::Point, ray_dir::Vec) :: Normal

Compute the `Normal` of a unit sphere.

The normal is computed for the given `Point` ``point = (P_x, P_y, P_z)`` 
(with ``\sqrt{P_x^2 + P_y^2 + P_z^2}=1``) on the 
surface of the sphere, and it is chosen so that it is always in the opposite
direction with respect to the given `Vec` `ray_dir`.

See also: [`Point`](@ref), [`Ray`](@ref), [`Normal`](@ref), [`Sphere`](@ref)
"""
function sphere_normal(point::Point, ray_dir::Vec)
    result = Normal(point.x, point.y, point.z)
    Vec(point) ⋅ ray_dir < 0.0 ? nothing : result = -result
    return result
end

@doc raw"""
    plane_normal(point::Point, ray_dir::Vec) :: Normal

Compute the `Normal` of a unit plane.

The normal is computed for the given `point` ``P = (P_x, P_y, 0)`` on the 
surface of the plane, and it is chosen so that it is always in the opposite
direction with respect to the given `Vec` `ray_dir`.

See also: [`Point`](@ref), [`Ray`](@ref), [`Normal`](@ref), [`Plane`](@ref)
"""
function plane_normal(point::Point, ray_dir::Vec)
    result = Normal(0., 0., 1.)
    Vec(0., 0., 1.) ⋅ ray_dir < 0.0 ? nothing : result = -result
    return result
end

@doc raw"""
    cube_normal(point::Point, ray_dir::Vec) :: Normal

Compute the `Normal` of a unit cube.

The normal is computed for the given `point` on the 
surface of the cube, and it is chosen so that it is always in the opposite
direction with respect to the given `Vec` `ray_dir`.

See also: [`Point`](@ref), [`Ray`](@ref), [`Normal`](@ref), [`Cube`](@ref)
"""
function cube_normal(point::Point, ray_dir::Vec)
    if (point.x ≈ 0.5 || point.x ≈ -0.5)
        result = Normal(1., 0., 0.)
    elseif (point.y ≈ 0.5 || point.y ≈ -0.5)
        result = Normal(0., 1., 0.)
    elseif (point.z ≈ 0.5 || point.z ≈ -0.5) 
        result = Normal(0., 0., 1.)
    else
        throw(ArgumentError("the given point do not belong to the unit cube."))
    end 

    result ⋅ ray_dir < 0.0 ? nothing : result = -result
    return result
end

"""
    torus_normal(p::Point, ray_dir::Vec, R::Float64) -> Normal

Compite the [`Normal`](@ref) of a torus

The normal is computed for [`Point`](@ref) (a point on the surface of the
torus), and it is chosen so that it is always in the opposite
direction with respect to `ray_dir` ([`Vec`](@ref)).
"""
# function torus_normal(P::Point, ray_dir::Vec, r::Float64, R::Float64)
#     # R_z = copysign(R / √(1+(P.x/P.z)^2), P.z)
#     # R_x = copysign(P.x / P.z * R_z, P.x)
#     # R_p = Vec(R_x, 0, R_z)
#     # result = Normal(Vec(P - R_p))
#     # result ⋅ ray_dir < 0.0 ? nothing : result = -result
#     # return result

#     ##########################################################################################################

#     # if abs((1 - (P.z/r)^2)) < 1e-8
#     #     N_x = 0.
#     #     N_y = 0.
#     # else
#     #     (abs(P.x) < 1e-6) ? (N_x = 0.) : (N_x = copysign( ((1 - (P.z/r)^2) / (1 + (P.y/P.x)^2))^0.5, P.x))
#     #     (abs(P.y) < 1e-6) ? (N_y = 0.) : (N_y = copysign( ((1 - (P.z/r)^2) / (1 + (P.x/P.y)^2))^0.5, P.y))
#     # end
#     # N_z = P.z/r
#     # result = Normal(N_x, N_y, N_z)
#     # result ⋅ ray_dir < 0.0 ? nothing : result = -result
#     # return result

#     ###########################################################################################################

#     # u e v mi danno gia' tutte le info che mi servono per la retta della normale, il verso ancora
#     # dalla provenienza del raggio luce

#     uv = torus_point_to_uv(P, r, R)
#     u = uv.u
#     v = uv.v
#     # N = Normal(cos(2.0*u*pi)*cos(2.0*v*pi), cos(2.0*u*pi)*sin(2.0*v*pi), sin(2.0*v*pi))
#     # N = Normal(cos(2.0*u*pi)*cos(2.0*v*pi), -sin(2.0*v*pi), sin(2.0*u*pi)*cos(2.0*v*pi))
#     N = Normal(cos(2.0*u*pi)*cos(2.0*v*pi), sin(2.0*u*pi)*cos(2.0*v*pi), -sin(2.0*v*pi))
#     N ⋅ ray_dir < 0.0 ? nothing : N = -N
#     return N

#     ###########################################################################################################
#     # https://github.com/marcin-chwedczuk/ray_tracing_torus_js/blob/master/app/scripts/Torus.js

#     # s = squared_norm(P)
#     # a = R^2+r^2
#     # N = Normal(s-a, s-a +2*R^2, s-a)

#     # N ⋅ ray_dir < 0.0 ? nothing : N = -N
#     # return N
    
#     ############################################################################################################

#     # Q = R/√(P.x^2-P.z^2) * Point(P.x, 0, P.z)
#     # M = Normal(P - Q)
#     # M ⋅ ray_dir < 0.0 ? nothing : M = -M

#     # # println("u = ", u, "     v = ", v)
#     # # println(N, "    ", M)
#     # # @assert M ≈ N

#     # return M
# end

function torus_normal(P::Point, ray_dir::Vec, r::Float64, R::Float64)
    # u e v mi danno gia' tutte le info che mi servono per la retta della normale, il verso ancora
    # dalla provenienza del raggio luce

    uv = torus_point_to_uv(P, r, R)
    u = uv.u
    v = uv.v
    # N = Normal(cos(2.0*u*pi)*cos(2.0*v*pi), sin(2.0*u*pi)*cos(2.0*v*pi), sin(2.0*v*pi))
    N = Normal(cos(2.0*u*pi)*cos(2.0*v*pi), sin(2.0*v*pi)*cos(2.0*u*pi), sin(2.0*u*pi))
    N ⋅ ray_dir < 0.0 ? nothing : N = -N
    return N
end

@doc raw"""
    triangle_normal(triangle::Triangle, ray_dir::Vec) :: Normal

Compute the `Normal` of a given triangle.

The normal for a triangle with vertexes ``(A, B, C)`` is computed as follows:
```math
    n = \pm (B-A) \times (C-A)
```
where the sign is chosen so that it is always in the opposite
direction with respect to the given `ray_dir`.

See also: [`Point`](@ref), [`Ray`](@ref), [`Normal`](@ref), [`Triangle`](@ref)
"""
function triangle_normal(triangle::Triangle, ray_dir::Vec)
    result = (triangle.vertexes[2] -  triangle.vertexes[1]) ×
                (triangle.vertexes[3] -  triangle.vertexes[1])
    result ⋅ ray_dir < 0.0 ? nothing : result = -result
    return Normal(result)
end


@doc raw"""
    triangle_barycenter(triangle::Triangle) :: Point

Return the barycenter of the given `triangle`.

For a triangle with vertexes ``(A, B, C)``, the barycenter
is ``M``:
```math
    M = \frac{A + B + C}{3}
```

See also: [`Triangle`](@ref), [`Point`](@ref)
"""
function triangle_barycenter(triangle::Triangle)
    A, B, C = Tuple(P for P in triangle.vertexes)
    result = Point(A.x+B.x+C.x, A.y+B.y+C.y, A.z+B.z+C.z)*1/3
    return result
end


##########################################################################################92


"""
    ray_intersection(shape::Shape, ray::Ray) :: Union{HitRecord, Nothing}

Compute the intersection between a `Ray` and a `Shape`.

See also: [`Ray`](@ref), [`Shape`](@ref)
"""
function ray_intersection(shape::Shape, ray::Ray)
    return ErrorException(
            "ray_intersection is an abstract method"*
            "and cannot be called directly"
            )
end


"""
    ray_intersection(AABB::AABB, ray::Ray) :: Bool

Check if the `ray` intersects the `AABB`.
Return `true` if intersection occurs, `false` otherwise.

See also: [`Ray`](@ref), [`AABB`](@ref), [`HitRecord`](@ref)
"""
# function ray_intersection(AABB::AABB, ray::Ray)
#     (tmin, tmax) = Tuple( sort( [ 
#                         (AABB.m.x - ray.origin.x) / ray.dir.x, 
#                         (AABB.M.x - ray.origin.x) / ray.dir.x
#                     ]) )
#     (tymin, tymax) = Tuple( sort( [ 
#                         (AABB.m.y - ray.origin.y) / ray.dir.y, 
#                         (AABB.M.y - ray.origin.y) / ray.dir.y
#                     ]) )
 
#     ((tmin > tymax) || (tymin > tmax)) && (return false)
 
#     (tymin > tmin) && (tmin = tymin)
#     (tymax < tmax) && (tmax = tymax)

#     (tzmin, tzmax) = Tuple( sort( [ 
#                         (AABB.m.z - ray.origin.z) / ray.dir.z, 
#                         (AABB.M.z - ray.origin.z) / ray.dir.z
#                     ]) )
 
#     ((tmin > tzmax) || (tzmin > tmax)) && (return false)
 
#     (tzmin > tmin) && (tmin = tzmin)
#     (tzmax < tmax) && (tmax = tzmax)
 
#     if (ray.tmin ≤ tmin ≤ ray.tmax) || ( ray.tmin ≤ tmax ≤ ray.tmax)
#         return true
#     else
#         return false
#     end
# end

function ray_intersection(AABB::AABB, ray::Ray)

    m = AABB.m
    M = AABB.M
    O = ray.origin
    D = ray.dir

    (tmin, tmax) = Tuple( sort([(m.x- O.x)/ D.x, (M.x- O.x)/ D.x]))
    (tymin, tymax) = Tuple( sort([(m.y - O.y)/ D.y, (M.y - O.y)/ D.y]))
 
    ((tmin > tymax) || (tymin > tmax)) && (return false)
 
    (tymin > tmin) && (tmin = tymin)
    (tymax < tmax) && (tmax = tymax)

    (tzmin, tzmax) = Tuple( sort([(m.z- O.z)/ D.z, (M.z- O.z)/ D.z])) 
 
    ((tmin > tzmax) || (tzmin > tmax)) && (return false)
 
    (tzmin > tmin) && (tmin = tzmin)
    (tzmax < tmax) && (tmax = tzmax)
 
    if (ray.tmin ≤ tmin ≤ ray.tmax) || ( ray.tmin ≤ tmax ≤ ray.tmax)
        return true
    else
        return false
    end
end

"""
    ray_intersection(sphere::Sphere, ray::Ray) :: Union{HitRecord, Nothing}

Check if the `ray` intersects the `sphere`.
Return a `HitRecord`, or `nothing` if no intersection is found.

See also: [`Ray`](@ref), [`Sphere`](@ref), [`HitRecord`](@ref)
"""
function ray_intersection(sphere::Sphere, ray::Ray)

    (ray_intersection(sphere.AABB, ray) == true) || (return nothing)

    inv_ray = inverse(sphere.T) * ray
    origin_vec = Vec(inv_ray.origin)

    a = squared_norm(inv_ray.dir)
    b = 2.0 * origin_vec ⋅ inv_ray.dir
    c = squared_norm(origin_vec) - 1.0
    Δ = b * b - 4.0 * a * c 
     
    (Δ > 0.0) || (return nothing)

    tmin = (-b - √Δ) / (2.0 * a)
    tmax = (-b + √Δ) / (2.0 * a)

    if (tmin > inv_ray.tmin) && (tmin < inv_ray.tmax)
        first_hit_t = tmin
    elseif (tmax > inv_ray.tmin) && (tmax < inv_ray.tmax)
        first_hit_t = tmax
    else
        return nothing
    end

    hit_point = at(inv_ray, first_hit_t)
    
    return HitRecord(
        sphere.T * hit_point,
        sphere.T * sphere_normal(hit_point, inv_ray.dir),
        sphere_point_to_uv(hit_point),
        first_hit_t,
        ray, 
        sphere
    )
end


"""
    ray_intersection(plane::Plane, ray::Ray) :: Union{HitRecord, Nothing}

Check if the `ray` intersects the `plane`.
Return a `HitRecord`, or `nothing` if no intersection is found.

See also: [`Ray`](@ref), [`Plane`](@ref), [`HitRecord`](@ref)
"""
function ray_intersection(plane::Plane, ray::Ray)
    inv_ray = inverse(plane.T) * ray

    !(inv_ray.dir.z ≈ 0.) || (return nothing)

    hit_t = - inv_ray.origin.z / inv_ray.dir.z

    ( (hit_t > inv_ray.tmin) && (hit_t < inv_ray.tmax) ) || (return nothing)

    hit_point = at(inv_ray, hit_t)

    return HitRecord(
        plane.T * hit_point,
        plane.T * plane_normal(hit_point, inv_ray.dir),
        plane_point_to_uv(hit_point),
        hit_t,
        ray,
        plane
    )
end


"""
    ray_intersection(cube::Cube, ray::Ray) :: Union{HitRecord, Nothing}

Check if the `ray` intersects the `cube`.
Return a `HitRecord`, or `nothing` if no intersection is found.

The implementation is only a long boring list of `if`-`else` block statements,
and may have to be optimized.

See also: [`Ray`](@ref), [`Cube`](@ref), [`HitRecord`](@ref)
"""
function ray_intersection(cube::Cube, ray::Ray)
    (ray_intersection(cube.AABB, ray) == true) || (return nothing)

    inv_ray = inverse(cube.T) * ray
    d = inv_ray.dir
    O = inv_ray.origin

    (tmin, tmax) = Tuple( sort( [ (-0.5 - O.x) / d.x, (0.5 - O.x) / d.x ]) )
    (tymin, tymax) = Tuple( sort( [ (-0.5 - O.y) / d.y, (0.5 - O.y) / d.y ]) )
 
    ((tmin > tymax) || (tymin > tmax)) && (return false)
 
    (tymin > tmin) && (tmin = tymin)
    (tymax < tmax) && (tmax = tymax)

    (tzmin, tzmax) = Tuple( sort( [ (-0.5 - O.z) / d.z, (0.5 - O.z) / d.z ]) )
 
    ((tmin > tzmax) || (tzmin > tmax)) && (return false)
 
    (tzmin > tmin) && (tmin = tzmin)
    (tzmax < tmax) && (tmax = tzmax)
 
    if (inv_ray.tmin ≤ tmin ≤ inv_ray.tmax) 
        hit_point = at(inv_ray, tmin)
        return HitRecord(
            cube.T * hit_point,
            cube.T * cube_normal(hit_point, inv_ray.dir),
            cube_point_to_uv(hit_point),
            tmin,
            ray,
            cube
        )
    elseif ( inv_ray.tmin ≤ tmax ≤ inv_ray.tmax)
        hit_point = at(inv_ray, tmax)
        return HitRecord(
            cube.T * hit_point,
            cube.T * cube_normal(hit_point, inv_ray.dir),
            cube_point_to_uv(hit_point),
            tmax,
            ray,
            cube
        )
    else
        return nothing
    end
end


# function ray_intersection(torus::Torus, ray::Ray)
#     inv_ray = inverse(torus.T) * ray

#     d = normalize(inv_ray.dir)
#     o = inv_ray.origin
#     norm²_d = squared_norm(d)
#     norm²_o = squared_norm(Vec(o))
#     r = torus.r
#     R = torus.R
    
#     c4 = norm²_d^2
#     c3 = 4 * norm²_d * (Vec(o) ⋅ d)
#     c2 = 2 * norm²_d * (norm²_o - r^2 - R^2) + 4 * (Vec(o) ⋅ d)^2 + 4 * R^2 * (d.y)^2
#     c1 = 4 * (norm²_o - r^2 - R^2) *  (Vec(o) ⋅ d) + 8 * R^2 * o.y * d.y
#     c0 = (norm²_o - r^2 - R^2)^2 - 4 * R^2 * (r^2 - (o.y)^2)

#     t_ints = roots(Polynomial([c0, c1, c2, c3, c4]))

#     hit_t = Union{Float64, Nothing}
#     hit_t = nothing
#     for i in t_ints
#         if typeof(i) == Float64
#             if (i > inv_ray.tmin) && (i < inv_ray.tmax)
#                 hit_t = i
#             end
#         end
#     end

#     if hit_t == nothing
#         return nothing
#     end
    
#     hit_point = at(inv_ray, hit_t)

#     return HitRecord(
#         torus.T * hit_point,
#         torus.T * torus_normal(hit_point, inv_ray.dir, torus.r, torus.R),
#         torus_point_to_uv(hit_point, torus.r, torus.R), # manca la funzione
#         hit_t,
#         ray, 
#         torus
#     )
# end


### THE ONE DOWN WORKS BUT ERRORS IN EVALUATING u,v COORDS AND Normal
### THIS ONE HAS ITS AXIS ALONG y DIRECTION

# function ray_intersection(torus::Torus, ray::Ray)

#     (ray_intersection(torus.AABB, ray) == true) || (return nothing)

#     inv_ray = inverse(torus.T) * ray
#     o = Vec(inv_ray.origin)
#     d = inv_ray.dir
#     norm2_d = squared_norm(d)
#     norm2_o =  squared_norm(o)
#     scalar_od = o ⋅ d
#     r = torus.r
#     R = torus.R
#     # calc = norm2_o - r^2 - R^2
#     calc = norm2_o - r^2 - R^2

#     # coefficienti per calcolo soluzioniintersezione
#     c4 = norm2_d^2
#     c3 = 4 * norm2_d * scalar_od
#     c2 = 2 * norm2_d * calc + 4 * scalar_od^2 + 4 * R^2 * d.y^2
#     c1 = 4 * calc * scalar_od + 8 * R^2 * o.y * d.y
#     c0 = calc^2 - 4 * R^2 * (r^2 - o.y^2)

#     # calcolo soluzioni
#     t_ints = roots(Polynomial([c0, c1, c2, c3, c4]))

#     # verifico esistenza di almeno una soluzione
#     (t_ints === nothing) && (return nothing)

#     hit_ts = Vector{Float64}()

#     # controllo che le soluzioni siano reali positive o che la parte immaginaria sia quasi nulla
#     for i in t_ints
#         if (typeof(i) == ComplexF64) && (abs(i.im) > 1e-8) #1e-8
#             continue
#         elseif ((typeof(i) == Float64) && (1e-8 < i < inv_ray.tmax))
#             push!(hit_ts, i)
#         elseif ((typeof(i) == ComplexF64) && (abs(i.im) < 1e-8) && (1e-8 < i.re < inv_ray.tmax)) 
#             push!(hit_ts, i.re)
#         else
#             nothing
#         end
#     end

#     (length(hit_ts) == 0) && return nothing
#     # print(" OK ")
#     real_ts = sort(hit_ts)

#     first_hit_t = inv_ray.tmin - 1
#     for i in real_ts
#         if ((i > inv_ray.tmin) && (i < inv_ray.tmax))
#             first_hit_t = i
#             break
#         end
#     end

#     if first_hit_t == inv_ray.tmin - 1
#         return nothing
#     end

#     hit_point = at(inv_ray, first_hit_t)

#     return HitRecord(
#         torus.T * hit_point,
#         torus.T * torus_normal(hit_point, inv_ray.dir, r, R),
#         torus_point_to_uv(hit_point, r, R),
#         first_hit_t,
#         ray, 
#         torus
#     )
# end


### NEW TORUS, HAS ITS AXIS ALONG z DIRECTION

function ray_intersection(torus::Torus, ray::Ray)

    (ray_intersection(torus.AABB, ray) == true) || (return nothing)

    inv_ray = inverse(torus.T) * ray
    o = Vec(inv_ray.origin)
    d = inv_ray.dir
    norm2_d = squared_norm(d)
    norm2_o =  squared_norm(o)
    scalar_od = o ⋅ d
    r = torus.r
    R = torus.R
    calc = norm2_o - r^2 - R^2

    # coefficienti per calcolo soluzioniintersezione
    c4 = norm2_d^2
    c3 = 4 * norm2_d * scalar_od
    c2 = 2 * norm2_d * calc + 4 * scalar_od^2 + 4 * R^2 * d.z^2
    c1 = 4 * calc * scalar_od + 8 * R^2 * o.z * d.z
    c0 = calc^2 - 4 * R^2 * (r^2 - o.z^2)

    # calcolo soluzioni
    t_ints = roots(Polynomial([c0, c1, c2, c3, c4]))

    # verifico esistenza di almeno una soluzione
    (t_ints === nothing) && (return nothing)

    hit_ts = Vector{Float64}()

    # controllo che le soluzioni siano reali positive o che la parte immaginaria sia quasi nulla
    for i in t_ints
        if (typeof(i) == ComplexF64) && (abs(i.im) > 1e-15) #1e-8
            continue
        elseif ((typeof(i) == Float64) && (1e-15 < i < inv_ray.tmax))
            push!(hit_ts, i)
        elseif ((typeof(i) == ComplexF64) && (abs(i.im) < 1e-15) && (1e-15 < i.re < inv_ray.tmax)) 
            push!(hit_ts, i.re)
        else
            nothing
        end
    end

    (length(hit_ts) == 0) && return nothing
    real_ts = sort(hit_ts)

    first_hit_t = inv_ray.tmin - 1
    for i in real_ts
        if ((i > inv_ray.tmin) && (i < inv_ray.tmax))
            first_hit_t = i
            break
        end
    end

    if first_hit_t == inv_ray.tmin - 1
        return nothing
    end

    hit_point = at(inv_ray, first_hit_t)

    return HitRecord(
        torus.T * hit_point,
        torus.T * torus_normal(hit_point, inv_ray.dir, r, R),
        torus_point_to_uv(hit_point, r, R),
        first_hit_t,
        ray, 
        torus
    )
end

@doc raw"""
    ray_intersection(triangle::Triangle, ray::Ray) :: Union{HitRecord, Nothing}

Check if the `ray` intersects the `triangle`.
Return a `HitRecord`, or `nothing` if no intersection is found.

For a triangle with vertexes ``(A, B, C)`` and a ray defined with the
simple equation ``r(t) = O + t \, \vec{d}``, the coordinates ``(u,v) = (\beta, \gamma)``
and the `t` value of intersection are obtained solving this linear system:
```math

\begin{bmatrix}
    B_x-A_x & C_x-A_x & -d_x \\
    B_y-A_y & C_y-A_y & -d_y \\
    B_z-A_z & C_z-A_z & -d_z 
\end{bmatrix}

\begin{bmatrix}
u \\
v \\
t
\end{bmatrix}
= 
\begin{bmatrix}
O_x - A_x\\
O_z - A_z\\
O_z - A_z
\end{bmatrix}
```

See also: [`Ray`](@ref), [`Triangle`](@ref), [`HitRecord`](@ref)
"""
function ray_intersection(triangle::Triangle, ray::Ray)

    A, B, C = Tuple(P for P in triangle.vertexes)
    m = [ray.origin.x-A.x;  ray.origin.y-A.y; ray.origin.z-A.z]
    M = [
        B.x-A.x C.x-A.x -ray.dir.x ;
        B.y-A.y C.y-A.y -ray.dir.y ;
        B.z-A.z C.z-A.z -ray.dir.z ;
    ]

    try
        w = transpose(m) / transpose(M)
        u, v, hit_t = Tuple(x for x in w)
        ( ray.tmin < hit_t < ray.tmax ) || (return nothing)
        ( (u>0.) && (v>0.) && (1-u-v>0.) ) || (return nothing)
        hit_point = at(ray, hit_t)
        return HitRecord(
            hit_point,
            triangle_normal(triangle, ray.dir),
            Vec2d(u,v),
            hit_t,
            ray,
            triangle
        )
    catch Excep
        return nothing
    end
end


"""
    ray_intersection(world::World, ray::Ray) :: Union{HitRecord, Nothing}

Determine whether the `ray` intersects any of the objects of the given `world`.
Return a `HitRecord`, or `nothing` if no intersection is found.

See also: [`Ray`](@ref), [`World`](@ref), [`HitRecord`](@ref)
"""
function ray_intersection(world::World, ray::Ray)
    closest = nothing

    for shape in world.shapes
        intersection = ray_intersection(shape, ray)

        # The ray missed this shape, skip to the next one
        !(isnothing(intersection)) || continue

        # There was a hit, and it was closer than any other hit found before
        ( isnothing(closest) || (intersection.t < closest.t) ) &&  (closest = intersection)
    end
    
    return closest
end

##########################################################################################92

"""
    add_shape!(world::World, shape::Shape)

Append a new `shape` to the given `world`.

See also: [`Shape`](@ref), [`World`](@ref)
"""
function add_shape!(world::World, S::Shape)
    push!(world.shapes, S)
    return nothing
end


"""
    add_light!(world::World, pointlight::PointLight)

Append a new `pointlight` to the given `world`.

See also: [`PointLight`](@ref), [`World`](@ref)
"""
function add_light!(world::World, pointlight::PointLight)
    push!(world.point_lights, pointlight)
    return nothing
end

##########################################################################################92

"""
    quick_ray_intersection(shape::Shape, ray::Ray) :: Bool

Quickly determine whether the `ray` hits the `shape` or not.

See also: [`Shape`](@ref), [`Ray`](@ref)
"""
function quick_ray_intersection(shape::Shape, ray::Ray)
    return ErrorException(
            "quick_ray_intersection is an abstract method"*
            "and cannot be called directlly")
end

"""
    quick_ray_intersection(sphere::Sphere, ray::Ray) :: Bool

Quickly checks if the `ray` intersects the `sphere` or not.

See also: [`Sphere`](@ref), [`Ray`](@ref)
"""
function quick_ray_intersection(sphere::Sphere, ray::Ray)
    inv_ray = inverse(sphere.T) * ray
    origin_vec = Vec(inv_ray.origin)

    a = squared_norm(inv_ray.dir)
    b = 2.0 * origin_vec ⋅ inv_ray.dir
    c = squared_norm(origin_vec) - 1.0
    Δ = b * b - 4.0 * a * c 
     
    (Δ > 0.0) || (return false)

    tmin = (-b - √Δ) / (2.0 * a)
    tmax = (-b + √Δ) / (2.0 * a)

    return ((inv_ray.tmin < tmin < inv_ray.tmax) || (inv_ray.tmin < tmax < inv_ray.tmax))
end

"""
    quick_ray_intersection(plane::Plane, ray::Ray) :: Bool

Quickly checks if the `ray` intersects the `plane` or not.

See also: [`Plane`](@ref), [`Ray`](@ref)
"""
function quick_ray_intersection(plane::Plane, ray::Ray)
    inv_ray = inverse(plane.T) * ray
    !(inv_ray.dir.z ≈ 0.) || (return false)

    t = -inv_ray.origin.z / inv_ray.dir.z
    return (inv_ray.tmin < t < inv_ray.tmax)
end


function quick_ray_intersection(torus::Torus, ray::Ray)

    inv_ray = inverse(torus.T) * ray
    o = Vec(inv_ray.origin)
    d = inv_ray.dir
    norm2_d = squared_norm(d)
    norm2_o =  squared_norm(o)
    scalar_od = o ⋅ d
    r = torus.r
    R = torus.R
    calc = norm2_o - r^2 - R^2

    # coefficienti per calcolo soluzioniintersezione
    c4 = norm2_d^2
    c3 = 4 * norm2_d * scalar_od
    # c2 = 4 * scalar_od^2 + 2 * norm2_d * norm2_o - 4 * R^2 * (norm2_d - d.z^2) + 2 * norm2_d * (R^2 - r^2)
    c2 = 2 * norm2_d * calc + 4 * scalar_od^2 + 4 * R^2 * d.y^2
    # c1 = 4 * norm2_o * scalar_od + 4 * scalar_od * (R^2 - r^2) - 8 * R^2 * (scalar_od - (o.z * d.z))
    c1 = 4 * calc * scalar_od + 8 * R^2 * o.y * d.y
    # c0 = norm2_o^2 + (R^2 - r^2)^2 + 2 * norm2_o * (R^2 - r^2) - 4 * R^2 * (norm2_o - o.z^2)
    c0 = calc^2 - 4 * R^2 * (r^2 - o.y^2)

    # calcolo soluzioni
    t_ints = roots(Polynomial([c0, c1, c2, c3, c4]))

    # verifico esistenza di almeno una soluzione
    (length(t_ints) == 0) && (return nothing)

    hit_ts = Vector{Float64}()

    # controllo che le soluzioni siano reali positive o che la parte immaginaria sia quasi nulla
    for i in t_ints
        if (typeof(i) == ComplexF64) && (abs(i.im) > 1e-8) #1e-8
            continue
        elseif ((typeof(i) == Float64) && (1e-5 < i < inv_ray.tmax)) || ((typeof(i) == ComplexF64) && (abs(i.im) < 1e-8) && (1e-5 < i.re < inv_ray.tmax)) 
            (typeof(i) == Float64) && push!(hit_ts, i)
            continue
            (typeof(i) == ComplexF64) && push!(hit_ts, i.re)
        else
            nothing
        end
    end

    if (length(hit_ts) == 0 )
        return false
    else
        return true
    end
# end
    # (length(hit_ts) == 0 ) ? (return true) : (return false)

end    # quick_ray_intersection


"""
    is_point_visible(
            world::World, 
            point::Point, 
            observer_pos::Point
            ) :: Bool

Return `true` if the straight line connecting `observer_pos` to `point`
do not intersect any of the shapes of `world` between the two points,
otherwise return `false`.

See also: [`World`](@ref), [`Point`](@ref)
"""
function is_point_visible(world::World, point::Point, observer_pos::Point)
    direction = point - observer_pos
    dir_norm = norm(direction)

    ray = Ray(observer_pos, direction, 1e-2 / dir_norm, 1.0)
    for shape in world.shapes
        if (quick_ray_intersection(shape, ray) == true) && (shape.flag_pointlight==false) 
            return false
        end
    end

    return true
end
