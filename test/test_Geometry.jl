# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



@testset "test_Vec" begin
     err = 1e-11
     a = Vec(1.0, 2.0, 3.0)
     b = Vec(4.0, 6.0, 8.0)

     @test a ≈ Vec(1.0, 2.0, 3.0 + err)
     @test (a + b) ≈ Vec(5.0, 8.0 + 3*err, 11.0)
     @test (b - a) ≈ Vec(3.0, 4.0 - 2*err, 5.0)
     @test (a * 2) ≈ Vec(2.0, 4.0 + 2*err, 6.0 - err)
     @test (2 * a) ≈ Vec(2.0, 4.0 - err, 6.0)
     @test ( a/2 ) ≈ Vec(0.5, 1.0, 1.5 + 3*err)
     @test (a ⋅ b) ≈ 40.0 - 9.5*err
     @test (a × b) ≈ Vec(-2.0, 4.0 - err, -2.0)
     @test (b × a) ≈ Vec(2.0, -4.0, 2.0 - err)
end

@testset "test_Point" begin
     err = 1e-11
     p1 = Point(1.0, 2.0, 3.0)
     p2 = Point(4.0, 6.0, 8.0)
     v = Vec(4.0, 6.0, 8.0)
     
     @test (p1 * 2) ≈ Point(2.0, 4.0 - err, 6.0)
     @test (2 * p1) ≈ Point(2.0, 4.0 + 8.5*err, 6.0)
     @test (p1 + v) ≈ Point(5.0, 8.0 - err, 11.0)
     @test (p1 - v) ≈ Point(-3.0, -4.0 - err, -5.0)
     @test (p2 - p1) ≈ Vec(3.0, 4.0 - 2 * err, 5.0)
end

@testset "test_geometry_normalizations" begin
     err = 1e-11
     a = Vec(1.0, 2.0, 3.0)
     b = Vec(4.0, 6.0, 8.0)

     @test Raytracing.squared_norm(a) ≈ 14 - 3*err
     @test Raytracing.squared_norm(b) ≈ 116 + 3*err
     @test Raytracing.norm(a) ≈ √14 - 3*err
     @test Raytracing.norm(b) ≈ √116 + 3*err
     a = Raytracing.normalize(a)
     b = Raytracing.normalize(b)
     @test a ≈ Vec(1.0, 2.0, 3.0)/√14
     @test b ≈ Vec(4.0, 6.0, 8.0)/√116
end
