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


@testset "test_Vec2D" begin
     v1 = Vec2d(5.2 + 1e-11, 6.3)
     v2 = Vec2d(5.2, 6.3 - (2*1e-11))
     @test v1 ≈ v2
end

@testset "test_World" begin
     w = World()
	sph1 = Sphere(translation(VEC_X * 2))
	sph2 = Sphere(translation(VEC_X * 8))
	add_shape(w, sph1)
	add_shape(w, sph2)

	intersection1 = ray_intersection(w, Ray(Point(0.0, 0.0, 0.0), VEC_X))
	@test intersection1.world_point ≈ Point(1., 0., 0.)

	intersection2 = ray_intersection(w, Ray(Point(10.0, 0.0, 0.0), -VEC_X))
	@test intersection2.world_point ≈ Point(9., 0., 0.)
end

