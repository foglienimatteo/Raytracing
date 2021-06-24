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


function func(x::Real, y::Real)
     return (x/2, y/2)
end

