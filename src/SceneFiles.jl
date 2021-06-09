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
    InputStream(
        stream::IO,
        location::SourceLocation,
        saved_char::String,
        saved_location::SourceLocation,
        tabulations::Int64,
        saved_token::Union{Token, Nothing},
    )

A high-level wrapper around a stream, used to parse scene files
This class implements a wrapper around a stream, with the following additional capabilities:
    - It tracks the line number and column number;
    - It permits to "un-read" characters and tokens.

## Arguments

- `stream`: 

- `location`: memorize the current location in the file

- `saved_char`: the last char read

- `saved_location`: the location where `saved_char` is in the file

- `tabulations`: number of space a tab command gives

- `saved_token`: the last token found
"""
struct InputStream
    stream::IO
    location::SourceLocation
    saved_char::String
    saved_location::SourceLocation
    tabulations::Int64
    saved_token::Union{Token, Nothing}

    InputStream(stream::IO, file_name::String = "", tabulations::Int64 = 8) = 
        new(stream, SourceLocation(file_name, 1, 0), "", location, tabulations)
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

"""
    update_pos(InputS::InputStream, ch)

Update `location` after having read `ch` from the stream
"""
function update_pos(InputS::InputStream, ch)
    if ch == ""
        return nothing
    elseif ch == "\n"
        InputS.location.line_num += 1
        InputS.location.col_num = 1
    elseif ch == "\t"
        InputS.location.col_num += InputS.tabulations
    else
        InputS.location.col_num += 1
    end
end

"""
    parse_string_token(
        InputS::InputStream,
        token_location::SourceLocation
        ) ::Token(
                ::SourceLocation,
                ::LiteralStringToken
                )


"""
function parse_string_token(InputS::InputStream, token_location::SourceLocation)
    token = ""
    while true
        ch = read_char(InputS)

        if ch == `"`
            break
        end
        if ch == ""
            throw(GrammarError(token_location, "unterminated string"))
        end

        token += ch
    end

    return Token(token_location, token)
end

"""
    parse_keyword_or_identifier_token(
        InputS::InputStream,
        first_char::String,
        token_location::SourceLocation
        ) ::Union{
                Token(::SourceLocation, ::KeywordToken),
                Token(::SourceLocation, ::IdentifierToken)
                }
"""
function parse_keyword_or_identifier_token(InputS::InputStream, first_char::String, token_location::SourceLocation)
    token = first_char

    while true
        read_char(ch)

        if !(isa(ch, Int8) || ch == "_")
            unread_char(ch)
            break
        end

        token += ch
    end

    try
        # If it is a keyword, it must be listed in the KEYWORDS dictionary
        return Token(token_location, KeywordToken(KEYWORDS[token]))
    catch KeyError
        # If we got KeyError, it is not a keyword and thus it must be an identifier
        return Token(token_location, IdentifierToken(token))
    end
end