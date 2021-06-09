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