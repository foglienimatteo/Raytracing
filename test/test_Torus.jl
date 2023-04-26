# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

using Raytracing, Raytracing.Interpreter
using Test, LinearAlgebra, StaticArrays
import ColorTypes:RGB

@testset "test_Hit" begin
    torus = Torus()
    ray1 = Ray(Point(0, 0, 10), -VEC_Z)
    ray2 = Ray(Point(0, 0, 0), VEC_X)
    ray3 = Ray(Point(0., 10., 0.), -VEC_Y)
    ray4 = Ray(Point(3., 0, -8), VEC_Z)
    ray5 = Ray(Point(3, 1., -8), VEC_Z)

    intersection1 = ray_intersection(torus, ray1)
    intersection2 = ray_intersection(torus, ray2)
    intersection3 = ray_intersection(torus, ray3)
    intersection4 = ray_intersection(torus, ray4)
    intersection5 = ray_intersection(torus, ray5)

    @test typeof(intersection1) == Nothing
    @test typeof(intersection2) == HitRecord
    @test typeof(intersection3) == HitRecord
    @test typeof(intersection4) == HitRecord
    @test typeof(intersection5) == HitRecord

    @test HitRecord(
         Point(2.0, 0.0, 0.0),
         Normal(-1.0, 0.0, 0.0),
         Vec2d(0.5, 0.0), 
         2.0,
         ray2
         ) ≈ intersection2
    
    @test HitRecord(
        Point(0.0, 4.0, 0.0),
        Normal(0.0, 1.0, 0.0),
        Vec2d(0.0, 0.25), 
        6.0,
        ray3
        ) ≈ intersection3
    
    @test HitRecord(
        Point(3.0, 0.0, -1),
        Normal(0.0, 0.0, -1.0),
        Vec2d(0.75, 0.0), 
        7.0,
        ray4
        ) ≈ intersection4

end

@testset "test_InnerHit" begin
    torus = Torus()

    ray = Ray(Point(3, 0, 0), VEC_X)
    intersection = ray_intersection(torus, ray)

    @test typeof(intersection) == HitRecord
    @test HitRecord(
         Point(4.0, 0.0, 0.0),
         Normal(-1.0, 0.0, 0.0),
         Vec2d(0.0, 0.0), 
         1.0,
         ray
         ) ≈ intersection
end

@testset "test_Transformation" begin
    torus = Torus(translation(Vec(10.0, 0.0, 0.0)))

    ray1 = Ray(Point(13, 0, 2), -VEC_Z)
    intersection1 = ray_intersection(torus, ray1)
    @test typeof(intersection1) == HitRecord
    @test HitRecord(
         Point(13.0, 0.0, 1.0),
         Normal(0.0, 0.0, 1.0),
         Vec2d(0.25, 0.0),
         1.0,
         ray1
         ) ≈ intersection1

    ray2 = Ray(Point(16, 0, 0), -VEC_X)
    intersection2 = ray_intersection(torus, ray2)
    @test typeof(intersection2) == HitRecord
    @test HitRecord(
         Point(14.0, 0.0, 0.0),
         Normal(1.0, 0.0, 0.0),
         Vec2d(0.0, 0.0), 
         2.0,
         ray2
         ) ≈ intersection2

    # Check if the torus failed to move by trying to hit the untransformed shape
    @test typeof( ray_intersection(torus, Ray( Point(3, 0, 2), -VEC_Z ) ) ) == Nothing

    # Check if the *inverse* transformation was wrongly applied
    @test typeof( ray_intersection(torus, Ray( Point(-10, 0, 0), -VEC_Z ) ) ) == Nothing
end

@testset "test_Normals" begin
    torus = Torus(scaling(Vec(2.0, 1.0, 2.0)))
    ray = Ray(Point(10.0, 0.0, 1.0), -VEC_X)
    intersection = ray_intersection(torus, ray)

    @test typeof(intersection) == HitRecord
    @test intersection.normal ≈ Normal((√3)/2, 0.0, 1/2)
end

@testset "test_UV_Coordinates" begin
    torus = Torus()

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

    ray1 = Ray(Point(5.0, 0.0, 0.0), -VEC_X)
    ray2 = Ray(Point(0.0, 5.0, 0.0), -VEC_Y)
    ray3 = Ray(Point(-5.0, 0.0, 0.0), VEC_X)
    ray4 = Ray(Point(0.0, -5.0, 0.0), VEC_Y)
    ray5 = Ray(Point(5.0, 0.0, 0.5), -VEC_X)
    ray6 = Ray(Point(5.0, 0.0, -0.5), -VEC_X)
    ray7 = Ray(Point(3.5, 0.0, 2.0), -VEC_Z)
    
    @test ray_intersection(torus, ray1).surface_point ≈ Vec2d(0.0, 0.0)
    @test ray_intersection(torus, ray2).surface_point ≈ Vec2d(0.0, 0.25)
    @test ray_intersection(torus, ray3).surface_point ≈ Vec2d(0.0, 0.5)
    @test ray_intersection(torus, ray4).surface_point ≈ Vec2d(0.0, 0.75)
    @test ray_intersection(torus, ray5).surface_point ≈ Vec2d(1/12, 0.0)
    @test ray_intersection(torus, ray6).surface_point ≈ Vec2d(11/12, 0.0)
    @test ray_intersection(torus, ray7).surface_point ≈ Vec2d(1/6, 0.0)
end