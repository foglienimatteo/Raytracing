# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



@testset "test_Hit" begin
     AABB = Raytracing.AABB()

     @test ray_intersection(AABB, Ray(Point(0.0, 0.0, 0.0), VEC_X))
     @test ray_intersection(AABB, Ray(Point(0.0, 2.0, 0.0), -VEC_Y))
     @test ray_intersection(AABB, Ray(Point(0.0, 0.0, -1.5), VEC_Z ))
end

@testset "test_noHit" begin
     AABB = Raytracing.AABB()

     @test !ray_intersection(AABB, Ray(Point(0.0, 0.0, 2.0), VEC_X))
     @test !ray_intersection(AABB, Ray(Point(0.0, -2.0, 0.0), -VEC_Y))
     @test !ray_intersection(AABB, Ray(Point(0.0, 0.0, 1.5), VEC_Z ))
end

#=
@testset "test_Transformation" begin
     cube1 = Cube( rotation_z(π/2.0) * translation(Vec(3.5, 0.0, 0.0)))

     ray1 = Ray(Point(0, 1, 0), VEC_Y)
     intersection1 = ray_intersection(cube1, ray1)
     @test typeof(intersection1) == HitRecord
     @test HitRecord(
          Point(0.0, 3.0, 0.0),
          Normal(0.0, -1.0, 0.0),
          Vec2d(0.5, 0.5),
          2.0,
          ray1
          ) ≈ intersection1

     cube2 = Cube(translation(Vec(0., 0., 1.5))*rotation_x(π/2.0))
     ray2 = Ray(Point(0.0, 0.0, 0.0), Vec(0., 0., 1.))
     intersection2 = ray_intersection(cube2, ray2)
     @test HitRecord(
          Point(0., 0., 1.),
          Normal(0.0, 0., -1.0),
          Vec2d(0.5, 0.5),
          1.0,
          ray2
          ) ≈ intersection2

     # Check if the plane failed to move by trying to hit the untransformed shape
     @test isnothing( ray_intersection(cube1, Ray( Point(0, 0, 0), -VEC_Z ) ) )
end

@testset "test_Normals" begin
     cube = Cube()

     P = Point(0, 0, 0.6)
     Q = Point(0.6, 0, 0)
     ray1 = Ray(P, Q-P)
     intersection1 = ray_intersection(cube, ray1)
     @test intersection1.normal ≈ Normal(0.0, 0.0, 1.0)

     ray2 = Ray(Point(-1.0, 0.0, 0.0), Vec(3.0, 0.25, 0.25))
     intersection2 = ray_intersection(cube, ray2)
     @test intersection2.normal ≈ Normal(-1.0, 0.0, 0.0)
end

@testset "test_UV_Coordinates" begin
     cube = Cube(translation(0.0, 0.5, 0.5))

     ray1 = Ray(Point(-1.0, 0.25, 0.5), VEC_X)
     @test ray_intersection(cube, ray1).surface_point ≈ Vec2d(0.25, 0.5)

     ray2 = Ray(Point(-1.0, 0.25, 0.75), VEC_X)
     @test ray_intersection(cube, ray2).surface_point ≈ Vec2d(0.25, 0.75)

     ray3 = Ray(Point(0.25, 0.75, 0.25), -VEC_X)
     @test ray_intersection(cube, ray3).surface_point ≈ Vec2d(0.75, 0.25)
end
=###############################
