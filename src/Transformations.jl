"""transformation type, creates two SMatrix{4,4,Float64}, corresponding to rotation around x-axis anticlockwise and clockwise (ϑ[rad]>0)."""
function rotation_x(ϑ::Float64) # ϑ is in radiant
    Transformation(
        [1.0    0.0     0.0     0.0 ;   
         0.0    cos(ϑ)  -sin(ϑ) 0.0 ;
         0.0    sin(ϑ)  cos(ϑ)  0.0 ;
         0.0    0.0     0.0     1.0]
         ,
        [1.0    0.0     0.0     0.0 ;   
         0.0    cos(ϑ)  sin(ϑ)  0.0 ;
         0.0    -sin(ϑ) cos(ϑ)  0.0 ;
         0.0    0.0     0.0     1.0]
    )
end # rotation_x

"""transformation type, creates two SMatrix{4,4,Float64}, corresponding to rotation around y-axis anticlockwise and clockwise (ϑ[rad]>0)."""
function rotation_y(ϑ::Float64) # ϑ is in radiant
    Transformation(
        [cos(ϑ)     0.0     sin(ϑ)  0.0 ;
         0.0        1.0     0.0     0.0 ;
         -sin(ϑ)    0.0     cos(ϑ)  0.0 ;
         0.0        0.0     0.0     1.0  ]
         ,
        [cos(ϑ)     0.0     -sin(ϑ) 0.0 ;
         0.0        1.0     0.0     0.0 ;
         sin(ϑ)     0.0     cos(ϑ)  0.0 ;
         0.0        0.0     0.0     1.0  ]
    )
end # rotation_y

"""transformation type, creates two SMatrix{4,4,Float64}, corresponding to rotation around z-axis anticlockwise and clockwise (ϑ[rad]>0)."""
function rotation_z(ϑ::Float64) # ϑ is in radiant
    Transformation(
        [cos(ϑ) -sin(ϑ) 0.0     0.0 ;
         sin(ϑ) cos(ϑ)  0.0     0.0 ;
         0.0    0.0     1.0     0.0 ;
         0.0    0.0     0.0     1.0]
         ,
        [cos(ϑ)     sin(ϑ)  0.0     0.0 ;
         -sin(ϑ)    cos(ϑ)  0.0     0.0 ;
         0.0        0.0     1.0     0.0 ;
         0.0        0.0     0.0     1.0]
    )
end # rotation_z

function scaling(v::Vec)
    Transformation(
        [v.x    0.0     0.0     0.0 ;
         0.0    v.y     0.0     0.0 ;
         0.0    0.0     v.z     0.0 ;
         0.0    0.0     0.0     1.0]
         ,
        [1/v.x  0.0     0.0     0.0 ;
         0.0    1/v.y   0.0     0.0 ;
         0.0    0.0     1/v.z   0.0 ;
         0.0    0.0     0.0     1.0]
    )
end # scaling

function translation(v::Vec)
   Transformation(
        [1.0    0.0     0.0     v.x ;
         0.0    1.0     0.0     v.y ;
         0.0    0.0     1.0     v.z ;
         0.0    0.0     0.0     1.0]
         ,
        [1.0    0.0     0.0     -v.x ;
         0.0    1.0     0.0     -v.y ;
         0.0    0.0     1.0     -v.z ;
         0.0    0.0     0.0     1.0]
    )
end # translation

function inverse(T::Transformation)
    return Transformation(T.invM, T.M)
end # inverse

"""Returns true if the two matrices of a Transformation type are one the inverse of the other."""
function is_consistent(T::Transformation)
    p = T.M * T.invM
    I = SMatrix{4,4}( Diagonal(ones(4)) )
    return p ≈ I
end # is_consistent