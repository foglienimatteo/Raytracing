# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


@testset "test_Hit" begin
     sphere = Sphere()
     ray1 = Ray(Point(0, 0, 2), -VEC_Z)

     intersection1 = ray_intersection(sphere, ray1)
     @test typeof(intersection1) == HitRecord
     @test HitRecord(
          Point(0.0, 0.0, 1.0), 
          Normal(0.0, 0.0, 1.0), 
          Vec2d(0.0, 0.0), 
          1.0,
          ray1
          ) ≈ intersection1

     ray2 = Ray( Point(3, 0, 0), -VEC_X )
     intersection2 = ray_intersection(sphere, ray2)
     @test typeof(intersection2) == HitRecord
     @test HitRecord(
          Point(1.0, 0.0, 0.0),
          Normal(1.0, 0.0, 0.0),
          Vec2d(0.0, 0.5),
          2.0,
          ray2
          ) ≈ intersection2
          
     @test typeof( ray_intersection(sphere, Ray(Point(0, 10, 2), -VEC_Z ) ) ) == Nothing
end

@testset "test_InnerHit" begin
     sphere = Sphere()

     ray = Ray(Point(0, 0, 0), VEC_X)
     intersection = ray_intersection(sphere, ray)

     @test typeof(intersection) == HitRecord
     @test HitRecord(
          Point(1.0, 0.0, 0.0),
          Normal(-1.0, 0.0, 0.0),
          Vec2d(0.0, 0.5), 
          1.0,
          ray
          ) ≈ intersection
end

@testset "test_Transformation" begin
     sphere = Sphere(translation(Vec(10.0, 0.0, 0.0)))

     ray1 = Ray(Point(10, 0, 2), -VEC_Z)
     intersection1 = ray_intersection(sphere, ray1)
     @test typeof(intersection1) == HitRecord
     @test HitRecord(
          Point(10.0, 0.0, 1.0),
          Normal(0.0, 0.0, 1.0),
          Vec2d(0.0, 0.0),
          1.0,
          ray1
          ) ≈ intersection1

     ray2 = Ray(Point(13, 0, 0), -VEC_X)
     intersection2 = ray_intersection(sphere, ray2)
     @test typeof(intersection2) == HitRecord
     @test HitRecord(
          Point(11.0, 0.0, 0.0),
          Normal(1.0, 0.0, 0.0),
          Vec2d(0.0, 0.5), 
          2.0,
          ray2
          ) ≈ intersection2

     # Check if the sphere failed to move by trying to hit the untransformed shape
     @test typeof( ray_intersection(sphere, Ray( Point(0, 0, 2), -VEC_Z ) ) ) == Nothing
          
     # Check if the *inverse* transformation was wrongly applied
     @test typeof( ray_intersection(sphere, Ray( Point(-10, 0, 0), -VEC_Z ) ) ) == Nothing
end

@testset "test_Normals" begin
     sphere = Sphere(scaling(Vec(2.0, 1.0, 1.0)))
     println(sphere.AABB)
     ray = Ray(Point(1.0, 1.0, 0.0), Vec(-1.0, -1.0, 0.0))
     intersection = ray_intersection(sphere, ray)

     @test intersection.normal ≈ Normal(1.0, 4.0, 0.0)
end

@testset "test_Normal_direction" begin
     # Scaling a sphere by -1 keeps the sphere the same but reverses its
     # reference frame
     sphere = Sphere(scaling(Vec(-1.0, -1.0, -1.0)))

     ray = Ray(Point(0.0, 2.0, 0.0), -VEC_Y)
     intersection = ray_intersection(sphere, ray)

     @test intersection.normal ≈ Normal(0.0, 1.0, 0.0)
end

@testset "test_UV_Coordinates" begin
     sphere = Sphere()

     # The first four rays hit the unit sphere at the
     # points P1, P2, P3, and P4.
     #
     #                    ^ y
     #                    | P2
     #              , - ~ * ~ - ,
     #          , '       |       ' ,
     #        ,           |           ,
     #       ,            |            ,
     #      ,             |             , P1
     # -----*-------------+-------------*---------> x
     #   P3 ,             |             ,
     #       ,            |            ,
     #        ,           |           ,
     #          ,         |        , '
     #            ' - , _ * _ ,  '
     #                    | P4
     #
     # P5 and P6 are aligned along the x axis and are displaced
     # along z (ray5 in the positive direction, ray6 in the negative
     # direction).

     ray1 = Ray(Point(2.0, 0.0, 0.0), -VEC_X)
     @test ray_intersection(sphere, ray1).surface_point ≈ Vec2d(0.0, 0.5)

     ray2 = Ray(Point(0.0, 2.0, 0.0), -VEC_Y)
     @test ray_intersection(sphere, ray2).surface_point ≈ Vec2d(0.25, 0.5)

     ray3 = Ray(Point(-2.0, 0.0, 0.0), VEC_X)
     @test ray_intersection(sphere, ray3).surface_point ≈ Vec2d(0.5, 0.5)
     
     ray4 = Ray(Point(0.0, -2.0, 0.0), VEC_Y)
     @test ray_intersection(sphere, ray4).surface_point ≈ Vec2d(0.75, 0.5)

     ray5 = Ray(Point(2.0, 0.0, 0.5), -VEC_X)
     @test ray_intersection(sphere, ray5).surface_point ≈ Vec2d(0.0, 1/3)

     ray6 = Ray(Point(2.0, 0.0, -0.5), -VEC_X)
     @test ray_intersection(sphere, ray6).surface_point ≈ Vec2d(0.0, 2/3)
end