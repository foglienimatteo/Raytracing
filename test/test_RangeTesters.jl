# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


@testset "test_check_is_positive" begin
     @test Raytracing.check_is_positive("")
     @test Raytracing.check_is_positive("    ")
     @test Raytracing.check_is_positive(" 3 ")
     @test Raytracing.check_is_positive("3.0 ")
     @test !Raytracing.check_is_positive("-3.4")
     @test !Raytracing.check_is_positive(" -3")
end

@testset "test_string2positive" begin
     @test Raytracing.string2positive("") == 0.0
     @test Raytracing.string2positive("    ") == 0.0
     @test Raytracing.string2positive(" 3 ") == 3.0
     @test Raytracing.string2positive("3.0 ") == 3.0
     @test_throws ArgumentError Raytracing.string2positive("-3.4")
     @test_throws ArgumentError Raytracing.string2positive("-3")
end


##########################################################################################92


@testset "test_check_is_uint64" begin
     @test Raytracing.check_is_uint64("")
     @test Raytracing.check_is_uint64("    ")
     @test Raytracing.check_is_uint64(" 3 ")
     @test Raytracing.check_is_uint64("3.0 ")
     @test !Raytracing.check_is_uint64("3.4")
     @test !Raytracing.check_is_uint64("-3")
end

@testset "test_string2int64" begin
     @test Raytracing.string2int64("") == 0
     @test Raytracing.string2int64("", true) == UInt64(0)
     @test Raytracing.string2int64("", false) == 0
     @test Raytracing.string2int64("    ") == 0
     @test Raytracing.string2int64("    ", true) == UInt64(0)
     @test Raytracing.string2int64("    ", false) == 0
     @test Raytracing.string2int64(" 3 ") == 3
     @test Raytracing.string2int64(" 3 ", true) == UInt64(3)
     @test Raytracing.string2int64(" 3 ", false) == 3
     @test Raytracing.string2int64("3.0 ") == 3
     @test Raytracing.string2int64("3.0 ", true) == UInt64(3)
     @test Raytracing.string2int64("3.0 ", false) == 3
     @test_throws ArgumentError Raytracing.string2int64("3.4")
     @test_throws ArgumentError Raytracing.string2int64("-3")
     @test_throws ArgumentError Raytracing.string2int64("3.4", true)
     @test_throws ArgumentError Raytracing.string2int64("-3", true)
     @test_throws ArgumentError Raytracing.string2int64("3.4", false)
     @test_throws ArgumentError Raytracing.string2int64("-3", false)
end


##########################################################################################92


@testset "test_check_is_even_uint64" begin
     @test Raytracing.check_is_even_uint64("")
     @test Raytracing.check_is_even_uint64("    ")
     @test Raytracing.check_is_even_uint64(" 0 ")
     @test Raytracing.check_is_even_uint64("0.0 ")
     @test Raytracing.check_is_even_uint64(" 2 ")
     @test Raytracing.check_is_even_uint64("2.0 ")
     @test Raytracing.check_is_even_uint64(" 4 ")
     @test Raytracing.check_is_even_uint64("4.0 ")
     @test !Raytracing.check_is_even_uint64("2.5")
     @test !Raytracing.check_is_even_uint64("1")
     @test !Raytracing.check_is_even_uint64("3")
     @test !Raytracing.check_is_even_uint64("-4")
end

@testset "test_string2evenint64" begin
     @test Raytracing.string2evenint64("") == 0
     @test Raytracing.string2evenint64("", true) == UInt64(0)
     @test Raytracing.string2evenint64("", false) == 0
     @test Raytracing.string2evenint64("    ") == 0
     @test Raytracing.string2evenint64("    ", true) == UInt64(0)
     @test Raytracing.string2evenint64("    ", false) == 0
     @test Raytracing.string2evenint64(" 2 ") == 2
     @test Raytracing.string2evenint64(" 2 ", true) == UInt64(2)
     @test Raytracing.string2evenint64(" 2 ", false) == 2
     @test Raytracing.string2evenint64("2.0 ") == 2
     @test Raytracing.string2evenint64("  2.0 ", true) == UInt64(2)
     @test Raytracing.string2evenint64("2.0 ", false) == 2
     @test_throws ArgumentError Raytracing.string2evenint64("3.4")
     @test_throws ArgumentError Raytracing.string2evenint64("-3")
     @test_throws ArgumentError Raytracing.string2evenint64("3", true)
     @test_throws ArgumentError Raytracing.string2evenint64("3.4", true)
     @test_throws ArgumentError Raytracing.string2evenint64("-3", true)
     @test_throws ArgumentError Raytracing.string2evenint64("3.4", false)
     @test_throws ArgumentError Raytracing.string2evenint64("-3", false)
end


##########################################################################################92


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

@testset "test_string2rootint64" begin
     @test Raytracing.string2rootint64("") == 0
     @test Raytracing.string2rootint64("    ") == 0
     @test Raytracing.string2rootint64(" 0 ") == 0
     @test Raytracing.string2rootint64(" 1 ") == 1
     @test Raytracing.string2rootint64(" 4 ") == 2
     @test Raytracing.string2rootint64(" 4.0 ") == 2
     @test Raytracing.string2rootint64(" 9 ") == 3
     @test Raytracing.string2rootint64(" 9.0 ") == 3
     @test_throws ArgumentError Raytracing.string2rootint64("3")
     @test_throws ArgumentError Raytracing.string2rootint64("-4")
     @test_throws ArgumentError Raytracing.string2rootint64("10.0")
end



##########################################################################################92



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

@testset "test_string2color" begin
     @test Raytracing.string2color("") == RGB{Float32}(0,0,0)
     @test Raytracing.string2color("  ") == RGB{Float32}(0,0,0)
     @test Raytracing.string2color("<0,0,0>") == RGB{Float32}(0,0,0)
     @test Raytracing.string2color("<1.0,  2, pi >   ") == RGB{Float32}(1,2,π)
     @test_throws ArgumentError Raytracing.string2color("3")
     @test_throws ArgumentError Raytracing.string2color("0,0,0")
     @test_throws ArgumentError Raytracing.string2color("[0,0,0]")
     @test_throws ArgumentError Raytracing.string2color("<0 0 0>")
end


##########################################################################################92


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


@testset "test_string2vector" begin
     @test Raytracing.string2vector("") == Raytracing.Vec(0.,0.,0.)
     @test Raytracing.string2vector("  ") == Raytracing.Vec(0.,0.,0.)
     @test Raytracing.string2vector("[0,0,0]") == Raytracing.Vec(0.,0.,0.)
     @test Raytracing.string2vector("[1.0,  2, pi ]   ") == Raytracing.Vec(1.,2.,π)
     @test_throws ArgumentError Raytracing.string2vector("3")
     @test_throws ArgumentError Raytracing.string2vector("0,0,0")
     @test_throws ArgumentError Raytracing.string2vector("<0,0,0>")
     @test_throws ArgumentError Raytracing.string2vector("[0 0 0]")
end
