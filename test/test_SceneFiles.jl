# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


@testset "test_isdigit" begin
     @test Raytracing.isdigit("2")
     @test Raytracing.isdigit("1")
     @test !Raytracing.isdigit("10")
     @test !Raytracing.isdigit("a")
     @test !Raytracing.isdigit("")
end

@testset "test_isdecimal" begin
     @test Raytracing.isdecimal("2")
     @test Raytracing.isdecimal("1123129")
     @test !Raytracing.isdecimal("10.9")
     @test !Raytracing.isdecimal("ag")
     @test !Raytracing.isdecimal("10ag")
     @test !Raytracing.isdecimal("")
end

@testset "test_isalpha" begin
     @test Raytracing.isalpha("a")
     @test Raytracing.isalpha("ADcLopnb__o")
     @test !Raytracing.isalpha("1")
     @test !Raytracing.isalpha("aD1sd")
     @test !Raytracing.isalpha("")
end

@testset "test_isalnum" begin
     @test Raytracing.isalnum("adf_g")
     @test Raytracing.isalnum("1239")
     @test Raytracing.isalnum("A1__Def98")
     @test !Raytracing.isalnum("78KO.b")
     @test !Raytracing.isalnum("78KO@b")
     @test !Raytracing.isalnum("")
end


function assert_is_keyword(token::Token, keyword::KeywordEnum) 
     @test isa(token, KeywordToken)
     if token.keyword == keyword 
          @test token.keyword == keyword
     else
          throw(Exception("Token '$(token)' is not equal to keyword '$(keyword)'"))
     end
end

function assert_is_identifier(token::Token, identifier::String) 
     @test isa(token, IdentifierToken)
     if token.identifier == identifier
          @test token.identifier == identifier
     else 
          throw(Exception("expecting identifier '$(identifier)' instead of '$(token)'"))
     end
end

function assert_is_symbol(token::Token, symbol::String) 
     @test isa(token, SymbolToken)
     if token.symbol == symbol
          @test token.symbol == symbol
     else 
          throw(Exception("expecting symbol '$(symbol)' instead of '$(token)'"))
     end
end

function assert_is_number(token::Token, number::Float64) 
     @test isa(token, LiteralNumberToken)
     if token.value == number
          @test token.value == number
     else
          throw(Exception("Token '$(token)' is not equal to number '$(number)'"))
     end
end

function assert_is_string(token::Token, string::String) 
     @test isa(token, StringToken)
     if token.value == string
          @test token.value == string
     else
          throw(Exception("Token '$(token)' is not equal to string '$(string)'"))
     end
end

@testset "test_input_file" begin
     stream = InputStream(IOBuffer("abc   \nd\nef"))

     @test stream.location.line_num == 1
     @test stream.location.col_num == 1

     @test Raytracing.read_char(stream) == "a"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 2

     Raytracing.unread_char(stream, "A")
     @test stream.location.line_num == 1
     @test stream.location.col_num == 1

     @test Raytracing.read_char(stream) == "A"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 2

     @test Raytracing.read_char(stream) == "b"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 3

     @test Raytracing.read_char(stream) == "c"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 4

     skip_whitespaces_and_comments(stream)

     @test Raytracing.read_char(stream) == "d"
     @test stream.location.line_num == 2
     @test stream.location.col_num == 2

     @test Raytracing.read_char(stream) == "\n"
     @test stream.location.line_num == 3
     @test stream.location.col_num == 1

     @test Raytracing.read_char(stream) == "e"
     @test stream.location.line_num == 3
     @test stream.location.col_num == 2

     @test Raytracing.read_char(stream) == "f"
     @test stream.location.line_num == 3
     @test stream.location.col_num == 3

     @test Raytracing.read_char(stream) == ""
end

@testset "test_lexer" begin

     stream = IOBuffer("""
     # This is a comment
     # This is another comment
     new material sky_material(
          diffuse(image("my file.pfm")),
          <5.0, 500.0, 300.0>
     ) # Comment at the end of the line
""")

     input_file = InputStream(stream)

     assert_is_keyword(read_token(input_file), KeywordEnum.NEW)
     assert_is_keyword(read_token(input_file), KeywordEnum.MATERIAL)
     assert_is_identifier(read_token(input_file), "sky_material")
     assert_is_symbol(read_token(input_file), "(")
     assert_is_keyword(read_token(input_file), KeywordEnum.DIFFUSE)
     assert_is_symbol(read_token(input_file), "(")
     assert_is_keyword(read_token(input_file), KeywordEnum.IMAGE)
     assert_is_symbol(read_token(input_file), "(")
     assert_is_string(read_token(input_file), "my file.pfm")
     assert_is_symbol(read_token(input_file), ")")
end