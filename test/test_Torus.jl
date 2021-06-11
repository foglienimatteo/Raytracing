# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

@testset "test_Hit" begin
    torus = Torus()
    ray1 = Ray(Point(0., 0., 2.), -VEC_Z)
    ray2 = Ray(Point(4., 0., 0.), -VEC_X)
    ray3 = Ray(Point(0., 1., 2.), -VEC_Z)
    ray4 = Ray(Point(0., 4., 0.), -VEC_Y)

#    printstyled("\nintersection1 :", color=:light_green, "\n")
    intersection1 = ray_intersection(torus, ray1)
#    printstyled("\nintersection2 :", color=:light_green, "\n")
    intersection2 = ray_intersection(torus, ray2)
#    printstyled("\nintersection3 :", color=:light_green, "\n")
    intersection3 = ray_intersection(torus, ray3)
#    printstyled("\nintersection4 :", color=:light_green, "\n")
    intersection4 = ray_intersection(torus, ray4)
    
    @test isnothing(intersection1)

    @test typeof(intersection2) == HitRecord
    @test typeof(intersection3) == HitRecord
    @test typeof(intersection4) == HitRecord

    @test intersection2 ≈ HitRecord(
                            Point(1.5, 0., 0.),
                            Normal(1., 0., 0.),
                            Vec2d(0., 0.),
                            2.5,
                            ray2,
                            torus
    )
    @test intersection3 ≈ HitRecord(
                            Point(0., 1., 0.5),
                            Normal(0., 0., 1.),
                            Vec2d(0.25, 0.07379180882521622),
                            1.5,
                            ray3,
                            torus
    )
    @test intersection4 ≈ HitRecord(
                            Point(0., 1.5, 0.),
                            Normal(0., 1., 0.),
                            Vec2d(0.25, 0.),
                            2.5,
                            ray4,
                            torus
    )
end

@testset "test_InnerHit" begin
    torus = Torus(Transformation(), Material(), 1., 5.)

    ray = Ray(Point(5., 0., 0.), VEC_X)
    intersection = ray_intersection(torus, ray)

    typeof(intersection) == HitRecord
    @test HitRecord(
            Point(6., 0., 0.),
            Normal(-1., 0., 0.),
            Vec2d(0., 0.),
            1.,
            ray
            ) ≈ intersection
end

@testset "test_Transformation" begin
    torus = Torus(
                translation(Vec(10., 0., 0.)) * rotation_y(pi/2),
                Material(),
                1.,
                3.
    )

    ray1 = Ray(Point(0., 0., 0.), VEC_X)
    ray2 = Ray(Point(10., 5., 0.), -VEC_Y)
    ray3 = Ray(Point(10., 0., 5.), -VEC_Z)

    intersection1 = ray_intersection(torus, ray1)
    intersection2 = ray_intersection(torus, ray2)
    intersection3 = ray_intersection(torus, ray3)
    
    @test isnothing(intersection1)
    @test typeof(intersection2) == HitRecord
    @test typeof(intersection3) == HitRecord

    @test intersection2 ≈ HitRecord(
                            Point(10., 4., 0.),
                            Normal(0., 1., 0.),
                            Vec2d(0.25, 0.),
                            1.,
                            ray2
    )
    @test intersection3 ≈ HitRecord(
                            Point(10., 0., 4.),
                            Normal(0., 0., 1.),
                            Vec2d(0.5, 0.),      # ERROR
                            1.,
                            ray3,
                            torus
    )
end

@testset "test_Normals" begin
    torus = Torus(
                Transformation(),
                Material(),
                1.,
                5.
    )
    ray1 = Ray(Point(-5., 0., -3.), VEC_Z)
    ray2 = Ray(Point(0., -10., 0.), VEC_Y)

    intersection1 = ray_intersection(torus, ray1)
    intersection2 = ray_intersection(torus, ray2)

    @test intersection1.normal ≈ Normal(0., 0., -1.)
    @test intersection2.normal ≈ Normal(0., -1., 0.)
end

#=
HitRecord(
    Point(10.0, 0.0, 4.0),
    Normal(-1.2246467991473535e-16, 0.0, 1.0),
    Vec2d(-0.0, 1.0),
    1.0000000000000002,
    Ray(Point(10.0, 0.0, 5.0),
    Vec(-0.0, -0.0, -1.0),
    1.0e-5, Inf, 0),
    Torus(
        Transformation(
            [6.123233995736766e-17 0.0 1.0 10.0; 0.0 1.0 0.0 0.0; -1.0 0.0 6.123233995736766e-17 0.0; 0.0 0.0 0.0 1.0],
            [6.123233995736766e-17 0.0 -1.0 -6.123233995736766e-16; 0.0 1.0 0.0 0.0; 1.0 0.0 6.123233995736766e-17 -10.0; 0.0 0.0 0.0 1.0]
            ),
        Material(DiffuseBRDF(UniformPigment(RGB{Float32}(1.0f0,1.0f0,1.0f0)), 1.0), UniformPigment(RGB{Float32}(0.0f0,0.0f0,0.0f0))), 1.0, 3.0)
)
≈
HitRecord(
    Point(10.0, 0.0, 4.0),
    Normal(0.0, 0.0, 1.0),
    Vec2d(0.0, 0.0),
    1.0,
    Ray(Point(10.0,0.0, 5.0),
    Vec(-0.0, -0.0, -1.0), 1.0e-5, Inf, 0),
    Torus(
        Transformation(
            [6.123233995736766e-17 0.0 1.0 10.0; 0.0 1.0 0.0 0.0; -1.0 0.0 6.123233995736766e-17 0.0; 0.0 0.0 0.0 1.0],
            [6.123233995736766e-17 0.0 -1.0 -6.123233995736766e-16; 0.0 1.0 0.0 0.0; 1.0 0.0 6.123233995736766e-17 -10.0; 0.0 0.0 0.0 1.0]
            ),
        Material(DiffuseBRDF(UniformPigment(RGB{Float32}(1.0f0,1.0f0,1.0f0)), 1.0), UniformPigment(RGB{Float32}(0.0f0,0.0f0,0.0f0))), 1.0, 3.0))
=#