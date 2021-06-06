# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



@testset "test_luminosity" begin
     a = RGB{Float32}(8.0, 10.0, 22.0)
     b = RGB{Float32}(1.0, 100.0, 221.0)
     @test Raytracing.luminosity(a) ≈ 15.0
     @test Raytracing.luminosity(b) ≈ 111.0
end

@testset "test_avg_lum" begin
     rgb_matrix = [RGB(5.0, 10.0, 15.0), RGB(500.0, 1000.0, 1500.0)]
     img = Raytracing.HDRimage(2, 1, rgb_matrix)
     @test Raytracing.avg_lum(img, 0.0) ≈ 100.0
end

@testset "normalize_image" begin
     img = Raytracing.HDRimage(2, 1, [RGB(5.0, 10.0, 15.0), RGB(500.0, 1000.0, 1500.0)])
     Raytracing.normalize_image!(img, 1000.0, 100.0)
     @test Raytracing.get_pixel(img, 0, 0) ≈ RGB(0.5e2, 1.0e2, 1.5e2)
     @test Raytracing.get_pixel(img, 1, 0) ≈ RGB(0.5e4, 1.0e4, 1.5e4)

     img = Raytracing.HDRimage(2, 1, [RGB(5.0, 10.0, 15.0), RGB(500.0, 1000.0, 1500.0)])	
     Raytracing.normalize_image!(img, 1000.0)
     @test Raytracing.get_pixel(img, 0, 0) ≈ RGB(0.5e2, 1.0e2, 1.5e2)
     @test Raytracing.get_pixel(img, 1, 0) ≈ RGB(0.5e4, 1.0e4, 1.5e4)
end

@testset "test_clamp_image" begin
     img = Raytracing.HDRimage(2, 1, [RGB(5.0, 10.0, 15.0), RGB(500.0, 1000.0, 1500.0)])
     Raytracing.clamp_image!(img)
     @test Raytracing.get_pixel(img, 0, 0).r >= 0 && Raytracing.get_pixel(img, 0, 0).r <= 1
     @test Raytracing.get_pixel(img, 0, 0).g >= 0 && Raytracing.get_pixel(img, 0, 0).g <= 1
     @test Raytracing.get_pixel(img, 0, 0).b >= 0 && Raytracing.get_pixel(img, 0, 0).b <= 1
end

@testset "test_γcorrection" begin
     img = Raytracing.HDRimage(2, 3, [RGB(1.0, 2.0, 3.0), RGB(4.0, 5.0, 6.0), RGB(7.0, 8.0, 9.0), RGB(10.0, 11.0, 12.0), RGB(13.0, 14.0, 15.0), RGB(16.0, 17.0, 18.0)])
     img2 = Raytracing.HDRimage(2, 3, [RGB(255., 360., 441.)/255., RGB(510., 570., 624.)/255., RGB(674., 721, 765.)/255., RGB(806., 845., 883.)/255., RGB(919., 954., 987.)/255., RGB(1020., 1051., 1081.)/255.])
     Raytracing.γ_correction!(img, 2.0)	
     @test img ≈ img2
end

@testset "test_get_matrix" begin
     img = Raytracing.HDRimage(2, 3, [
               RGB(1.0, 2.0, 3.0), RGB(4.0, 5.0, 6.0), RGB(7.0, 8.0, 9.0), 
               RGB(10.0, 11.0, 12.0), RGB(13.0, 14.0, 15.0), RGB(16.0, 17.0, 18.0)
               ])
     M1 = RGB{Float32}[
          RGB(1.0, 2.0, 3.0) RGB(4.0, 5.0, 6.0) ;
          RGB(7.0, 8.0, 9.0) RGB(10.0, 11.0, 12.0) ;
          RGB(13.0, 14.0, 15.0) RGB(16.0, 17.0, 18.0)
          ]
     @test M1 ≈  Raytracing.get_matrix(img)
end

@testset "test_tone_mapping_inputs" begin
     @test_throws MethodError tone_mapping("abracadabra")
     @test_throws ArgumentError tone_mapping(["abracadabra"])
     @test_throws ArgumentError tone_mapping(["a", "b", "c", "d", "e"])
end