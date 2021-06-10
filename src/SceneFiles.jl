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

function isdigit(a::String)
     !isnothing(tryparse(Int64, a)) || (return false)
     val = parse(Int64, a)
     bool = 0≤val≤9 ? true : false
     return bool
end

function isdecimal(a::String)
     !isnothing(tryparse(Int64, a)) || (return false)
     val = parse(Int64, a)
     bool = val≥0 ? true : false
     return bool
end

function isalpha(a::String)
     for ch in a
          (ch ∈ LETTERS) || (return false)
     end
     !(a=="") || (return false)
     return true 
end

function isalnum(a::String)
     for ch in a
          (ch ∈ LETTERS || ch ∈ NUMBERS) || (return false)
     end
     !(a=="") || (return false)
     return true 
end

"""
    SourceLocation(file_name::String, line_num::Int64, col_num::Int64)

A specific position in a source file

## Arguments

- `file_name`: the name of the file, or the empty string if there is no file associated with this location
    (e.g., because the source code was provided as a memory stream, or through a network connection)

- `line_num`: number of the line (starting from 1)

- `col_num`: number of the column (starting from 1)
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

A lexical token, used when parsing a scene file

## Arguments

- `location::SourceLocation`: location of the last char readed

- `value` : specify the type of token between 6 types
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
end


##########################################################################################92

"""
    update_pos(inputstream::InputStream, ch::String)

Update `location` after having read `ch` from the stream
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

See also: [`InputStream`](@ref)
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

See also: [`InputStream`](@ref)
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
        ) ::Token(
                ::SourceLocation,
                :: StringToken
                )


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

Parse a token as a float number.
Calls internally [`read_char`](@ref) and [`unread_char`](@ref), and it's used
inside the main function [`read_token`](@ref).

See also: [`InputStream`](@ref), [`SourceLocation`](@ref), 
[`LiteralNumberToken`](@ref)
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

Read a token from the stream, raising `GrammarError` if a 
lexical error is found.
Calls internally the following functions:
- [`skip_whitespaces_and_comments`](@ref)
- [`read_char`](@ref)
- [`isdecimal`](@ref)
- [`isalpha`](@ref)
- [`parse_string_token`](@ref)
- [`parse_float_token`](@ref)
- [`parse_keyword_or_identifier_token`](@ref)
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

Make as if `token` were never read from `input_file`
"""
function unread_token(inputstream::InputStream, token::Token)
    @assert isnothing(inputstream.saved_token) "$(inputstream.saved_token) ≠ nothing "
    inputstream.saved_token = token
end
