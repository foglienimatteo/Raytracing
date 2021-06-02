# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



@testset "test_Rays" begin
     @testset "test_is_close" begin
          ray1 = Ray(Point(1.0, 2.0, 3.0), Vec(5.0, 4.0, -1.0))
          ray2 = Ray(Point(1.0, 2.0, 3.0), Vec(5.0, 4.0, -1.0))
          ray3 = Ray(Point(5.0, 1.0, 4.0), Vec(3.0, 9.0, 4.0))

          @test ray1 ≈ ray2
          @test !( ray1 ≈ ray3 )
     end

     @testset "test_at" begin
          ray = Ray(Point(1.0, 2.0, 4.0),Vec(4.0, 2.0, 1.0))
          @test at(ray, 0.0) ≈ ray.origin
          @test at(ray, 1.0) ≈ Point(5.0, 4.0, 5.0)
          @test at(ray, 2.0) ≈ Point(9.0, 6.0, 6.0)  
     end

     @testset "test_transform" begin
          ray = Ray(Point(1.0, 2.0, 3.0), Vec(6.0, 5.0, 4.0))
          T = translation(Vec(10.0, 11.0, 12.0)) * rotation_x(π/2)
          transformed = T*ray

          @test transformed.origin ≈ Point(11.0, 8.0, 14.0)
          @test transformed.dir ≈ Vec(6.0, -4.0, 5.0)
     end
end

@testset "test_Camera" begin

     @testset "test_OrthogonalCamera" begin
          cam = OrthogonalCamera(2.0)
          ray1 = fire_ray(cam, 0.0, 0.0)
          ray2 = fire_ray(cam, 1.0, 0.0)
          ray3 = fire_ray(cam, 0.0, 1.0)
          ray4 = fire_ray(cam, 1.0, 1.0)

          # Verify that the rays are parallel by verifying that cross-products vanish
          @test 0.0 ≈ squared_norm(ray1.dir × ray2.dir)
          @test 0.0 ≈ squared_norm(ray1.dir × ray3.dir)
          @test 0.0 ≈ squared_norm(ray1.dir × ray4.dir)

          # Verify that the ray hitting the corners have the right coordinates
          @test at(ray1, 1.0) ≈ Point(0.0, 2.0, -1.0)
          @test at(ray2, 1.0) ≈ Point(0.0, -2.0, -1.0)
          @test at(ray3, 1.0) ≈ Point(0.0, 2.0, 1.0)
     end

     @testset "test_PerspectiveCamera" begin
          cam = PerspectiveCamera(1.0, 2.0)
          ray1 = fire_ray(cam, 0.0, 0.0)
          ray2 = fire_ray(cam, 1.0, 0.0)
          ray3 = fire_ray(cam, 0.0, 1.0)
          ray4 = fire_ray(cam, 1.0, 1.0)

          # Verify that all the rays depart from the same point
          @test ray1.origin ≈ ray2.origin
          @test ray1.origin ≈ ray3.origin
          @test ray1.origin ≈ ray4.origin

          # Verify that the ray hitting the corners have the right coordinates
          @test at(ray1, 1.0) ≈ Point(0.0, 2.0, -1.0)
          @test at(ray2, 1.0) ≈ Point(0.0, -2.0, -1.0)
          @test at(ray3, 1.0) ≈ Point(0.0, 2.0, 1.0)
          @test at(ray4, 1.0) ≈ Point(0.0, -2.0, 1.0)
     end

end

@testset "test_ImageTracer" begin
     
     @testset "test_uv_sub_mapping" begin
          img = HDRimage(4, 2)
          Pcam = PerspectiveCamera(1., 2.) # PAY ATTENSTION TO POSITIONAL ARGUMENTS!!!!!!!!!!!!!!!!!
          tracer = ImageTracer(img, Pcam)
          r1 = fire_ray(tracer, 0, 0, 2.5, 1.5)
          r2 = fire_ray(tracer, 2, 1)
          @test r1 ≈ r2
     end

     @testset "test_orientation" begin
          img = HDRimage(4, 2)
          Pcam = PerspectiveCamera(1., 2.) # PAY ATTENSTION TO POSITIONAL ARGUMENTS!!!!!!!!!!!!!!!!!
          tracer = ImageTracer(img, Pcam)

          top_left_ray = fire_ray(tracer, 0, 0, 0., 0.)
          bottom_right_ray = fire_ray(tracer, 3, 1, 1.0, 1.0)

          @test Point(0., 2., 1.) ≈ at(top_left_ray, 1.)
          @test Point(0., -2., -1.) ≈ at(bottom_right_ray, 1.)
     end

     @testset "test_image_coverage" begin
          img = HDRimage(4, 2)
          Pcam = PerspectiveCamera(1., 2.) # PAY ATTENSTION TO POSITIONAL ARGUMENTS!!!!!!!!!!!!!!!!!
          tracer = ImageTracer(img, Pcam)
          fire_all_rays!(tracer, x->RGB{Float32}(1.0, 2.0, 3.0))
          for row in tracer.img.height-1:-1:0, col in 0:tracer.img.width-1
               @test Raytracing.get_pixel(img, col, row) == RGB{Float32}(1.0, 2.0, 3.0)
          end
     end

end