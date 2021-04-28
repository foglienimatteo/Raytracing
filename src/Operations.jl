"""Returns true if the difference between two numbers is smaller than 10^{-10}."""
are_close(x, y, epsilon=1e-10) = abs(x-y) < epsilon

Base.:≈(a::RGB{T}, b::RGB{T}) where {T} = are_close(a.r,b.r) && are_close(a.g,b.g) && are_close(a.b, b.b)
Base.:≈(a::Vec, b::Vec) = are_close(a.x, b.x) && are_close(a.y, b.y) && are_close(a.z, b.z)
Base.:≈(a::Normal, b::Normal) = are_close(a.x, b.x) && are_close(a.y, b.y) && are_close(a.z, b.z)
Base.:≈(a::Point, b::Point) = are_close(a.x, b.x) && are_close(a.y, b.y) && are_close(a.z,b.z)
Base.:≈(m1::SMatrix{4,4,Float64}, m2::SMatrix{4,4,Float64}) = (B = [are_close(m,n) for (m,n) in zip(m1,m2)] ; all(i->(i==true) , B) )
Base.:≈(t1::Transformation, t2::Transformation) = (t1.M ≈ t2.M) && ( t1.invM ≈ t2.invM )
Base.:≈(r1::Ray, r2::Ray) = (r1.origin ≈ r2.origin) && (r1.dir ≈ r2.dir)

# Definitions of operations for RGB objects
Base.:+(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r + b.r, a.g + b.g, a.b + b.b)
Base.:-(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r - b.r, a.g - b.g, a.b - b.b)
Base.:*(scalar::Real, c::RGB{T}) where {T} = RGB(scalar*c.r , scalar*c.g, scalar*c.b)
Base.:*(c::RGB{T}, scalar::Real) where {T} = scalar * c
Base.:/(c::RGB{T}, scalar::Real) where {T} = RGB(c.r/scalar , c.g/scalar, c.b/scalar)

# Definitions of operations for Vec
Base.:+(a::Vec, b::Vec) = Vec(a.x+b.x, a.y+b.y, a.z+b.z)
Base.:-(a::Vec, b::Vec) = Vec(a.x-b.x, a.y-b.y, a.z-b.z)
Base.:*(s::Real, a::Vec) = Vec(s*a.x, s*a.y, s*a.z)
Base.:*(a::Vec, s::Real) = Vec(s*a.x, s*a.y, s*a.z)
Base.:/(a::Vec, s::Real) = Vec(a.x/s, a.y/s, a.z/s)
LinearAlgebra.:⋅(a::Vec, b::Vec) = a.x*b.x + a.y*b.y + a.z*b.z
LinearAlgebra.:×(a::Vec, b::Vec) = Vec(a.y*b.z-a.z*b.y, b.x*a.z-a.x*b.z, a.x*b.y-a.y*b.x)

# Definitions of operations between Vec and Point
Base.:+(p::Point, v::Vec) = Point(p.x+v.x, p.y+v.y, p.z+v.z)
# Base.:+(v::Vec, p::Point) = Point(p.x+v.x, p.y+v.y, p.z+v.z)
Base.:-(p::Point, v::Vec) = Point(p.x-v.x, p.y-v.y, p.z-v.z)
Base.:*(s::Real, a::Point) = Point(s*a.x, s*a.y, s*a.z)
Base.:*(a::Point, s::Real) = Point(s*a.x, s*a.y, s*a.z)
Base.:-(a::Point, b::Point) = Vec(b.x-a.x, b.y-a.y, b.z-a.z)

# Definitions of operations for Transformations
Base.:*(s::Transformation, t::Transformation) = Transformation(s.M*t.M, t.invM*s.invM)
function Base.:*(t::Transformation, p::Point)
    q = Point(t.M[1] * p.x + t.M[5] *p.y +t.M[9] *p.z +t.M[13],
              t.M[2] * p.x + t.M[6] *p.y +t.M[10] *p.z +t.M[14],
              t.M[3] * p.x + t.M[7]*p.y +t.M[11]*p.z +t.M[15]
    )
    λ = t.M[4] * p.x + t.M[8]*p.y +t.M[12]*p.z +t.M[16]
    λ == 1.0 ? (return q) : (return q/λ)
end
function Base.:*(t::Transformation, p::Vec)
    Vec(t.M[1] * p.x + t.M[5] * p.y + t.M[9]  * p.z, 
        t.M[2] * p.x + t.M[6] * p.y + t.M[10] * p.z, 
        t.M[3] * p.x + t.M[7] * p.y + t.M[11] * p.z)
end
function Base.:*(t::Transformation, n::Normal)
    Mat = transpose(t.invM)
    l = Normal(Mat[1] * n.x + Mat[5] * n.y + Mat[9]  *n.z,
               Mat[2] * n.x + Mat[6] * n.y + Mat[10] *n.z,
               Mat[3] * n.x + Mat[7] * n.y + Mat[11] *n.z
    )
    return l
end
Base.:*(t::Transformation, r::Ray) = Ray(t * r.origin, t*r.dir, r.tmin, r.tmax, r.depth)
Base.:*(r::Ray, t::Transformation) = t*r