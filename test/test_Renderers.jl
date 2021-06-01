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
     add_shape!(world, sphere)
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
     add_shape!(world, sphere)
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

@testset "test_PathTracer" begin
     # Here is impemented the Furnace test.
     # It is runned several times using random values 
     # for the emitted radiance and reflectance.
     
     pcg = PCG()

     for i in 1:10
          world = World()
          emitted_radiance = random(pcg)
          reflectance = random(pcg)
          enclosure_material = 
               Material(
                    DiffuseBRDF(UniformPigment(RGB{Float32}(1., 1., 1.) * reflectance)),
                    UniformPigment(RGB{Float32}(1., 1., 1.) * emitted_radiance),
               )

          add_shape!(world, Sphere(enclosure_material))

          path_tracer = PathTracer(world, BLACK, pcg, 1, 100, 101)

          ray = Ray(Point(0., 0., 0.), Vec(1., 0., 0.))
          color = path_tracer(ray)

          expected = emitted_radiance / (1.0 - reflectance)
          
          err=1e-3
          @test are_close(expected, color.r, err)
          @test are_close(expected, color.g, err)
          @test are_close(expected, color.b, err)

     end
end