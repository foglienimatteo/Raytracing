# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


"""
    SourceLocation(file_name::String, line_num::Int64, col_num::Int64)

A specific position in a source file

## Arguments

- `file_name`: the name of the file, or the empty string if there is no file associated with this location
    (e.g., because the source code was provided as a memory stream, or through a network connection)

- `line_num`: number of the line (starting from 1)

- `col_num`: number of the column (starting from 1)
"""
struct SourceLocation
    file_name::String
    line_num::Int64
    col_num::Int64
    SourceLocation(fn::String, ln::Int64 = 0, cn::Int64 = 0) = new(fn, ln, cn)
end

"""
    LiteralNumberToken(number::Float64)

A token containing a literal number

## Arguments

- `number`: value of the token
"""
struct LiteralNumberToken
    number::Float64
end

"""
    LiteralStringToken(sentence::String)

A token containing a literal string

## Arguments

- `sentence`: sentence between two `"` symbols
"""
struct LiteralStringToken
    sentence::String
end

"""
    KeywordToken(keyword::String)

A token containing a keyword

## Arguments

- `keyword`: string containing a keyword of Photorealistic Object Applications language
"""
struct KeywordToken
    keyword::String
end

"""
    IdentifierToken(variable::String)

A token containing an identifier

## Arguments

- `variable`: name of a variable
"""
struct IdentifierToken
    variable::String
end

"""
    SymbolToken(symbol::String)

A token containing a symbol (i.e., a variable name)

## Arguments

- `symbol`: string containing a recognised symbol by Photorealistic Object Applications language
"""
struct SymbolToken
    symbol::String
end

"""
    StopToken(stop::String)

A token signalling the end of a file

## Arguments

- `stop`: the string `""`, meaning the end of the file
"""
struct StopToken
    stop::String
end

"""
    Token(loc::SourceLocation,
          value::Union{LiteralNumber, LiteralString, Keyword, Identifier, Symbol})

A lexical token, used when parsing a scene file

## Arguments

- `loc`: the location of the last char read

- `value`: specify the type of token between 6 types
"""
struct Token
    loc::SourceLocation
    value::Union{LiteralNumber, LiteralString, Keyword, Identifier, Symbol}
end
"""
     GrammarError <: Exception(
          location::SourceLocation
          message::str
     )

An error found by the lexer/parser while reading a scene file

## Arguments

- `location::SourceLocation` : a struct containing the name of the file 
  (or the empty string if there is no real file) and the line and column 
  number where the error was discovered (both starting from 1)

- `message::String` : a user-frendly error message

See also: [`SourceLocation`](@ref)
"""
struct GrammarError <: Exception 
    location::SourceLocation
    message::String
end


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
    "new" => KeywordEnum.NEW,
    "material" => KeywordEnum.MATERIAL,
    "plane" => KeywordEnum.PLANE,
    "sphere" => KeywordEnum.SPHERE,
    "diffuse" => KeywordEnum.DIFFUSE,
    "specular" => KeywordEnum.SPECULAR,
    "uniform" => KeywordEnum.UNIFORM,
    "checkered" => KeywordEnum.CHECKERED,
    "image" => KeywordEnum.IMAGE,
    "identity" => KeywordEnum.IDENTITY,
    "translation" => KeywordEnum.TRANSLATION,
    "rotation_x" => KeywordEnum.ROTATION_X,
    "rotation_y" => KeywordEnum.ROTATION_Y,
    "rotation_z" => KeywordEnum.ROTATION_Z,
    "scaling" => KeywordEnum.SCALING,
    "camera" => KeywordEnum.CAMERA,
    "orthogonal" => KeywordEnum.ORTHOGONAL,
    "perspective" => KeywordEnum.PERSPECTIVE,
    "float" => KeywordEnum.FLOAT,
)
