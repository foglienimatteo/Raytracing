# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

export my_function  # remember to export the functions you want to use!

# Let's define a function that will be used in the "tutorial_basic_sintax.txt" file
# NOTE: DO NOT MODIFY THIS FUNCTION: IT?S USED FOR TESTS!
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

function earth_moon_sun(x, P_rev_moon=200, P_rot_earth=50, d=3.0, v=1.0)
     moon_x = d * cos(2 * π * x/P_rev_moon)
     moon_y =  d * sin(2 * π * x/P_rev_moon)
     moon_z =  v * cos(2 * π * x/P_rev_moon) * 0.0
     moon_rotang = 2 * π * x/P_rev_moon
     earth_rotang = 2 * π * x/P_rot_earth
     return (moon_x, moon_y, moon_z, moon_rotang, earth_rotang)
end

##########################################################################################################

function torus_and_sphere(t, P_rev_torus = 300, P_rot_torus = 100, P_oscill_sphere = 50, P_rot_sphere = 38, A = 0.5)
     first_torus_rot_Z = 2 * π * t/P_rot_torus
     second_torus_rot_Z = 2 * π * t/P_rev_torus
     first_sphere_trasl = A * cos(2 * π * t/P_oscill_sphere)
     first_sphere_rot = 2 * π * t/P_rot_sphere
     return (first_torus_rot_Z, second_torus_rot_Z, first_sphere_trasl, first_sphere_rot)
end