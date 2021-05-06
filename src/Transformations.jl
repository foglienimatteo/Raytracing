# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

##########################################################################################92

"""
    rotation_x(ϑ::Float64) -> Transformation

    Return a `Transformation` object encoding a rotation around the x-axis; 
    the parameter `ϑ` specifies the rotation angle _**in radiant**_. 

    The positive sign is given by the right-hand rule, therefore clockwise
    rotation for entering x-axis corresponds to a `ϑ>0` rotation angle. 
"""
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

##########################################################################################92

"""
    rotation_y(ϑ::Float64) -> Transformation

    Return a `Transformation` object encoding a rotation around the y-axis; 
    the parameter `ϑ` specifies the rotation angle _**in radiant**_. 

    The positive sign is given by the right-hand rule, therefore clockwise
    rotation for entering y-axis corresponds to a `ϑ>0` rotation angle. 
"""
function rotation_y(ϑ::Float64) # ϑ is in radiant
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
end # rotation_y

##########################################################################################92

"""
    rotation_z(ϑ::Float64) -> Transformation

    Return a `Transformation` object encoding a rotation around the z-axis; 
    the parameter `ϑ` specifies the rotation angle _**in radiant**_. 

    The positive sign is given by the right-hand rule, therefore clockwise
    rotation for entering z-axis corresponds to a `ϑ>0` rotation angle. 
"""
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

##########################################################################################92

"""
    scaling(v::Vec)
    
    Check the internal consistency of the transformation.
    This method is useful when writing tests.
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
end # scaling

##########################################################################################92

"""
    translation(v::Vec) -> Transformation

    Return a `Transformation` object encoding a rigid translation.
    The parameter `Vec` specifies the amount of shift to be applied along the three axes.
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
end # translation

##########################################################################################92

"""
    inverse(T::Transformation) -> Transformation

    Return a `Transformation` object representing the inverse affine transformation.
    This method is very cheap to call.
"""
function inverse(T::Transformation)
    return Transformation(T.invM, T.M)
end # inverse

##########################################################################################92

"""
    is_consistent(T::Transformation) -> Bool

    Check the internal consistency of the transformation, returning a bool variable indicating
    whether `T.M==T.invM`.
    This method is useful when writing tests.
"""
function is_consistent(T::Transformation)
    p = T.M * T.invM
    I = SMatrix{4,4}( Diagonal(ones(4)) )
    return p ≈ I
end # is_consistent
