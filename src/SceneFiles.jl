# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

WHITESPACE = [" ", "\t", "\n", "\r"]
SYMBOLS = ["(", ")", "<", ">", "[", "]", "*"]
LETTERS = [
     'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 
     'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 
     'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
     'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 
     '_',
]
NUMBERS = ['0', '1', '2', '3', '4', '5', '6','7', '8', '9']


"""
   isdigit(a::String) :: Bool
   
Return `true` if `a` is a sigle digit, `false` otherwise.
"""
function isdigit(a::String)
     !isnothing(tryparse(Int64, a)) || (return false)
     val = parse(Int64, a)
     bool = 0≤val≤9 ? true : false
     return bool
end


"""
   isdecimal(a::String) :: Bool
   
Return `true` if `a` is an integer number, `false` otherwise.
"""
function isdecimal(a::String)
     !isnothing(tryparse(Int64, a)) || (return false)
     val = parse(Int64, a)
     bool = val≥0 ? true : false
     return bool
end


"""
   isalpha(a::String) :: Bool
   
Return `true` if `a` is a string made only of the 26 english letters (capitalized
or not) and/or the underscore symbol "_" , `false` otherwise.
"""
function isalpha(a::String)
     for ch in a
          (ch ∈ LETTERS) || (return false)
     end
     !(a=="") || (return false)
     return true 
end


"""
   isalnum(a::String) :: Bool
   
Return `true` if `a` is a string made only of the 26 english letters (capitalized
or not), the underscore symbol "_" and the 10 basic digits, `false` otherwise.
"""
function isalnum(a::String)
     for ch in a
          (ch ∈ LETTERS || ch ∈ NUMBERS) || (return false)
     end
     !(a=="") || (return false)
     return true 
end


##########################################################################################92


"""
    SourceLocation(file_name::String, line_num::Int64, col_num::Int64)

A specific position in a source file.

## Arguments

- `file_name::String` : the name of the file, or the empty string if there is no 
  file associated with this location (e.g., because the source code was provided as 
  a memory stream, or through a network connection)

- `line_num::Int64` : number of the line (starting from 1)

- `col_num::Int64` : number of the column (starting from 1)
"""
mutable struct SourceLocation
    file_name::String
    line_num::Int64
    col_num::Int64
    SourceLocation(fn::String, ln::Int64 = 0, cn::Int64 = 0) = new(fn, ln, cn)
end

"""
     copy(location::SourceLocation) :: SourceLocation

Return a shallow copy of the input source location.

See also: [`SourceLocation`](@ref)
"""
function copy(location::SourceLocation)
     copy = SourceLocation(
               location.file_name,
               location.line_num,
               location.col_num
          )
     return copy
end


##########################################################################################92


"""
     @enum KeywordEnum

Enumeration for all the possible keywords recognized by the lexer:
```ditaa
|:-----------------:|:-----------------:|:-----------------:|
| NEW = 1           | CHECKERED = 8     | SCALING = 15      |
| MATERIAL = 2      | IMAGE = 9         | ORTHOGONAL = 17   |
| PLANE = 3         | IDENTITY = 10     | ORTHOGONAL = 17   |
| SPHERE = 4        | TRANSLATION = 11  | PERSPECTIVE = 18  |
| DIFFUSE = 5       | ROTATION_X = 12   | FLOAT = 19        |
| SPECULAR = 6      | ROTATION_Y = 13   |
| UNIFORM = 7       | ROTATION_Z = 14   |
|:-----------------:|:-----------------:|:-----------------:|
```
"""
@enum KeywordEnum begin
    NEW = 1
    MATERIAL = 2
    PLANE = 3
    SPHERE = 4
    DIFFUSE = 5
    SPECULAR = 6
    UNIFORM = 7
    CHECKERED = 8
    IMAGE = 9
    IDENTITY = 10
    TRANSLATION = 11
    ROTATION_X = 12
    ROTATION_Y = 13
    ROTATION_Z = 14
    SCALING = 15
    CAMERA = 16
    ORTHOGONAL = 17
    PERSPECTIVE = 18
    FLOAT = 19
end

KEYWORDS = Dict{String, KeywordEnum}(
    "new" => NEW,
    "material" => MATERIAL,
    "plane" => PLANE,
    "sphere" => SPHERE,
    "diffuse" => DIFFUSE,
    "specular" => SPECULAR,
    "uniform" => UNIFORM,
    "checkered" => CHECKERED,
    "image" => IMAGE,
    "identity" => IDENTITY,
    "translation" => TRANSLATION,
    "rotation_x" => ROTATION_X,
    "rotation_y" => ROTATION_Y,
    "rotation_z" => ROTATION_Z,
    "scaling" => SCALING,
    "camera" => CAMERA,
    "orthogonal" => ORTHOGONAL,
    "perspective" => PERSPECTIVE,
    "float" => FLOAT,
)


"""
    KeywordToken(keyword::KeywordEnum)

A token containing a keyword of the Photorealistic Object Applications Language.

See also: [`KeywordEnum`](@ref)
"""
struct KeywordToken
    keyword::KeywordEnum
end


"""
    IdentifierToken(identifier::String)

A token containing an identifier, i.e. a name of a variable.
"""
struct IdentifierToken
    identifier::String
end


"""
     StringToken(string::String)

A token containing a literal string, i.e. a sentence placed inside
two  double quotes ("...") symbols.
"""
struct StringToken
    string::String
end


"""
    LiteralNumberToken(number::Float64)

A token containing a literal number.
"""
struct LiteralNumberToken
    number::Float64
end


"""
    SymbolToken(symbol::String)

A token containing a recognised symbol by the Photorealistic Object 
Applications Language.
"""
struct SymbolToken
    symbol::String
end


"""
    StopToken()

A token signalling the end of a file.
"""
struct StopToken
end


"""
    Token(
          location::SourceLocation,
          value::Union{  
               KeywordToken, 
               IdentifierToken, 
               StringToken,
               LiteralNumberToken,
               SymbolToken, 
               StopToken}
          )

A lexical token, used when parsing a scene file.

## Arguments

- `location::SourceLocation`: location of the last char read

- `value` : one of the basic 6 token types:
  - [`KeywordToken`](@ref)
  - [`IdentifierToken`](@ref)
  - [`StringToken`](@ref)
  - [`LiteralNumberToken`](@ref)
  - [`SymbolToken`](@ref)
  - [`StopToken`](@ref)

See also: [`SourceLocation`](@ref)
"""
struct Token
     location::SourceLocation
     value::Union{  
          KeywordToken, 
          IdentifierToken, 
          StringToken,
          LiteralNumberToken,
          SymbolToken, 
          StopToken}
end

"""
     GrammarError <: Exception(
          location::SourceLocation
          message::String
     )

An error found by the lexer/parser while reading a scene file.

## Arguments

- `location::SourceLocation` : location of the last char read

- `message::String` : a user-frendly error message

See also: [`SourceLocation`](@ref)
"""
struct GrammarError <: Exception 
    location::SourceLocation
    message::String
end

"""
    InputStream(
        stream::IO,
        location::SourceLocation,
        saved_char::String,
        saved_location::SourceLocation,
        tabulations::Int64,
        saved_token::Union{Token, Nothing},
    )

A high-level wrapper around a stream, used to parse scene files
This class implements a wrapper around a stream, with the following 
additional capabilities:
- It tracks the line number and column number;
- It permits to "un-read" characters and tokens.

## Arguments

- `stream::IO` : stream to read from

- `location::SourceLocation` : location of the last char read

- `saved_char::String` : the last char read

- `saved_location::SourceLocation` : location where `saved_char` is in the file

- `tabulations::Int64`: number of space a tab command gives

- `saved_token::Union{Token, Nothing}` : the last token found

## Constructors

-    InputStream(
          stream::IO, 
          file_name::String = "", 
          tabulations::Int64 = 8
          ) = new(
               stream, 
               SourceLocation(file_name, 1, 1), 
               "", 
               SourceLocation(file_name, 1, 1), 
               tabulations, 
               nothing
               )

-    InputStream(
          s::IO,
          l::SourceLocation,
          sc::String,
          sl::SourceLocation,
          t::Int64,
          st::Union{Token, Nothing}
          ) = new(s,l,sc,sl,t,st)


See also: [`SourceLocation`](@ref), [`Token`](@ref)
"""
mutable struct InputStream
     stream::IO
     location::SourceLocation
     saved_char::String
     saved_location::SourceLocation
     tabulations::Int64
     saved_token::Union{Token, Nothing}

     InputStream(
          stream::IO, 
          file_name::String = "", 
          tabulations::Int64 = 8
          ) = new(
               stream, 
               SourceLocation(file_name, 1, 1), 
               "", 
               SourceLocation(file_name, 1, 1), 
               tabulations, 
               nothing
               )

     InputStream(
          s::IO,
          l::SourceLocation,
          sc::String,
          sl::SourceLocation,
          t::Int64,
          st::Union{Token, Nothing}
          ) = new(s,l,sc,sl,t,st)
end


##########################################################################################92


"""
    update_pos(inputstream::InputStream, ch::String)

Update `location` after having read `ch` from the stream.

See also: [`SourceLocation`](@ref)
"""
function update_pos(inputstream::InputStream, ch::String)
     if ch == ""
          nothing
     elseif ch == "\n"
          inputstream.location.line_num += 1
          inputstream.location.col_num = 1
     elseif ch == "\t"
          inputstream.location.col_num += inputstream.tabulations
     else
          inputstream.location.col_num += 1
     end
end


"""
     read_char(inputstream::InputStream) :: String

Read a new character from the stream.
Calls internally [`update_pos`](@ref).

See also: [`InputStream`](@ref), [`unread_char`](@ref)
"""
function read_char(inputstream::InputStream)
     if inputstream.saved_char ≠ ""
          ch = inputstream.saved_char
          inputstream.saved_char = ""
     elseif eof(inputstream.stream)
          ch = ""
     else
          ch = String([read(inputstream.stream, UInt8)])
     end

     inputstream.saved_location = copy(inputstream.location)  # shallow copy ?
     update_pos(inputstream, ch)

     return ch
end


"""
     unread_char(inputstream::InputStream, ch::String)

Push a character back to the stream.

See also: [`InputStream`](@ref), [`read_char`](@ref)
"""
function unread_char(inputstream::InputStream, ch::String)
     @assert inputstream.saved_char == ""
     inputstream.saved_char = ch
     inputstream.location = copy(inputstream.saved_location) # shallow copy ?
end


"""
     skip_whitespaces_and_comments(inputstream::InputStream)

Keep reading characters until a non-whitespace/non-comment character is found.
Calls internally [`read_char`](@ref) and [`unread_char`](@ref), and it's used
inside the main function [`read_token`](@ref).

See also: [`InputStream`](@ref)
"""        
function skip_whitespaces_and_comments(inputstream::InputStream)
     ch = read_char(inputstream)
     while ( (ch in WHITESPACE) || (ch == "#") )
          if ch == "#"
               # It's a comment! Keep reading until the end of the line 
               #(include the case "", the end-of-file)
               while read_char(inputstream) ∉ ["\r", "\n", ""]
                    nothing
               end
          end
          ch = read_char(inputstream)
          !(ch == "") || (return nothing)
     end
     
     # Put the non-whitespace character back
     unread_char(inputstream, ch)
     nothing
end


"""
     parse_string_token(
          inputstream::InputStream,
          token_location::SourceLocation
          ) ::Token(::SourceLocation, ::StringToken)

Parse a string from the given input `inputstream` and return
that string inside a `Token(::SourceLocation, ::StringToken)` with the given
`token_location`, throwing `GrammarError` in case of exception.
Works calling [`read_char`](@ref), and it's used
inside the main function [`read_token`](@ref).

See also: [`InputStream`](@ref), [`SourceLocation`](@ref)
[`Token`](@ref), [`StringToken`](@ref), [`GrammarError`](@ref)
"""
function parse_string_token(inputstream::InputStream, token_location::SourceLocation)
     token = ""
     while true
          ch = read_char(inputstream)

          if ch == "\""
               break
          end
          if ch == ""
               throw(GrammarError(token_location, "unterminated string"))
          end

          token *= ch
     end

    return Token(token_location, StringToken(token))
end


"""
     parse_float_token(
          inputstream::InputStream, 
          first_char::String, 
          token_location::SourceLocation
          ) :: Token{SourceLocation, LiteralNumberToken}

Parse a float from the given input `inputstream` and return
that float inside a `Token(::SourceLocation, ::LiteralNumberToken)` with the given
`token_location`, throwing `GrammarError` in case of exception.
Works calling [`read_char`](@ref) and [`unread_char`](@ref), and it's used
inside the main function [`read_token`](@ref).


See also: [`InputStream`](@ref), [`SourceLocation`](@ref)
[`Token`](@ref), [`LiteralNumberToken`](@ref), [`GrammarError`](@ref)
"""
function parse_float_token(inputstream::InputStream, first_char::String, token_location::SourceLocation) :: LiteralNumberToken
     token = first_char

     while true
          ch = read_char(inputstream)

          if !( isdigit(ch) || (ch == ".") || (ch ∈ ["e", "E"]) )
               unread_char(inputstream, ch)
               break
          end

          token *= ch
     end

     try
          value = float(token)
     catch ValueError
          throw(
               GrammarError(
                    token_location, 
                    """ "$(token)" is an invalid floating-point number"""
               )
          )
     end

     return Token(token_location, LiteralNumberToken(value))
end


"""
     parse_keyword_or_identifier_token(
          inputstream::InputStream,
          first_char::String,
          token_location::SourceLocation
          ) ::Union{
                    Token(::SourceLocation, ::KeywordToken),
                    Token(::SourceLocation, ::IdentifierToken)
                    }

Parse a keyword or an identifier from the given input `inputstream` and return
that keyword/identifier inside respectively a `Token(::SourceLocation, ::KeyworkdToken)` 
or a `Token(::SourceLocation, ::IdentifierToken)` with the given `token_location`, 
throwing `GrammarError` in case of exception.
Works calling [`read_char`](@ref) and [`unread_char`](@ref), and it's used
inside the main function [`read_token`](@ref).


See also: [`InputStream`](@ref), [`SourceLocation`](@ref)
[`Token`](@ref), [`LiteralNumberToken`](@ref), [`GrammarError`](@ref)
"""
function parse_keyword_or_identifier_token(
               inputstream::InputStream, 
               first_char::String, 
               token_location::SourceLocation
          )
     
     token = first_char

     while true
          ch = read_char(inputstream)

          if !isalnum(ch)
               unread_char(inputstream, ch)
               break
          end

          token *= ch
     end


     try
          # If it is a keyword, it must be listed in the KEYWORDS dictionary
          return Token(token_location, KeywordToken(KEYWORDS[token]))
     catch KeyError
          # If we got KeyError, it is not a keyword and thus it must be an identifier
          return Token(token_location, IdentifierToken(token))
     end
end


"""
     read_token(inputstream::InputStream) :: Token

Read one of the 6 basic tokens from the stream, raising `GrammarError` if a 
lexical error is found.
Calls internally the following functions:
- [`skip_whitespaces_and_comments`](@ref)
- [`read_char`](@ref)
- [`isdecimal`](@ref)
- [`isalpha`](@ref)
- [`copy(::SourceLocation)`](@ref)
- [`parse_string_token`](@ref) for [`StringToken`](@ref)
- [`parse_float_token`](@ref) for [`LiteralNumberToken`](@ref)
- [`parse_keyword_or_identifier_token`](@ref) for [`KeywordToken`](@ref)
  and [`IdentifierToken`](@ref)


See also: [`InputStream`](@ref), [`Token`](@ref), [`SymbolToken`](@ref), 
[`StopToken`](@ref), [`GrammarError`](@ref),
"""
function read_token(inputstream::InputStream)

     if !isnothing(inputstream.saved_token)
          result = inputstream.saved_token
          inputstream.saved_token = nothing
          return result
     end

     skip_whitespaces_and_comments(inputstream)

     # At this point we're sure that ch does *not* contain a whitespace character
     ch = read_char(inputstream)
     if ch == ""
          # No more characters in the file, so return a StopToken
          return Token(inputstream.location, StopToken())
     end

     # At this point we must check what kind of token begins with the "ch" character 
     # (which has been put back in the stream with self.unread_char). First, we save 
     # the position in the stream.
     token_location = copy(inputstream.location)  # shallow copy ?

     if ch ∈ SYMBOLS
          # One-character symbol, like '(' or ','
          return Token(token_location, SymbolToken(ch))
     elseif ch == "\"" 
          # A literal string (used for file names)
          return parse_string_token(inputstream, token_location)
     elseif ( isdecimal(ch) || (ch ∈ ["+", "-", "."]) )
          # A floating-point number
          return parse_float_token(inputstream, ch, token_location)
     elseif isalpha(ch)
          # Since it begins with an alphabetic character, it must either be 
          # a keyword or a identifier
          return parse_keyword_or_identifier_token(inputstream, ch, token_location)
     else
          # We got some weird character, like '@` or `&`
          throw(GrammarError(inputstream.location, "Invalid character $(ch)"))
     end
end


"""
    unread_token(inputstream::InputStream, token::Token)

Make as if `token` were never read from `inputstream`.

See also: [`InputStream`](@ref), [`Token`](@ref), [`read_token`](@ref)
"""
function unread_token(inputstream::InputStream, token::Token)
    @assert isnothing(inputstream.saved_token) "$(inputstream.saved_token) ≠ nothing "
    inputstream.saved_token = token
end

##########################################################################################92


"""
     Scene(
          materials::Dict{String, Material} = Dict{String, Material}(),
          world::World = World(),
          camera::Union{Camera, Nothing} = nothing,
          float_variables::Dict{String, Float64} = Dict{String, Float64}(),
          overridden_variables::Set{String} = Set{String}() 
     )

A scene read from a scene file.

See also: [`Material`](@ref), [`World`](@ref), [`Camera`](@ref)
"""
struct Scene
     materials::Dict{String, Material}
     world::World
     camera::Union{Camera, Nothing}
     float_variables::Dict{String, Float64}
     overridden_variables::Set{String}
     Scene(
          m::Dict{String, Material} = Dict{String, Material}(),
          w::World = World(),
          c::Union{Camera, Nothing} = nothing,
          fv::Dict{String, Float64} = Dict{String, Float64}(),
          ov::Set{String} = Set{String}() 
     ) = new(m,w,c,fv,ov)
end

"""
     expect_symbol(inputstream::InputStream, symbol::String)

Read a token from `input_file` and check that it matches `symbol`.
"""
function expect_symbol(inputstream::InputStream, symbol::String)
     token = read_token(inputstream)
     if (typeof(token.value) ≠ SymbolToken) || (token.value.symbol ≠ symbol)
          throw(GrammarError(token.location, "got $(token) insted of $(symbol)"))
     end
end

"""
     expect_keywords(input_file::InputStream, keywords::Vector{KeywordEnum}) :: KeywordEnum

Read a token from `input_file` and check that it is one of the keywords in `keywords`.

See also: [`InputStream`](@ref), [`KeywordEnum`](@ref), [`Token`](@ref)
"""
function expect_keywords(input_file::InputStream, keywords::Vector{KeywordEnum})
     token = read_token(input_file)
     if !isa(token, KeywordToken)
          throw(GrammarError(token.location, "expected a keyword instead of \"$(token)\" "))
     end

     if token.keyword ∉ keywords
          throw(GrammarError(
               token.location,
               "expected one of the keywords $([String(x)*"," for x in keywords]...)) instead of \"$(token)\""
          ))
     end

     return token.keyword
end


"""
     expect_number(input_file::InputStream, scene::Scene) :: Float64

Read a token from `input_file` and check that it is either a literal number 
or a variable in `scene`, and return the number value.

See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref)
"""
function expect_number(input_file::InputStream, scene::Scene)
     token = read_token(input_file)
     if !isa(token, LiteralNumberToken)
          return token.value
     elseif !isa(token, IdentifierToken)
          variable_name = token.identifier
          if variable_name ∉ scene.float_variables
               throw(GrammarError(token.location, "unknown variable \"$(token)\""))
          end
          return scene.float_variables[variable_name]
     end

     throw(GrammarError(token.location, "got \"$(token)\" instead of a number"))
end


"""
     expect_string(input_file::InputStream) :: String

Read a token from `input_file` and check that it is a literal string.
Return the value of the string (a ``str``).
"""
function expect_string(input_file::InputStream)
    token = read_token(input_file)
    if (typeof(token.value) ≠ StringToken)
          throw(GrammarError(token.location, "got $(token) instead of a string"))
    end
    return token.value.string
end

"""
Read a token from `input_file` and check that it is an identifier.
Return the name of the identifier.
"""
function expect_identifier(input_file::InputStream)
     token = read_token(input_file)
     if (typeof(token.value) ≠ IdentifierToken)
          throw(GrammarError(token.location, "got $(token) instead of an identifier"))
    end
end


"""
    parse_vector(input_file::InputStream, scene::Scene) :: Vec

Parse a vector from the given input `inputstream`.
Call internally [`expect_number`](@ref) and [`expect_symbol`](@ref).
    
See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref)
"""
function parse_vector(input_file::InputStream, scene::Scene)
     expect_symbol(input_file, "[")
     x = expect_number(input_file, scene)
     expect_symbol(input_file, ",")
     y = expect_number(input_file, scene)
     expect_symbol(input_file, ",")
     z = expect_number(input_file, scene)
     expect_symbol(input_file, "]")

     return Vec(x, y, z)
end

"""
     parse_color(input_file::InputStream, scene::Scene) :: RGB{Float32}

Read the color `input_file` and return it
Call internally ['expect_symbol'](@ref), ['expect_number'](@ref)

See also: ['InputStream'](@ref), ['Scene'](@ref), ['Token'](@ref)
"""
function parse_color(input_file::InputStream, scene::Scene)
    expect_symbol(input_file, "<")
    red = expect_number(input_file, scene)
    expect_symbol(input_file, ",")
    green = expect_number(input_file, scene)
    expect_symbol(input_file, ",")
    blue = expect_number(input_file, scene)
    expect_symbol(input_file, ">")

    return RGB{Float32}(red, green, blue)
end


"""
     parse_pigment(input_file::InputStream, scene::Scene) :: Pigment

Parse a pigment from the given input `inputstream`.
Call internally the following parsing functions:
- [`expect_keywords`](@ref)
- [`expect_symbol`](@ref)
- [`parse_color`](@ref)
- [`expect_number`](@ref)
- [`expect_string`](@ref)
Call internally the following functions and structs of the program
- [`UniformPigment`](@ref)
- [`CheckeredPigment`](@ref)
- [`ImagePigment`](@ref)
- [`load_image`](@ref)
    
See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref), [`Pigment`](@ref)
"""
function parse_pigment(input_file::InputStream, scene::Scene)
     keyword = expect_keywords(input_file, [KeywordEnum.UNIFORM, KeywordEnum.CHECKERED, KeywordEnum.IMAGE])

     expect_symbol(input_file, "(")
     if keyword == KeywordEnum.UNIFORM
          color = parse_color(input_file, scene)
          result = UniformPigment(color)
     elseif keyword == KeywordEnum.CHECKERED
          color1 = parse_color(input_file, scene)
          expect_symbol(input_file, ",")
          color2 = parse_color(input_file, scene)
          expect_symbol(input_file, ",")
          num_of_steps = Int(expect_number(input_file, scene))
          result = CheckeredPigment(color1, color2, num_of_steps)
     elseif keyword == KeywordEnum.IMAGE
          file_name = expect_string(input_file)
          image = open(file_name, "r") do image_file; load_image(image_file); end
          result = ImagePigment(image)
     else
          @assert false "This line should be unreachable"
     end

     expect_symbol(input_file, ")")
     return result
end

"""
     parse_brdf(input_file::InputStream, scene::Scene) :: BRDF

Parse a BRDF from the given input `inputstream`.
Call internally the following parsing functions:
- [`expect_keywords`](@ref)
- [`expect_symbol`](@ref)
- [`parse_pigment`](@ref)
Call internally the following functions and structs of the program
- [`DiffuseBRDF`](@ref)
- [`SpecularBRDF`](@ref)
    
See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref), [`BRDF`](@ref)
"""
function parse_brdf(input_file::InputStream, scene::Scene)
     brdf_keyword = expect_keywords(input_file, [KeywordEnum.DIFFUSE, KeywordEnum.SPECULAR])
     expect_symbol(input_file, "(")
     pigment = parse_pigment(input_file, scene)
     expect_symbol(input_file, ")")

     if (brdf_keyword == KeywordEnum.DIFFUSE)
          return DiffuseBRDF(pigment)
     elseif (brdf_keyword == KeywordEnum.SPECULAR)
          return SpecularBRDF(pigment)
     else
          @assert false "This line should be unreachable"
     end
end

"""
     parse_material(input_file::InputStream, scene::Scene) :: (String, Material)

Parse a Material from the given input `inputstream`.
Call internally the following parsing functions:
- [`expect_identifier`](@ref)
- [`expect_symbol`](@ref)
- [`parse_brdf`](@ref)
- [`parse_pigment`](@ref)
Call internally the following functions and structs of the program
- [`Material`](@ref)
    
See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref), [`Material`](@ref)
"""
function parse_material(input_file::InputStream, scene::Scene)
     name = expect_identifier(input_file)

     expect_symbol(input_file, "(")
     brdf = parse_brdf(input_file, scene)
     expect_symbol(input_file, ",")
     emitted_radiance = parse_pigment(input_file, scene)
     expect_symbol(input_file, ")")

     return name, Material(brdf, emitted_radiance)
end

"""
     parse_transformation(input_file::InputStream, scene::Scene) :: Transformation

Parse a transformation from the given input `inputstream`.
Call internally the following parsing functions:
- [`expect_keywords`](@ref)
- [`expect_symbol`](@ref)
- [`expect_number`](@ref)
- [`parse_vector`](@ref)
- [`read_token`](@ref)
- [`unread_token`](@ref)
Call internally the following functions and structs of the program
- [`Transformation`](@ref)
- [`translation`](@ref)
- [`rotation_x`](@ref)
- [`rotation_y`](@ref)
- [`rotation_z`](@ref)
- [`scaling`](@ref)

See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref)
"""
function parse_transformation(input_file::InputStream, scene::Scene)
     result = Transformation()

     while true
          transformation_kw = expect_keywords(input_file, [
               KeywordEnum.IDENTITY,
               KeywordEnum.TRANSLATION,
               KeywordEnum.ROTATION_X,
               KeywordEnum.ROTATION_Y,
               KeywordEnum.ROTATION_Z,
               KeywordEnum.SCALING,
          ])

          if transformation_kw == KeywordEnum.IDENTITY
               nothing # Do nothing (this is a primitive form of optimization!)
          elseif transformation_kw == KeywordEnum.TRANSLATION
               expect_symbol(input_file, "(")
               result *= translation(parse_vector(input_file, scene))
               expect_symbol(input_file, ")")
          elseif transformation_kw == KeywordEnum.ROTATION_X
               expect_symbol(input_file, "(")
               result *= rotation_x(expect_number(input_file, scene))
               expect_symbol(input_file, ")")
          elseif transformation_kw == KeywordEnum.ROTATION_Y
               expect_symbol(input_file, "(")
               result *= rotation_y(expect_number(input_file, scene))
               expect_symbol(input_file, ")")
          elseif transformation_kw == KeywordEnum.ROTATION_Z
               expect_symbol(input_file, "(")
               result *= rotation_z(expect_number(input_file, scene))
               expect_symbol(input_file, ")")
          elseif transformation_kw == KeywordEnum.SCALING
               expect_symbol(input_file, "(")
               result *= scaling(parse_vector(input_file, scene))
               expect_symbol(input_file, ")")
          end

          # We must peek the next token to check if there is another transformation that is being
          # chained or if the sequence ends. Thus, this is a LL(1) parser.
          next_kw = read_token(input_file)
          if !isa(next_kw, SymbolToken) || (next_kw.symbol != "*")
               # Pretend you never read this token and put it back!
               unread_token(input_file, next_kw)
               break
          end
     end

     return result
end


"""
     parse_sphere(input_file::InputStream, scene::Scene) :: Sphere

Parse a sphere from the given input `inputstream`.
Call internally the following parsing functions:
- [`expect_symbol`](@ref)
- [`expect_identifier`](@ref)
- [`parse_transformation`](@ref)

See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref), [`Sphere`](@ref)
"""
function parse_sphere(input_file::InputStream, scene::Scene)
     expect_symbol(input_file, "(")

     material_name = expect_identifier(input_file)
     if material_name ∉ keys(scene.materials)
          # We raise the exception here because input_file is pointing to the end of the wrong identifier
          throw(GrammarError(input_file.location, "unknown material $(material_name)"))
     end

     expect_symbol(input_file, ",")
     transformation = parse_transformation(input_file, scene)
     expect_symbol(input_file, ")")

     return Sphere(transformation, scene.materials[material_name])
end

"""
     parse_plane(input_file::InputStream, scene::Scene) :: Plane

Parse a plane from the given input `inputstream`.
Call internally the following parsing functions:
- [`expect_symbol`](@ref)
- [`expect_identifier`](@ref)
- [`parse_transformation`](@ref)

See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref), [`Plane`](@ref)
"""
function parse_plane(input_file::InputStream, scene::Scene)
     expect_symbol(input_file, "(")

     material_name = expect_identifier(input_file)
     if material_name ∉ keys(scene.materials)
          # We raise the exception here because input_file is pointing to the end of the wrong identifier
          throw(GrammarError(input_file.location, "unknown material $(material_name)"))
     end
     expect_symbol(input_file, ",")
     transformation = parse_transformation(input_file, scene)
     expect_symbol(input_file, ")")

     return Plane(transformation, scene.materials[material_name])
end


"""
     parse_camera(input_file::InputStream, scene::Scene) :: Camera

Parse a camera from the given input `inputstream`.
Call internally the following parsing functions:
- [`expect_symbol`](@ref)
- [`expect_keywords`](@ref)
- [`expect_number`](@ref)
- [`parse_transformation`](@ref)
Call internally the following functions and structs of the program
- [`OrthogonalCamera`](@ref)
- [`PerspectiveCamera`](@ref)

See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref), [`Camera`](@ref)
"""
function parse_camera(input_file::InputStream, scene::Scene)
     expect_symbol(input_file, "(")
     type_kw = expect_keywords(input_file, [KeywordEnum.PERSPECTIVE, KeywordEnum.ORTHOGONAL])
     expect_symbol(input_file, ",")
     transformation = parse_transformation(input_file, scene)
     expect_symbol(input_file, ",")
     aspect_ratio = expect_number(input_file, scene)
     expect_symbol(input_file, ",")
     distance = expect_number(input_file, scene)
     expect_symbol(input_file, ")")

     if type_kw == KeywordEnum.PERSPECTIVE
          result = PerspectiveCamera(distance, aspect_ratio, transformation)
     elseif type_kw == KeywordEnum.ORTHOGONAL
          result = OrthogonalCamera(aspect_ratio, transformation)
     end

     return result
end

