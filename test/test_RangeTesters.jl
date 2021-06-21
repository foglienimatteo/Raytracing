# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


@testset "test_check_is_uint64" begin
     @test Raytracing.check_is_uint64("")
     @test Raytracing.check_is_uint64("    ")
     @test Raytracing.check_is_uint64(" 3 ")
     @test Raytracing.check_is_uint64("3.0 ")
     @test !Raytracing.check_is_uint64("3.4")
     @test !Raytracing.check_is_uint64("-3")
end

@testset "test_check_is_square" begin
     @test Raytracing.check_is_square("")
     @test Raytracing.check_is_square("    ")
     @test Raytracing.check_is_square(" 0 ")
     @test Raytracing.check_is_square(" 1 ")
     @test Raytracing.check_is_square(" 4 ")
     @test Raytracing.check_is_square(" 4.0 ")
     @test Raytracing.check_is_square(" 9 ")
     @test Raytracing.check_is_square(" 9.0 ")
     @test !Raytracing.check_is_square("3")
     @test !Raytracing.check_is_square("-4")
     @test !Raytracing.check_is_square("10.0")
end



@testset "test_check_is_color" begin
     @test Raytracing.check_is_color("")
     @test Raytracing.check_is_color("  ")
     @test Raytracing.check_is_color("<0,0,0>")
     @test Raytracing.check_is_color("<1.0,  2, pi >   ")
     @test !Raytracing.check_is_color("3")
     @test !Raytracing.check_is_color("0,0,0")
     @test !Raytracing.check_is_color("[0,0,0]")
     @test !Raytracing.check_is_color("<0 0 0>")
end

@testset "test_check_is_vector" begin
     @test Raytracing.check_is_vector("")
     @test Raytracing.check_is_vector("  ")
     @test Raytracing.check_is_vector("[0,0,0]")
     @test Raytracing.check_is_vector("[1.0,  2, pi]   ")
     @test !Raytracing.check_is_vector("3")
     @test !Raytracing.check_is_vector("0,0,0")
     @test !Raytracing.check_is_vector("<0,0,0>")
     @test !Raytracing.check_is_vector("[0 0 0]")
end
