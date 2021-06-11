# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

@testset "test_triangle_barycenter" begin
     triangle1 = Triangle()
     @test Raytracing.triangle_barycenter(triangle1) ≈ Point(√3/6, 0.0, 0.0)

     P1 = Point(1.0, 1.0, 1.0)
     P2 = Point(3.0, -1.0, 1.0)
     P3 = Point(2.0, 0.0, 4.0)
     triangle2 = Triangle(P1,P2,P3)

     @test Raytracing.triangle_barycenter(triangle2) ≈ Point(2.0, 0.0, 2.0)
end

@testset "test_Hit" begin
     triangle = Triangle()
     barycenter =  Raytracing.triangle_barycenter(triangle) 
     ray1 = Ray(barycenter + 2.0*VEC_Z, -VEC_Z)

     intersection1 = ray_intersection(triangle, ray1)

     println(intersection1)
     @test typeof(intersection1) == HitRecord
     @test HitRecord(
          Raytracing.triangle_barycenter(triangle), 
          Normal(0.0, 0.0, 1.0), 
          Vec2d(1/3, 1/3), 
          2.0,
          ray1
          ) ≈ intersection1
end

@testset "test_noHit" begin
     triangle = Triangle()

     ray1 = Ray(Point(0, 0, 1), VEC_X)
     intersection1 = ray_intersection(triangle, ray1)
     @test isnothing(intersection1)

     ray2 = Ray(Point(1, 2, -10), VEC_X+VEC_Y)
     intersection2 = ray_intersection(triangle, ray2)
     @test isnothing(intersection2)

     ray3 = Ray(Point(10, 0, -1), -VEC_Y)
     intersection3 = ray_intersection(triangle, ray3)
     @test isnothing(intersection3)
end

@testset "test_general_triangle" begin
     P1 = Point(1.0, 0.5, 0.0)
     P2 = Point(1.0, -0.5, 0.0)
     P3 = Point(1.0, 0.0, √3/2)
     triangle = Triangle(SVector{3}(P1,P2, P3))

     ray1 = Ray(Point(0, 0,  √3/6), VEC_X)
     intersection1 = ray_intersection(triangle, ray1)
     @test typeof(intersection1) == HitRecord
     @test HitRecord(
          Raytracing.triangle_barycenter(triangle),
          Normal(-1.0, 0.0, 0.0),
          Vec2d(1/3, 1/3),
          1.0,
          ray1
          ) ≈ intersection1

     # Check if the triangle failed to move by trying to hit the basic shape
     @test isnothing( ray_intersection(triangle, Ray( Point(0.5, 0, 1), -VEC_Z ) ) )
end

@testset "test_Normals" begin
     P1 = Point(1.0, 1.0, 1.0)
     P2 = Point(3.0, -1.0, 1.0)
     P3 = Point(2.0, 0.0, √6+1)
     triangle = Triangle(SVector{3}(P1,P2,P3))

     ray1 = Ray(Point(0, 0, (2+√6)/3), VEC_X)
     intersection1 = ray_intersection(triangle, ray1)
     @test typeof(intersection1) == HitRecord
     @test HitRecord(
          Raytracing.triangle_barycenter(triangle),
          Normal(-√2/2, -√2/2, 1.0),
          Vec2d(1/3, 1/3),
          2.0,
          ray1
          ) ≈ intersection1

     ray2 = Ray(Point(2.0, 1.0, (2+√6)/3), -VEC_Y)
     intersection2 = ray_intersection(triangle, ray2)
     @test typeof(intersection2) == HitRecord
     @test HitRecord(
          Raytracing.triangle_barycenter(triangle),
          Normal(√2/2, √2/2, 1.0),
          Vec2d(1/3, 1/3),
          1.0,
          ray2
          ) ≈ intersection2
end


@testset "test_UV_Coordinates" begin
     triangle = Triangle()

     barycenter = Raytracing.triangle_barycenter(triangle) 
     @test Raytracing.triangle_point_to_uv(triangle, barycenter) ≈ Vec2d(1/3, 1/3)
     ray1 = Ray(Point(barycenter.x, 0.0, 1.0), -VEC_Z)
     @test ray_intersection(triangle, ray1).surface_point ≈ Vec2d(1/3, 1/3)

     P2 = Point(2/3, 0.0, 0.0)
     @test Raytracing.triangle_point_to_uv(triangle, P2) ≈ Vec2d(1/6, 1/6)
     ray2 = Ray(Point(P2.x, 0.0, 1.0), -VEC_Z)
     @test ray_intersection(triangle, ray2).surface_point ≈ Vec2d(1/6, 1/6)
     
     #=
     P3 = Point(√3/4 -1/3, 1/4, 0.0)
     @test Raytracing.triangle_point_to_uv(triangle, P3) ≈ Vec2d(2/3, 1/6)
     ray2 = Ray(Point(P3.x, P3.y, 1.0), -VEC_Z)
     @test ray_intersection(triangle, ray2).surface_point ≈ Vec2d(2/3, 1/6)
     =#

     P4 = Point(0.0, 0.5, 0.0)
     @test Raytracing.triangle_point_to_uv(triangle, P4) ≈ Vec2d(1.0, 0.0)
end