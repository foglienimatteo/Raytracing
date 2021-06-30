# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



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

copy(location::SourceLocation) = SourceLocation(location.file_name, location.line_num, location.col_num)




"""
     @enum KeywordEnum

Enumeration for all the possible keywords recognized by the lexer:
```ditaa
|:-----------------:|:-----------------:|:----------------------:|
| NEW = 1           | PIGMENT = 20      | TRANSFORMATION = 40    |
| FLOAT = 2         | UNIFORM = 21      | IDENTITY = 41          |
| STRING = 3        | CHECKERED = 22    | TRANSLATION = 42       |
| VECTOR = 4        | IMAGE = 23        | ROTATION_X = 43        |
| COLOR = 5         |                   | ROTATION_Y = 44        |
| MATERIAL = 6      |                   | ROTATION_Z = 45        |
| POINTLIGHT = 7    |                   | SCALING = 46           |
|                   |                   |                        |
|:-----------------:|:-----------------:|:----------------------:|
| BRDFS = 10        | CAMERA = 30       | BOOL = 50              |
| DIFFUSE = 11      | ORTHOGONAL = 31   | TRUE = 51              |
| SPECULAR = 12     | PERSPECTIVE = 32  | FALSE = 52             |
|                   |                   |                        |
|                   |                   |                        |
|:-----------------:|:-----------------:|:----------------------:|
| PLANE = 61        | PRINT = 71        |                        |
| SPHERE = 62       | ASSERT = 72       |                        |
| CUBE = 63         |                   |                        |
| TRIANGLE = 64     |                   |                        |
|                   |                   |                        |
|:-----------------:|:-----------------:|:----------------------:|
```
"""
@enum KeywordEnum begin
    NEW = 1
    FLOAT = 2
    STRING = 3
    VECTOR = 4
    COLOR = 5
    MATERIAL = 6
    POINTLIGHT = 7

    BRDFS = 10
    DIFFUSE = 11
    SPECULAR = 12

    PIGMENT = 20
    UNIFORM = 21
    CHECKERED = 22
    IMAGE = 23

    CAMERA = 30
    ORTHOGONAL = 31
    PERSPECTIVE = 32

    TRANSFORMATION = 40
    IDENTITY = 41
    TRANSLATION = 42
    ROTATION_X = 43
    ROTATION_Y = 44
    ROTATION_Z = 45
    SCALING = 46

    BOOL = 50
    TRUE = 51
    FALSE = 52

    PLANE = 61
    SPHERE = 62
    CUBE = 63
    TRIANGLE = 64

    PRINT = 71
    ASSERT = 72
end

KEYWORDS = Dict{String, KeywordEnum}(
    "NEW" => NEW,
    "FLOAT" => FLOAT,
    "STRING" => STRING,
    "VECTOR" => VECTOR,
    "COLOR" => COLOR,
    "MATERIAL" => MATERIAL,
    "POINTLIGHT" => POINTLIGHT,

    "BRDF" => BRDFS,
    "DIFFUSE" => DIFFUSE,
    "SPECULAR" => SPECULAR,

    "PIGMENT" => PIGMENT,
    "UNIFORM" => UNIFORM,
    "CHECKERED" => CHECKERED,
    "IMAGE" => IMAGE,

    "CAMERA" => CAMERA,
    "ORTHOGONAL" => ORTHOGONAL,
    "PERSPECTIVE" => PERSPECTIVE,

    "TRANSFORMATION" => TRANSFORMATION,
    "IDENTITY" => IDENTITY,
    "TRANSLATION" => TRANSLATION,
    "ROTATION_X" => ROTATION_X,
    "ROTATION_Y" => ROTATION_Y,
    "ROTATION_Z" => ROTATION_Z,
    "SCALING" => SCALING,

    "BOOL" => BOOL,
    "TRUE" => TRUE,
    "FALSE" => FALSE,

    "PLANE" => PLANE,
    "SPHERE" => SPHERE,
    "CUBE" => CUBE,
    "TRIANGLE" => TRIANGLE,

    "PRINT" => PRINT,
    "ASSERT" => ASSERT,
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
     value::Union{KeywordToken, IdentifierToken, StringToken, LiteralNumberToken, SymbolToken,StopToken}
end

copy(token::KeywordToken) = KeywordToken(token.keyword)
copy(token::IdentifierToken) = IdentifierToken(token.identifier)
copy(token::StringToken) = StringToken(token.string)
copy(token::LiteralNumberToken) = LiteralNumberToken(token.number)
copy(token::SymbolToken) = SymbolToken(token.symbol)
copy(token::StopToken) = StopToken()
copy(token::Token) = Token(token.location, copy(token.value))

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

