# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


@testset "test_isdigit" begin
     @test Raytracing.Interpreter.isdigit("2")
     @test Raytracing.Interpreter.isdigit("1")
     @test !Raytracing.Interpreter.isdigit("10")
     @test !Raytracing.Interpreter.isdigit("a")
     @test !Raytracing.Interpreter.isdigit("")
end

@testset "test_isdecimal" begin
     @test Raytracing.Interpreter.isdecimal("2")
     @test Raytracing.Interpreter.isdecimal("1123129")
     @test !Raytracing.Interpreter.isdecimal("10.9")
     @test !Raytracing.Interpreter.isdecimal("ag")
     @test !Raytracing.Interpreter.isdecimal("10ag")
     @test !Raytracing.Interpreter.isdecimal("")
end

@testset "test_isalpha" begin
     @test Raytracing.Interpreter.isalpha("a")
     @test Raytracing.Interpreter.isalpha("ADcLopnb__o")
     @test !Raytracing.Interpreter.isalpha("1")
     @test !Raytracing.Interpreter.isalpha("aD1sd")
     @test !Raytracing.Interpreter.isalpha("")
end

@testset "test_isalnum" begin
     @test Raytracing.Interpreter.isalnum("adf_g")
     @test Raytracing.Interpreter.isalnum("1239")
     @test Raytracing.Interpreter.isalnum("A1__Def98")
     @test !Raytracing.Interpreter.isalnum("78KO.b")
     @test !Raytracing.Interpreter.isalnum("78KO@b")
     @test !Raytracing.Interpreter.isalnum("")
end


@testset "test_close_bracket" begin
     @test Raytracing.Interpreter.close_bracket("(") == ")"
     @test Raytracing.Interpreter.close_bracket("[") == "]"
     @test Raytracing.Interpreter.close_bracket("{") == "}"
     @test Raytracing.Interpreter.close_bracket("<") == ">"
     @test_throws ArgumentError Raytracing.Interpreter.close_bracket(" (")
     @test_throws ArgumentError Raytracing.Interpreter.close_bracket(")")
     @test_throws ArgumentError Raytracing.Interpreter.close_bracket("]")
     @test_throws ArgumentError Raytracing.Interpreter.close_bracket("}")
     @test_throws ArgumentError Raytracing.Interpreter.close_bracket(">")
     @test_throws ArgumentError Raytracing.Interpreter.close_bracket("ag ")
     @test_throws ArgumentError Raytracing.Interpreter.close_bracket("123")
     @test_throws ArgumentError Raytracing.Interpreter.close_bracket("*")
     @test_throws ArgumentError Raytracing.Interpreter.close_bracket("(1")
end

function assert_is_keyword(token::Token, keyword::KeywordEnum) 
     @assert isa(token.value, KeywordToken) "Token '$(token.value)' is not a KeywordToken"
     @assert token.value.keyword == keyword "Token '$(token.value)' is not equal to keyword '$(keyword)'"
end

function assert_is_identifier(token::Token, identifier::String) 
     @assert isa(token.value, IdentifierToken) "Token '$(token.value)' is not a IdentifierToken"
     @assert token.value.identifier == identifier "expecting identifier '$(identifier)' instead of '$(token.value)'"
end

function assert_is_symbol(token::Token, symbol::String) 
     @assert isa(token.value, SymbolToken) "Token '$(token.value)' is not a SymbolToken"
     @assert token.value.symbol == symbol "expecting symbol '$(symbol)' instead of '$(token.value)'"
end

function assert_is_number(token::Token, number::Float64) 
     @assert isa(token.value, LiteralNumberToken) "Token '$(token.value)' is not a LiteralNumberToken"
     @assert token.value.number == number "Token '$(token.value)' is not equal to number '$(number)'"
end

function assert_is_string(token::Token, string::String) 
     @assert isa(token.value, StringToken) "Token '$(token.value)' is not a StringToken"
     @assert token.value.string == string "Token '$(token.value)' is not equal to string '$(string)'"
end

@testset "test_input_file" begin
     stream = InputStream(IOBuffer("abc   \nd\nef"))

     @test stream.location.line_num == 1
     @test stream.location.col_num == 1

     @test Raytracing.Interpreter.read_char(stream) == "a"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 2

     Raytracing.Interpreter.unread_char(stream, "A")
     @test stream.location.line_num == 1
     @test stream.location.col_num == 1

     @test Raytracing.Interpreter.read_char(stream) == "A"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 2

     @test Raytracing.Interpreter.read_char(stream) == "b"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 3

     @test Raytracing.Interpreter.read_char(stream) == "c"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 4

     skip_whitespaces_and_comments(stream)

     @test Raytracing.Interpreter.read_char(stream) == "d"
     @test stream.location.line_num == 2
     @test stream.location.col_num == 2

     @test Raytracing.Interpreter.read_char(stream) == "\n"
     @test stream.location.line_num == 3
     @test stream.location.col_num == 1

     @test Raytracing.Interpreter.read_char(stream) == "e"
     @test stream.location.line_num == 3
     @test stream.location.col_num == 2

     @test Raytracing.Interpreter.read_char(stream) == "f"
     @test stream.location.line_num == 3
     @test stream.location.col_num == 3

     @test Raytracing.Interpreter.read_char(stream) == ""
end

@testset "test_skip_whitespaces_and_comments" begin
     stream = IOBuffer("""
     # This is a comment
     # This is another comment
     #=
     this is a longer
     comment that i want to avoid
     =# 

     #=
     this is anothe long comment where i want to use
     the symbols = and # indifferently, because inside
     this sequence made of # + = and = + # i want to
     ignore anything.
     =# 
     FLOAT var(150) # Comment at the end of the line

""")

     scene = parse_scene(InputStream(stream, "test_skip_whitespaces_and_comments"))

     @test length(scene.float_variables) == 1
     @test "var" ∈ keys(scene.float_variables)
     @test scene.float_variables["var"] == 150.0

end


@testset "test_lexer" begin

     stream = IOBuffer("""
     # This is a comment
     # This is another comment
     NEW MATERIAL sky_material(
          DIFFUSE(IMAGE("my file.pfm")),
          <5.0, 500.0, 300.0>
     ) # Comment at the end of the line
""")

     input_file = InputStream(stream, "test_lexer")

     assert_is_keyword(read_token(input_file), Raytracing.Interpreter.NEW)
     assert_is_keyword(read_token(input_file), Raytracing.Interpreter.MATERIAL)
     assert_is_identifier(read_token(input_file), "sky_material")
     assert_is_symbol(read_token(input_file), "(")
     assert_is_keyword(read_token(input_file), Raytracing.Interpreter.DIFFUSE)
     assert_is_symbol(read_token(input_file), "(")
     assert_is_keyword(read_token(input_file), Raytracing.Interpreter.IMAGE)
     assert_is_symbol(read_token(input_file), "(")
     assert_is_string(read_token(input_file), "my file.pfm")
     assert_is_symbol(read_token(input_file), ")")

     @test 1==1
end

@testset "test_parser" begin
     stream = IOBuffer("""
     FLOAT clock(150)

     MATERIAL sky_material(
          DIFFUSE(UNIFORM(<0, 0, 0>)),
          UNIFORM(<0.7, 0.5, 1>)
     )

     # Here is a comment

     MATERIAL ground_material(
          DIFFUSE(CHECKERED(<0.3, 0.5, 0.1>,
                              <0.1, 0.2, 0.5>, 4)),
          UNIFORM(<0, 0, 0>)
     )

     MATERIAL sphere_material(
          SPECULAR(UNIFORM(<0.5, 0.5, 0.5>)),
          UNIFORM(<0, 0, 0>)
     )

     PLANE (sky_material, TRANSLATION([0, 0, 100]) * ROTATION_Y(clock))
     PLANE (ground_material, IDENTITY)

     SPHERE(sphere_material, TRANSLATION([0, 0, 1]))

     CAMERA(PERSPECTIVE, ROTATION_Z(30) * TRANSLATION([-4, 0, 1]), 2.0)
     """)

     scene = parse_scene(InputStream(stream, "test_parser"))

     # Check that the FLOAT variables are ok

     @test length(scene.float_variables) == 1
     @test "clock" ∈ keys(scene.float_variables)
     @test scene.float_variables["clock"] == 150.0

     # Check that the materials are ok

     @test length(scene.materials) == 3
     @test "sphere_material" ∈ keys(scene.materials)
     @test "sky_material" ∈ keys(scene.materials)
     @test "ground_material" ∈ keys(scene.materials)

     sphere_material = scene.materials["sphere_material"]
     sky_material = scene.materials["sky_material"]
     ground_material = scene.materials["ground_material"]

     @test isa(sky_material.brdf, DiffuseBRDF)
     @test isa(sky_material.brdf.pigment, UniformPigment)
     @test sky_material.brdf.pigment.color ≈ RGB(0., 0., 0.)

     @test isa(ground_material.brdf, DiffuseBRDF)
     @test isa(ground_material.brdf.pigment, CheckeredPigment)
     @test ground_material.brdf.pigment.color1 ≈ RGB(0.3, 0.5, 0.1)
     @test ground_material.brdf.pigment.color2 ≈ RGB(0.1, 0.2, 0.5)
     @test ground_material.brdf.pigment.num_steps == 4

     @test isa(sphere_material.brdf, SpecularBRDF)
     @test isa(sphere_material.brdf.pigment, UniformPigment)
     @test sphere_material.brdf.pigment.color ≈ RGB(0.5, 0.5, 0.5)

     @test isa(sky_material.emitted_radiance, UniformPigment)
     @test sky_material.emitted_radiance.color ≈ RGB(0.7, 0.5, 1.0)
     @test isa(ground_material.emitted_radiance, UniformPigment)
     @test ground_material.emitted_radiance.color ≈ RGB(0, 0, 0)
     @test isa(sphere_material.emitted_radiance, UniformPigment)
     @test sphere_material.emitted_radiance.color ≈ RGB(0, 0, 0)

     # Check that the shapes are ok

     @test length(scene.world.shapes) == 3
     @test isa(scene.world.shapes[1], Plane)
     @test scene.world.shapes[1].T ≈ translation(Vec(0, 0, 100)) * rotation_y(150.0)
     @test isa(scene.world.shapes[2], Plane)
     @test scene.world.shapes[2].T ≈ Transformation()
     @test isa(scene.world.shapes[3], Sphere)
     @test scene.world.shapes[3].T ≈ translation(Vec(0, 0, 1))

     # Check that the camera is ok

     @test isa(scene.camera, PerspectiveCamera)
     @test scene.camera.T ≈ rotation_z(30.0) * translation(Vec(-4, 0, 1))
     @test 2.0 ≈ scene.camera.d
end

@testset "test_parser_undefined_material" begin
     # Check that unknown materials raises a GrammarError
     stream = IOBuffer("""
     plane(this_material_does_not_exist, identity)
     """)

     @test_throws GrammarError parse_scene(InputStream(stream))
end

@testset "test_parser_double_camera" begin
     # Check that defining two cameras in the same file raises a GrammarError
     stream = IOBuffer("""
     camera(perspective, rotation_z(30) * translation([-4, 0, 1]), 1.0, 1.0)
     camera(orthogonal, identity, 1.0, 1.0)
     """)

    @test_throws GrammarError parse_scene(InputStream(stream))
end


@testset "test_math_operations_1" begin
     stream = IOBuffer(""" 
          FLOAT var1(1.0)
          FLOAT var2(2.0)
          FLOAT var3(0.5)
          FLOAT var4(0.5)
          FLOAT var5(-var1 * var2 - 0.5/(var3 + var4))

          ASSERT(var5, -2.5)
     """)

     scene = parse_scene(InputStream(stream, "test_math_operations_1"))
     @test 1==1
end

@testset "test_math_operations_2" begin
     stream = IOBuffer(""" 
          FLOAT var1(1.0)
          FLOAT var2(2.0)
          FLOAT var3(0.5)
          FLOAT var4(0.5)
          FLOAT var5(-var1 * var2 - 0.5/(var3 + var4))

          ASSERT(var5, 2.5)
     """)

     @test_throws AssertionError parse_scene(InputStream(stream))
end

@testset "test_return_token_value_1" begin
     stream = IOBuffer(""" 
          VECTOR try( ([1,2,3] + [3,2,1])*2.0 - [1,1,1] )
          ASSERT (try*1.0, -1.0*[-7,-7,-7])
     """)

     scene = parse_scene(InputStream(stream, "test_return_token_value_1"))
     @test 1==1
end

@testset "test_return_token_value_2" begin
     stream = IOBuffer(""" 
          VECTOR try( ([1,2,3] + [3,2,1])*2.0 - [1,1,1] )
          ASSERT (try, -1.0*[7,-7,-7])
     """)

     @test_throws AssertionError parse_scene(InputStream(stream))
end


@testset "test_parse_VECTOR_1" begin
     stream = IOBuffer(""" 
          VECTOR v1([1,2,3])
          VECTOR v2([4,5,6] * 1.0 - v1)
          ASSERT(v2-v1*0, 3*[1,1,1] )
     """)

     scene = parse_scene(InputStream(stream, "test_parse_VECTOR_1"))
     @test 1==1
end

@testset "test_parse_VECTOR_2" begin
     stream = IOBuffer(""" 
          VECTOR v1([1,2,3])
          VECTOR v2([4,5,6] * 1.0 - v1)
          ASSERT(v2-v1*0, 1*[1,1,1] )
     """)

     @test_throws AssertionError parse_scene(InputStream(stream))
end

@testset "test_parse_COLOR_1" begin
     stream = IOBuffer(""" 
          COLOR c1(<1,2,3>)
          COLOR c2(<4,5,6> * 1.0 - c1)
          ASSERT(c2-c1*0, 3*<1,1,1> )
     """)

     scene = parse_scene(InputStream(stream, "test_parse_COLOR_1"))
     @test 1==1
end

@testset "test_parse_COLOR_2" begin
     stream = IOBuffer(""" 
          COLOR c1(<1,2,3>)
          COLOR c2(<4,5,6> * 1.0 - c1)
          ASSERT(c2-c1*0, 0*<1,1,1> )
     """)

     @test_throws AssertionError parse_scene(InputStream(stream))
end

@testset "test_ASSERT_1" begin
     stream = IOBuffer(""" 
          ASSERT(1.0, 1, "=")
          ASSERT(1.0, 1, "==")
          ASSERT(1.0, 2.0, "<")
          ASSERT(1.0, 2.0, "<=")
          ASSERT(3, 2.0, ">")
          ASSERT(3, 2.0, ">=")
     """)

     scene = parse_scene(InputStream(stream, "test_ASSERT_1"))
     @test 1==1
end

@testset "test_ASSERT_2" begin
     @test_throws AssertionError parse_scene(InputStream(IOBuffer("""ASSERT(0.0, 1, "=")""")))
     @test_throws AssertionError parse_scene(InputStream(IOBuffer("""ASSERT(0.0, 1, "==")""")))
     @test_throws AssertionError parse_scene(InputStream(IOBuffer("""ASSERT(1.0, 1, ">")""")))
     @test_throws AssertionError parse_scene(InputStream(IOBuffer("""ASSERT(1.0, 2, ">=")""")))
     @test_throws AssertionError parse_scene(InputStream(IOBuffer("""ASSERT(1.0, 1, "<")""")))
     @test_throws AssertionError parse_scene(InputStream(IOBuffer("""ASSERT(1.0, 0, "<=")""")))
end


@testset "test_tutorial_basic_syntax.txt" begin
     # cd("..")
     #open("/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt") do stream
     open("./examples/tutorial_basic_syntax.txt") do stream
          scene = parse_scene(InputStream(stream, "tutorial_basic_syntax.txt"))
          @test 1==1
     end

     @test 1==1
     # cd("test")
end

@testset "test_demo_world_B.txt" begin
     # cd("..")
     #open("/home/runner/work/Raytracing/Raytracing/examples/demo_world_B.txt") do stream
     open("./examples/demo_world_B.txt") do stream
          scene = parse_scene(InputStream(stream, "/home/runner/work/Raytracing/Raytracing/examples/demo_world_B.txt"))
          @test 1==1
     end

     @test 1==1
     # cd("test")
end
