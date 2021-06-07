# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

"""
    rotation_x(ϑ::Float64) :: Transformation

Encoding a rotation around the x-axis of an angle `ϑ` _**in radiant**_. 

The positive sign is given by the right-hand rule, therefore clockwise
rotation for entering x-axis corresponds to a `ϑ>0` rotation angle. 

See also: [`Transformation`](@ref)
"""
function rotation_x(ϑ::Float64)
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
end

"""
    rotation_y(ϑ::Float64) :: Transformation

Encoding a rotation around the y-axis of an angle `ϑ` _**in radiant**_. 

The positive sign is given by the right-hand rule, therefore clockwise
rotation for entering y-axis corresponds to a `ϑ>0` rotation angle. 

See also: [`Transformation`](@ref)
"""
function rotation_y(ϑ::Float64)
    Transformation(
        [cos(ϑ)     0.0     sin(ϑ)  0.0 ;
         0.0        1.      0.0     0.0 ;
         -sin(ϑ)    0.0     cos(ϑ)  0.0 ;
         0.0        0.0     0.0     1.  ]
         ,
        [cos(ϑ)     0.0     -sin(ϑ) 0.0 ;
         0.0        1.      0.0     0.0 ;
         sin(ϑ)     0.0     cos(ϑ)  0.0 ;
         0.0        0.0     0.0     1.  ]
    )
end 

"""
    rotation_z(ϑ::Float64) :: Transformation

Encoding a rotation around the z-axis of an angle `ϑ` _**in radiant**_. 

The positive sign is given by the right-hand rule, therefore clockwise
rotation for entering z-axis corresponds to a `ϑ>0` rotation angle. 

See also: [`Transformation`](@ref)
"""
function rotation_z(ϑ::Float64)
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
end 

##########################################################################################92

"""
    scaling(v::Vec) :: Transformation

Encoding a scaling of the 3 spatial coordinates according to the
vector `v` (negative values codify spatial reflections). 

Each component of  `v` must be different from zero.

See also: [`Transformation`](@ref)
"""
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
end 

##########################################################################################92

"""
    translation(v::Vec) :: Transformation

Encoding a rigid translation of the 3 spatial coordinates according to the
vector `v`, which specifies the amount of shift to be applied along the three axes.

See also: [`Transformation`](@ref)
"""    
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
end 

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
