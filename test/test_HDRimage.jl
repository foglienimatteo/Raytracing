# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


rgb_matrix = fill(RGB(0., 0., 0.0), (6,))
img_1 = Raytracing.HDRimage(3, 2, rgb_matrix)
img_2 = Raytracing.HDRimage(3, 2)

@test img_1.width == 3
@test img_1.height == 2
@test img_1.rgb_m == img_2.rgb_m

# Controllo della scrittura errata nell'assert
@test_throws AssertionError img = Raytracing.HDRimage(3, 3, rgb_matrix)
@test_throws AssertionError img = Raytracing.HDRimage(1, 3, rgb_matrix)
