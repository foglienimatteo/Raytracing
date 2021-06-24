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



##########################################################################################92


@testset "test_check_is_declare_float" begin
     @test Raytracing.check_is_declare_float("")
     @test Raytracing.check_is_declare_float("  ")
     @test Raytracing.check_is_declare_float("nome1:1.01,nome2:3.14")
     @test Raytracing.check_is_declare_float(" nome:    1.09013")
     @test Raytracing.check_is_declare_float("var1 : 1, var2 : 2 , var3:5.64")
     @test !Raytracing.check_is_declare_float("prova , 1")
     @test !Raytracing.check_is_declare_float(" prova : 1 ,")
     @test !Raytracing.check_is_declare_float("prova")
end

@testset "test_declare_float2dict" begin
     @test isnothing(Raytracing.declare_float2dict(""))
     @test isnothing(Raytracing.declare_float2dict("  "))
     @test Raytracing.declare_float2dict("nome1:1.01,nome2:3.14") == Dict("nome1" => 1.01, "nome2" =>3.14)
     @test Raytracing.declare_float2dict(" nome:    1.09013") == Dict("nome" =>  1.09013)
     @test Raytracing.declare_float2dict("var1 : 1, var2 : 2 , var3:5.64")  == Dict("var1" => 1, "var2" =>2, "var3"=>5.64)
     @test_throws ArgumentError Raytracing.declare_float2dict("prova , 1")
     @test_throws ArgumentError Raytracing.declare_float2dict(" prova : 1 ,")
     @test_throws ArgumentError Raytracing.declare_float2dict("prova")
end

##########################################################################################92


@testset "test_check_is_one_of" begin
     @test Raytracing.check_is_one_of("per", CAMERAS)
     @test Raytracing.check_is_one_of("ort", CAMERAS)
     @test Raytracing.check_is_one_of("  per    ", CAMERAS)
     @test Raytracing.check_is_one_of("ort   ", CAMERAS)
     @test !Raytracing.check_is_one_of("", CAMERAS)
     @test !Raytracing.check_is_one_of("  ", CAMERAS)
     @test !Raytracing.check_is_one_of("prova", CAMERAS)
end

@testset "test_string2stringoneof" begin
     @test Raytracing.string2stringoneof("per", CAMERAS) == "per"
     @test Raytracing.string2stringoneof("ort", CAMERAS) == "ort"
     @test Raytracing.string2stringoneof("per   ", CAMERAS) == "per"
     @test Raytracing.string2stringoneof("  ort ", CAMERAS) == "ort"
     @test_throws ArgumentError Raytracing.string2stringoneof("", CAMERAS)
     @test_throws ArgumentError Raytracing.string2stringoneof("   ", CAMERAS)
     @test_throws ArgumentError Raytracing.string2stringoneof("prova ", CAMERAS)
end


##########################################################################################92


@testset "test_check_is_iterable_1" begin
     @test Raytracing.check_is_iterable(1)
     @test Raytracing.check_is_iterable(1:5)
     @test Raytracing.check_is_iterable([0.1 , 2, 14])

     @test Raytracing.check_is_iterable(1, Int64)
     @test Raytracing.check_is_iterable(1, Number)
     @test Raytracing.check_is_iterable(1:5, Int64)
     @test Raytracing.check_is_iterable(1:5, Number)
     @test Raytracing.check_is_iterable([0.1 , 2, 14], Float64)
     @test Raytracing.check_is_iterable([0.1 , 2, 14], Number)

     @test !Raytracing.check_is_iterable([0.1 , 2, 14], Int64)
end

@testset "test_check_is_iterable_2" begin
     @test Raytracing.check_is_iterable("1")
     @test Raytracing.check_is_iterable("1:5")
     @test Raytracing.check_is_iterable("[0.1 , 2, 14]")

     @test Raytracing.check_is_iterable("1", Int64)
     @test Raytracing.check_is_iterable("1", Number)
     @test Raytracing.check_is_iterable("1:5", Int64)
     @test Raytracing.check_is_iterable("1:5", Number)
     @test Raytracing.check_is_iterable("[0.1 , 2, 14]", Float64)
     @test Raytracing.check_is_iterable("[0.1 , 2, 14]", Number)

     @test !Raytracing.check_is_iterable("[0.1 , 2, 14]", Int64)
end


@testset "test_string2iterable" begin
     @test Raytracing.string2iterable("1.0") == 1
     @test Raytracing.string2iterable("1:5") == 1:5
     @test Raytracing.string2iterable("[0.1 , 2, 14]") == [0.1, 2, 14]

     @test Raytracing.string2iterable("1", Int64) == 1
     @test Raytracing.string2iterable("1", Number) == 1
     @test Raytracing.string2iterable("1:5", Int64) == 1:5
     @test Raytracing.string2iterable("1:5", Number) == 1:5
     @test Raytracing.string2iterable("[0.1 , 2, 14]", Float64) == [0.1, 2, 14]
     @test Raytracing.string2iterable("[0.1 , 2, 14]", Number) == [0.1, 2, 14]
end


##########################################################################################92


@testset "test_check_is_vec_variables" begin
     @test Raytracing.check_is_vec_variables("")
     @test Raytracing.check_is_vec_variables("  ")
     @test Raytracing.check_is_vec_variables("[nome1,nome2]")
     @test Raytracing.check_is_vec_variables("  [  nome  ]")
     @test Raytracing.check_is_vec_variables("[var1 ,  var2 , var3    ]")
     @test !Raytracing.check_is_vec_variables("prova , 1")
     @test !Raytracing.check_is_vec_variables("[ prova : 1 ]")
     @test !Raytracing.check_is_vec_variables("prova")
end

@testset "test_string2vec_variables" begin
     @test isnothing(Raytracing.string2vec_variables(""))
     @test isnothing(Raytracing.string2vec_variables("  "))
     @test Raytracing.string2vec_variables("[nome1,nome2]") == ["nome1", "nome2"]
     @test Raytracing.string2vec_variables("  [  nome  ]") == ["nome"]
     @test Raytracing.string2vec_variables("[var1 ,  var2 , var3    ]") == ["var1", "var2", "var3"]
     @test_throws ArgumentError Raytracing.string2vec_variables("prova , 1")
     @test_throws ArgumentError Raytracing.string2vec_variables("[ prova : 1 ]")
     @test_throws ArgumentError Raytracing.string2vec_variables("prova")
end

