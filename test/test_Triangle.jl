# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


@testset "test_Hit" begin
     triangle = Triangle()
     ray1 = Ray(Point(0.0, 0.0, 2), -VEC_Z)

     intersection1 = ray_intersection(plane, ray1)
     @test typeof(intersection1) == HitRecord
     @test HitRecord(
          Point(0.0, 0.0, 0.0), 
          Normal(0.0, 0.0, 1.0), 
          Vec2d(0.0, 0.0), 
          2.0,
          ray1
          ) ≈ intersection1

     ray2 = Ray( Point(3.0, 2.0, -2), VEC_Z )
     intersection2 = ray_intersection(plane, ray2)
     @test typeof(intersection2) == HitRecord
     @test HitRecord(
          Point(3.0, 2.0, 0.0),
          Normal(0.0, 0.0, -1.0),
          Vec2d(0., 0.),
          2.0,
          ray2
          ) ≈ intersection2

     P = Point(0., 5., 2.)
     Q = Point(6., 5., 0)
     ray3 = Ray( P, Q-P )
     intersection3 = ray_intersection(plane, ray3)
     @test typeof(intersection3) == HitRecord
     @test HitRecord(
          Q,
          Normal(0.0, 0.0, 1.0),
          Vec2d(0., 0.),
          1.0,
          ray3
          ) ≈ intersection3
end

@testset "test_noHit" begin
     plane = Plane()

     ray1 = Ray(Point(0, 0, 1), VEC_X)
     intersection1 = ray_intersection(plane, ray1)
     @test isnothing(intersection1)

     ray2 = Ray(Point(3, 2, -1), VEC_X+VEC_Y)
     intersection2 = ray_intersection(plane, ray2)
     @test isnothing(intersection2)

     ray3 = Ray(Point(0, 0, -1), -VEC_Z-VEC_Y)
     intersection3 = ray_intersection(plane, ray3)
     @test isnothing(intersection3)
end

@testset "test_Transformation" begin
     plane = Plane(translation(Vec(0.0, 0.0, 3.0)))

     ray1 = Ray(Point(0, 0, 5), -VEC_Z)
     intersection1 = ray_intersection(plane, ray1)
     @test typeof(intersection1) == HitRecord
     @test HitRecord(
          Point(0.0, 0.0, 3.0),
          Normal(0.0, 0.0, 1.0),
          Vec2d(0.0, 0.0),
          2.0,
          ray1
          ) ≈ intersection1

     ray2 = Ray(Point(3.0, 2.0, 0.), VEC_Z)
     intersection2 = ray_intersection(plane, ray2)
     @test typeof(intersection2) == HitRecord
     @test HitRecord(
          Point(3.0, 2.0, 3.0),
          Normal(0.0, 0.0, -1.0),
          Vec2d(0.0, 0.0),
          3.0,
          ray2
          ) ≈ intersection2

     plane3 = Plane(translation(Vec(0., 1., 0.))*rotation_x(π/4))
     ray3 = Ray(Point(0.0, 0.0, √2), Vec(0., 1., 0.))
     intersection3 = ray_intersection(plane3, ray3)
     @test HitRecord(
          Point(0., 1+√2, √2),
          Normal(0.0, -1.0, 1.0),
          Vec2d(0.0, 0.0),
          1+√2,
          ray3
          ) ≈ intersection3

     # Check if the plane failed to move by trying to hit the untransformed shape
     @test isnothing( ray_intersection(plane, Ray( Point(0, 0, 2), -VEC_Z ) ) )
end

@testset "test_Normals" begin
     plane1 = Plane(rotation_y(-π/4))
     P = Point(0, 0, 1)
     Q = Point(1, 0, 0)
     ray1 = Ray(P, Q-P)
     intersection1 = ray_intersection(plane1, ray1)

     @test intersection1.normal ≈ Normal(-1.0, 0.0, 1.0)

     plane2 = Plane(rotation_y(π/2))
     ray2 = Ray(Point(-1.0, 0.0, 0.0), Vec(1., 0., 0.))
     intersection2 = ray_intersection(plane2, ray2)
     @test intersection2.normal ≈ Normal(-1.0, 0.0, 0.0)
end

@testset "test_Normal_direction" begin
     # Scaling a plane by -1 keeps the plane the same but reverses its
     # reference frame
     plane = Plane(scaling(Vec(-1.0, -1.0, -1.0)))

     ray = Ray(Point(0.0, 0.0, 2.0), -VEC_Z)
     intersection = ray_intersection(plane, ray)

     @test intersection.normal ≈ Normal(0.0, 0.0, 1.0)
end

@testset "test_UV_Coordinates" begin
     plane = Plane()

     ray1 = Ray(Point(0.0, 0.0, 1.0), -VEC_Z)
     @test ray_intersection(plane, ray1).surface_point ≈ Vec2d(0.0, 0.0)

     ray2 = Ray(Point(0.5, 0.25, 1.0), -VEC_Z)
     @test ray_intersection(plane, ray2).surface_point ≈ Vec2d(0.5, 0.25)

     ray3 = Ray(Point(-2.25, 1.6, -1.0), VEC_Z)
     @test ray_intersection(plane, ray3).surface_point ≈ Vec2d(0.75, 0.6)
end