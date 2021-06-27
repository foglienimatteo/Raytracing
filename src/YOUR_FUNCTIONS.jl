# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

export my_function  # remember to export the functions you want to use!

# Let's define a function that will be used in the "tutorial_basic_sintax.txt" file
function my_function(x::Float64)
     return x+1.0
end

#    PAY ATTENTION: ALL THE NUMBERS DEFINED IN THE SCENEFILE ARE PARSED *ALWAYS*
#    ARE PARSED *ALWAYS* AS FLOAT64.
#
#    => DO NOT DEFINE FUNCTIONS THAT TAKE AS ARGUMENTS INTEGER VALUES,
#         THEY WILL NEVER BE USED!!!


function func(x::T) where {T<:Real}
     return (x, 0.5)
end

function earth_moon_sun(x::T) where {T<:Real}
     dist = 2.0
     period = 20
     moon_x = dist * cos(2 * π * x/period)
     moon_y =  dist * sin(2 * π * x/period)
     moon_z =  0.5*cos(2 * π * x/period)
     moon_rotang = 0.0
     earth_rotang = 0.0
     return (moon_x, moon_y, moon_z, moon_rotang, earth_rotang)
end

