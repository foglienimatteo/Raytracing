# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



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

