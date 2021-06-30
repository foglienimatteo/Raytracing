# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

"""
    rotation_x(ϑ::Float32) :: Transformation

Encoding a rotation around the x-axis of an angle `ϑ` _**in radiant**_. 

The positive sign is given by the right-hand rule, therefore clockwise
rotation for entering x-axis corresponds to a `ϑ>0` rotation angle. 

See also: [`Transformation`](@ref)
"""
function rotation_x(ϑ::Float32)
    Transformation(
        [1.0f0    0.0f0     0.0f0     0.0f0 ;   
         0.0f0    cos(ϑ)  -sin(ϑ) 0.0f0 ;
         0.0f0    sin(ϑ)  cos(ϑ)  0.0f0 ;
         0.0f0    0.0f0     0.0f0     1.0f0]
         ,
        [1.0f0    0.0f0     0.0f0     0.0f0 ;   
         0.0f0    cos(ϑ)  sin(ϑ)  0.0f0 ;
         0.0f0    -sin(ϑ) cos(ϑ)  0.0f0 ;
         0.0f0    0.0f0     0.0f0     1.0f0]
    )
end

"""
    rotation_y(ϑ::Float32) :: Transformation

Encoding a rotation around the y-axis of an angle `ϑ` _**in radiant**_. 

The positive sign is given by the right-hand rule, therefore clockwise
rotation for entering y-axis corresponds to a `ϑ>0` rotation angle. 

See also: [`Transformation`](@ref)
"""
function rotation_y(ϑ::Float32)
    Transformation(
        [cos(ϑ)     0.0f0     sin(ϑ)  0.0f0 ;
         0.0f0        1.0f0      0.0f0     0.0f0 ;
         -sin(ϑ)    0.0f0     cos(ϑ)  0.0f0 ;
         0.0f0        0.0f0     0.0f0     1.0f0  ]
         ,
        [cos(ϑ)     0.0f0     -sin(ϑ) 0.0f0 ;
         0.0f0        1.0f0      0.0f0     0.0f0 ;
         sin(ϑ)     0.0f0     cos(ϑ)  0.0f0 ;
         0.0f0        0.0f0     0.0f0     1.0f0  ]
    )
end 

"""
    rotation_z(ϑ::Float32) :: Transformation

Encoding a rotation around the z-axis of an angle `ϑ` _**in radiant**_. 

The positive sign is given by the right-hand rule, therefore clockwise
rotation for entering z-axis corresponds to a `ϑ>0` rotation angle. 

See also: [`Transformation`](@ref)
"""
function rotation_z(ϑ::Float32)
    Transformation(
        [cos(ϑ) -sin(ϑ) 0.0     0.0 ;
         sin(ϑ) cos(ϑ)  0.0     0.0 ;
         0.0    0.0     1.0     0.0 ;
         0.0    0.0     0.0     1.0]
         ,
        [cos(ϑ)     sin(ϑ)  0.0f0     0.0f0 ;
         -sin(ϑ)    cos(ϑ)  0.0f0     0.0f0 ;
         0.0f0        0.0f0     1.0f0     0.0f0 ;
         0.0f0        0.0f0     0.0f0     1.0f0]
    )
end 

##########################################################################################92

function scaling(v::Vec)
    Transformation(
        [v.v[1]    0.0     0.0     0.0 ;
         0.0f0    v.v[2]     0.0     0.0 ;
         0.0f0    0.0     v.v[3]     0.0 ;
         0.0f0    0.0     0.0     1.0]
         ,
        [1/v.v[1]  0.0f0     0.0f0     0.0f0 ;
         0.0f0    1/v.v[2]   0.0f0     0.0f0 ;
         0.0f0    0.0f0     1/v.v[3]   0.0f0 ;
         0.0f0    0.0f0    0.0f0     1.0f0]
    )
end 

scaling(x::Float32, y::Float32, z::Float32) = scaling(Vec(x,y,z))


"""
    scaling(v::Vec) :: Transformation
    scaling(x::Float32, y::Float64, z::Float64) = scaling(Vec(x,y,z))

Encoding a scaling of the 3 spatial coordinates according to the
vector `v` (negative values codify spatial reflections). 

Each component of  `v` must be different from zero.

See also: [`Transformation`](@ref)
"""
scaling

##########################################################################################92


function translation(v::Vec)
   Transformation(
        [1.0f0    0.0f0     0.0f0     v.v[1] ;
         0.0f0    1.0f0     0.0f0     v.v[2] ;
         0.0f0    0.0f0     1.0f0     v.v[3] ;
         0.0f0    0.0f0     0.0f0     1.0f0]
         ,
        [1.0f0    0.0f0     0.0f0     -v.v[1] ;
         0.0f0    1.0f0     0.0f0     -v.v[2] ;
         0.0f0    0.0f0     1.0f0     -v.v[3] ;
         0.0f0    0.0f0     0.0f0     1.0f0]
    )
end 

translation(x::Float32, y::Float32, z::Float32) = translation(Vec(x,y,z))

"""
    translation(v::Vec) :: Transformation
    translation(x::Float64, y::Float64, z::Float64) = translation(Vec(x,y,z))

Encoding a rigid translation of the 3 spatial coordinates according to the
vector `v`, which specifies the amount of shift to be applied along the three axes.

See also: [`Transformation`](@ref)
"""
translation

##########################################################################################92

"""
    inverse(T::Transformation) :: Transformation

Return the inverse affine transformation of `T`.
This method is very cheap to call.

See also: [`Transformation`](@ref)
"""
function inverse(T::Transformation)
    return Transformation(T.invM, T.M)
end 

"""
    is_consistent(T::Transformation) :: Bool

Check the internal consistency of the  input transformation, 
returning a bool variable indicating whether `T.M==T.invM`.
This method is useful when writing tests.

See also: [`Transformation`](@ref)
"""
function is_consistent(T::Transformation)
    p = T.M * T.invM
    I = SMatrix{4,4}( Diagonal(ones(4)) )
    return p ≈ I
end
