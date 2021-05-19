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


@testset "test_UniformPigment" begin
     color = RGB(1.0, 2.0, 3.0)
     pigment = UniformPigment(color)

     get_color(pigment, Vec2d(0.0, 0.0)) ≈ color
     @test get_color(pigment, Vec2d(1.0, 0.0)) ≈ color
     @test get_color(pigment, Vec2d(0.0, 1.0)) ≈ color
     @test get_color(pigment, Vec2d(1.0, 1.0)) ≈ color
     @test get_color(pigment, Vec2d(0.5, 0.5)) ≈ color
end

@testset "test_ImagePigment" begin
     image = HdrImage(2, 2)
     set_pixel(image, 0, 0, RGB(1.0, 2.0, 3.0))
     set_pixel(image, 1, 0, RGB(2.0, 3.0, 1.0))
     set_pixel(image, 0, 1, RGB(2.0, 1.0, 3.0))
     set_pixel(image, 1, 1, RGB(3.0, 2.0, 1.0))

     pigment = ImagePigment(image)
     @test get_color(pigment, Vec2d(0.0, 0.0)) ≈ RGB(1.0, 2.0, 3.0)
     @test get_color(pigment, Vec2d(1.0, 0.0)) ≈ RGB(2.0, 3.0, 1.0)
     @test get_color(pigment, Vec2d(0.0, 1.0)) ≈ RGB(2.0, 1.0, 3.0)
     @test get_color(pigment, Vec2d(1.0, 1.0)) ≈ RGB(3.0, 2.0, 1.0)
end

@testset "test_CheckeredPigment" begin
     color1 = RGB(1.0, 2.0, 3.0)
     color2 = RGB(10.0, 20.0, 30.0)

     pigment = CheckeredPigment(color1, color2, 2)

     # With num_of_steps == 2, the pattern should be the following:
     #
     #              (0.5, 0)
     #   (0, 0) +------+------+ (1, 0)
     #          |      |      |
     #          | col1 | col2 |
     #          |      |      |
     # (0, 0.5) +------+------+ (1, 0.5)
     #          |      |      |
     #          | col2 | col1 |
     #          |      |      |
     #   (0, 1) +------+------+ (1, 1)
     #              (0.5, 1)
     @test get_color(pigment, Vec2d(0.25, 0.25)) ≈ color1
     @test get_color(pigment, Vec2d(0.75, 0.25)) ≈ color2
     @test get_color(pigment, Vec2d(0.25, 0.75)) ≈ color2
     @test get_color(pigment, Vec2d(0.75, 0.75)) ≈ color1
end