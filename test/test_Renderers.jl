# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#




@testset "test_OnOffRenderer" begin
     sphere = Sphere(translation(Vec(2, 0, 0)) * scaling(Vec(0.2, 0.2, 0.2)),
                    Material(DiffuseBRDF(UniformPigment(WHITE))))
     image = HDRimage(3, 3)
     camera = OrthogonalCamera()
     tracer = ImageTracer(image,camera)
     world = World()
     add_shape(world, sphere)
     renderer = OnOffRenderer(world)
     fire_all_rays!(tracer, renderer)

     @test Raytracing.get_pixel(image, 0, 0) ≈ BLACK
     @test Raytracing.get_pixel(image, 1, 0) ≈ BLACK
     @test Raytracing.get_pixel(image, 2, 0) ≈ BLACK

     @test Raytracing.get_pixel(image, 0, 1) ≈ BLACK
     @test Raytracing.get_pixel(image, 1, 1) ≈ WHITE
     @test Raytracing.get_pixel(image, 2, 1) ≈ BLACK

     @test Raytracing.get_pixel(image, 0, 2) ≈ BLACK
     @test Raytracing.get_pixel(image, 1, 2) ≈ BLACK
     @test Raytracing.get_pixel(image, 2, 2) ≈ BLACK
end

@testset "test_FlatRenderer" begin
     sphere_color = RGB{Float32}(5.0, 6.0, 7.0)
     α = 0.2
     sphere = Sphere(translation(Vec(2, 0, 0)) * scaling(Vec(α, α, α)),
                    Material(DiffuseBRDF(UniformPigment(sphere_color))))
     
     @test sphere.Material.brdf.pigment == UniformPigment(sphere_color)

     image = HDRimage(3, 3)
     camera = OrthogonalCamera()
     tracer = ImageTracer(image, camera)

     world = World()
     add_shape(world, sphere)
     renderer = FlatRenderer(world)
     fire_all_rays!(tracer, renderer)

     @test Raytracing.get_pixel(image, 0, 0) ≈ BLACK
     @test Raytracing.get_pixel(image, 1, 0) ≈ BLACK
     @test Raytracing.get_pixel(image, 2, 0) ≈ BLACK

     @test Raytracing.get_pixel(image, 0, 1) ≈ BLACK
     @test Raytracing.get_pixel(image, 1, 1) ≈ sphere_color
     @test Raytracing.get_pixel(image, 2, 1) ≈ BLACK

     @test Raytracing.get_pixel(image, 0, 2) ≈ BLACK
     @test Raytracing.get_pixel(image, 1, 2) ≈ BLACK
     @test Raytracing.get_pixel(image, 2, 2) ≈ BLACK
end