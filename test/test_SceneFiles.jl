# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



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
          throw(Exception("expecting identifier '$(identifier})' instead of '$(token})'"))
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

function assert_is_string(token::Token, s::String) 
    @test isa(token, StringToken)
    @test token.string == s, f"Token '{token}' is not equal to string '{s}'"
end

@testset "test_input_file" begin
     stream = InputStream(StringIO("abc   \nd\nef"))

     @test stream.location.line_num == 1
     @test stream.location.col_num == 1

     @test read_char(stream) == "a"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 2

     unread_char(stream, "A")
     @test stream.location.line_num == 1
     @test stream.location.col_num == 1

     @test read_char(stream) == "A"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 2

     @test read_char(stream) == "b"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 3

     @test read_char(stream) == "c"
     @test stream.location.line_num == 1
     @test stream.location.col_num == 4

     skip_whitespaces_and_comments(stream)

     @test read_char(stream) == "d"
     @test stream.location.line_num == 2
     @test stream.location.col_num == 2

     @test read_char(stream) == "\n"
     @test stream.location.line_num == 3
     @test stream.location.col_num == 1

     @test read_char(stream) == "e"
     @test stream.location.line_num == 3
     @test stream.location.col_num == 2

     @test read_char(stream) == "f"
     @test stream.location.line_num == 3
     @test stream.location.col_num == 3

     @test read_char(stream) == ""
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