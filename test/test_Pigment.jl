# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



@testset "test_UniformPigment" begin
     color = RGB(1.0, 2.0, 3.0)
     pigment = UniformPigment(color)

     get_color(pigment, Vec2d(0.0, 0.0)) ≈ color
     @test get_color(pigment, Vec2d(1.0, 0.0)) ≈ color
     @test get_color(pigment, Vec2d(0.0, 1.0)) ≈ color
     @test get_color(pigment, Vec2d(1.0, 1.0)) ≈ color
     @test get_color(pigment, Vec2d(0.5, 0.5)) ≈ color
end

@testset "test_ImagePigment" begin
     image = HDRimage(2, 2)
     Raytracing.set_pixel(image, 0, 0, RGB{Float32}(1.0, 2.0, 3.0))
     Raytracing.set_pixel(image, 1, 0, RGB{Float32}(2.0, 3.0, 1.0))
     Raytracing.set_pixel(image, 0, 1, RGB{Float32}(2.0, 1.0, 3.0))
     Raytracing.set_pixel(image, 1, 1, RGB{Float32}(3.0, 2.0, 1.0))

     pigment = ImagePigment(image)
     @test get_color(pigment, Vec2d(0.0, 0.0)) ≈ RGB{Float32}(1.0, 2.0, 3.0)
     @test get_color(pigment, Vec2d(1.0, 0.0)) ≈ RGB{Float32}(2.0, 3.0, 1.0)
     @test get_color(pigment, Vec2d(0.0, 1.0)) ≈ RGB{Float32}(2.0, 1.0, 3.0)
     @test get_color(pigment, Vec2d(1.0, 1.0)) ≈ RGB{Float32}(3.0, 2.0, 1.0)
end

@testset "test_CheckeredPigment" begin
     color1 = RGB{Float32}(1.0, 2.0, 3.0)
     color2 = RGB{Float32}(10.0, 20.0, 30.0)

     pigment = CheckeredPigment(color1, color2, 2)

     # With num_of_steps == 2, the pattern should be the following:
     #
     #              (0.5, 0)
     #   (0, 0) +------+------+ (1, 0)
     #          |      |      |
     #          | col1 | col2 |
     #          |      |      |
     # (0, 0.5) +------+------+ (1, 0.5)
     #          |      |      |
     #          | col2 | col1 |
     #          |      |      |
     #   (0, 1) +------+------+ (1, 1)
     #              (0.5, 1)
     @test get_color(pigment, Vec2d(0.25, 0.25)) ≈ color1
     @test get_color(pigment, Vec2d(0.75, 0.25)) ≈ color2
     @test get_color(pigment, Vec2d(0.25, 0.75)) ≈ color2
     @test get_color(pigment, Vec2d(0.75, 0.75)) ≈ color1
end