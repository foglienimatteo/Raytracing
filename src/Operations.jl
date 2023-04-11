# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


##########################################################################################92

"""
    are_close(x, y, ε=1e-10) :: Bool

Returns `true` if the absolute difference between 
`x` and `y` is smaller than ε.
"""
are_close(x, y, ε=1e-10) = abs(x-y) < ε

function Base.:≈(a::RGB{T}, b::RGB{T}) where {T}
    are_close(a.r,b.r) && are_close(a.g,b.g) && are_close(a.b, b.b)
end
function Base.:≈(a::Array{RGB{T1}}, b::Array{RGB{T2}}) where {T1,T2}
    for (i,j) in zip(a, b); (i≈j) || (return false); end
    return true
end
function Base.:≈(a::HDRimage, b::HDRimage)
    (a.height == b.height) || return false
    (a.width == b.width) || return false
    return (a.rgb_m ≈ b.rgb_m)
end
Base.:≈(a::Vec, b::Vec) = are_close(a.x, b.x) && are_close(a.y, b.y) && are_close(a.z, b.z)
Base.:≈(a::Normal, b::Normal) = are_close(a.x, b.x) && are_close(a.y, b.y) && are_close(a.z, b.z)
Base.:≈(a::Point, b::Point) = are_close(a.x, b.x) && are_close(a.y, b.y) && are_close(a.z, b.z)
Base.:≈(m1::SMatrix{4,4,Float64}, m2::SMatrix{4,4,Float64}) = (B = [are_close(m,n) for (m,n) in zip(m1,m2)] ; all(i->(i==true) , B) )
Base.:≈(t1::Transformation, t2::Transformation) = (t1.M ≈ t2.M) && ( t1.invM ≈ t2.invM )
Base.:≈(r1::Ray, r2::Ray) = (r1.origin ≈ r2.origin) && (r1.dir ≈ r2.dir)
Base.:≈(v1::Vec2d, v2::Vec2d) = (are_close(v1.u, v2.u)) && (are_close(v1.v, v2.v))
Base.:≈(H1::HitRecord, H2::HitRecord) = (H1.normal ≈ H2.normal) && (H1.ray ≈ H2.ray) && (H1.surface_point ≈ H2.surface_point)&& (are_close(H1.t, H2.t)) && (H1.world_point ≈ H2.world_point)

# Operations for RGB objects
Base.:+(a::RGB{T}, b::RGB{T}) where {T} = RGB{T}(a.r + b.r, a.g + b.g, a.b + b.b)
Base.:-(a::RGB{T}, b::RGB{T}) where {T} = RGB{T}(a.r - b.r, a.g - b.g, a.b - b.b)
Base.:*(scalar::Real, c::RGB{T}) where {T} = RGB{T}(scalar*c.r , scalar*c.g, scalar*c.b)
Base.:*(a::RGB{T}, b::RGB{T}) where {T} = RGB{T}(a.r*b.r, a.g*b.g, a.b*b.b)
Base.:*(c::RGB{T}, scalar::Real) where {T} = scalar * c
Base.:/(c::RGB{T}, scalar::Real) where {T} = RGB{T}(c.r/scalar , c.g/scalar, c.b/scalar)

# Operations for Point
Base.:*(s::Real, a::Point) = Point(s*a.x, s*a.y, s*a.z)
Base.:*(a::Point, s::Real) = Point(s*a.x, s*a.y, s*a.z)
Base.:/(a::Point, s::Real) = Point(a.x/s, a.y/s, a.z/s)

# Operations for Vec
Base.:+(a::Vec, b::Vec) = Vec(a.x+b.x, a.y+b.y, a.z+b.z)
Base.:-(a::Vec, b::Vec) = Vec(a.x-b.x, a.y-b.y, a.z-b.z)
Base.:-(a::Vec) = Vec(-a.x, -a.y, -a.z)
Base.:*(s::Real, a::Vec) = Vec(s*a.x, s*a.y, s*a.z)
Base.:*(a::Vec, s::Real) = Vec(s*a.x, s*a.y, s*a.z)
Base.:/(a::Vec, s::Real) = Vec(a.x/s, a.y/s, a.z/s)
LinearAlgebra.:⋅(a::Vec, b::Vec) = a.x*b.x + a.y*b.y + a.z*b.z
LinearAlgebra.:×(a::Vec, b::Vec) = Vec(a.y*b.z-a.z*b.y, b.x*a.z-a.x*b.z, a.x*b.y-a.y*b.x)

# Operations for Normal
Base.:-(a::Normal) = Normal(-a.x, -a.y, -a.z)
Base.:*(a::Normal, b::Real) = Vec(b*a.x, b*a.y, b*a.z)
Base.:*(b::Real, a::Normal) = Vec(b*a.x, b*a.y, b*a.z)
LinearAlgebra.:⋅(a::Normal, b::Normal) = a.x*b.x + a.y*b.y + a.z*b.z
LinearAlgebra.:⋅(a::Normal, b::Vec) = a.x*b.x + a.y*b.y + a.z*b.z
LinearAlgebra.:⋅(a::Vec, b::Normal) = a.x*b.x + a.y*b.y + a.z*b.z
LinearAlgebra.:×(a::Normal, b::Normal) = Vec(a.y*b.z-a.z*b.y, b.x*a.z-a.x*b.z, a.x*b.y-a.y*b.x)
LinearAlgebra.:×(a::Normal, b::Vec) = Vec(a.y*b.z-a.z*b.y, b.x*a.z-a.x*b.z, a.x*b.y-a.y*b.x)
LinearAlgebra.:×(a::Vec, b::Normal) = Vec(a.y*b.z-a.z*b.y, b.x*a.z-a.x*b.z, a.x*b.y-a.y*b.x)

# Operations between Vec and Point
Base.:+(p::Point, v::Vec) = Point(p.x+v.x, p.y+v.y, p.z+v.z)
Base.:+(v::Vec, p::Point) = Point(p.x+v.x, p.y+v.y, p.z+v.z)
Base.:-(p::Point, v::Vec) = Point(p.x-v.x, p.y-v.y, p.z-v.z)
Base.:-(a::Point, b::Point) = Vec(a.x-b.x, a.y-b.y, a.z-b.z)

# Operations for Vec2d
Base.:+(a::Vec2d, b::Vec2d) = Vec2d(a.u+b.u - floor(a.u+b.u), a.v+b.v- floor(a.v+b.v))
Base.:-(a::Vec2d, b::Vec2d) = Vec2d(a.u-b.u- floor(a.u+b.u), a.v-b.v- floor(a.v+b.v))
Base.:-(a::Vec2d) = Vec2d(-a.x, -a.y, -a.z)
Base.:*(s::Real, a::Vec2d) = Vec2d(s*a.u - floor(s*a.u), s*a.v- floor(s*a.v))
Base.:*(a::Vec2d, s::Real) = Vec2d(s*a.u- floor(s*a.u), s*a.v- floor(s*a.v))
Base.:/(a::Vec2d, s::Real) = Vec2d(a.u/s- floor(a.u/s), a.v/s- floor(a.v/s))

#=
"""
Apply the dot product to the two arguments after having normalized them.
The result is the cosine of the angle between the two vectors/normals.
"""
function normalized_dot(v1::Union{Vec,Normal}, v2::Union{Vec,Normal}) 
    v1_vec = normalize(Vec(v1.x, v1.y, v1.z))
    v2_vec = normalize(Vec(v2.x, v2.y, v2.z))
    return v1_vec ⋅ v2_vec
end
=#

# Operations for Transformations
Base.:*(s::Transformation, t::Transformation) = Transformation(s.M*t.M, t.invM*s.invM)
function Base.:*(t::Transformation, p::Point)
    PV = SVector{4, Float64}(p.x, p.y, p.z, 1)
    res = t.M*PV
    #(res[end] == 1) || (res /= res[end])
    res /= res[4]
    Point(res)

    #= metodo 2
        @inbounds q =  Point(t.M[1] * p.x + t.M[5] * p.y + t.M[9] * p.z +t.M[13],
                    t.M[2] * p.x + t.M[6] * p.y + t.M[10] * p.z +t.M[14],
                    t.M[3] * p.x + t.M[7] * p.y + t.M[11] * p.z +t.M[15]
                    )   
        @inbounds λ = t.M[4] * p.x + t.M[8] * p.y + t.M[12] * p.z + t.M[16]
        λ == 1.0 ? (return q) : (return q/λ)
        =#
        #= metodo 1
        q =  Point(t.M[1] * p.x + t.M[5] * p.y + t.M[9] * p.z +t.M[13],
                        t.M[2] * p.x + t.M[6] * p.y + t.M[10] * p.z +t.M[14],
                        t.M[3] * p.x + t.M[7] * p.y + t.M[11] * p.z +t.M[15]
                        ) 
        λ = t.M[4] * p.x + t.M[8] * p.y + t.M[12] * p.z + t.M[16]
        λ == 1.0 ? (return q) : (return q/λ)
    =#
end
function Base.:*(t::Transformation, p::Vec)
    VV = SVector{4, Float64}(p.x, p.y, p.z, 0)
    res = t.M*VV
    Vec(res)
    #=
        Vec(t.M[1] * p.x + t.M[5] * p.y + t.M[9]  * p.z, 
            t.M[2] * p.x + t.M[6] * p.y + t.M[10] * p.z, 
            t.M[3] * p.x + t.M[7] * p.y + t.M[11] * p.z)
    =#
end
function Base.:*(t::Transformation, n::Normal)
    NV = SVector{4, Float64}(n.x, n.y, n.z, 0)
    Normal(transpose(t.invM)*NV)
    #Normal(transpose(@view(t.invM[1:3,1:3])) * NV)
    #=
        Mat = transpose(t.invM)
        l = Normal(Mat[1] * n.x + Mat[5] * n.y + Mat[9]  *n.z,
                    Mat[2] * n.x + Mat[6] * n.y + Mat[10] *n.z,
                    Mat[3] * n.x + Mat[7] * n.y + Mat[11] *n.z
        )
        return l
    =#
end
Base.:*(t::Transformation, r::Ray) = Ray(t * r.origin, t*r.dir, r.tmin, r.tmax, r.depth)
Base.:*(r::Ray, t::Transformation) = t*r


# Useful normalize functions
squared_norm(v::Union{Vec,Point, Normal}) = v.x^2 + v.y^2 + v.z^2
norm(v::Union{Vec,Point,Normal}) = √squared_norm(v)
normalize(v::Union{Vec, Normal}) = v/norm(v)
