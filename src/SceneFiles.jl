# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

WHITESPACE = [" ", "\t", "\n", "\r"]
OPERATIONS = ["*", "/", "+", "-"]
SYMBOLS = union(["(", ")", "<", ">", "[", "]", ",", "@"], OPERATIONS)
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
| SPHERE = 62       | ASSERT = 72         |                        |
|                   |                   |                        |
|                   |                   |                        |
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

     PRINT = 71
     ASSERT = 72
end

KEYWORDS = Dict{String, KeywordEnum}(
     "new" => NEW,
     "float" => FLOAT,
     "string" => STRING,
     "vector" => VECTOR,
     "color" => COLOR,
     "material" => MATERIAL,
     "pointlight" => POINTLIGHT,

     "brdf" => BRDFS,
     "diffuse" => DIFFUSE,
     "specular" => SPECULAR,

     "pigment" => PIGMENT,
     "uniform" => UNIFORM,
     "checkered" => CHECKERED,
     "image" => IMAGE,

     "camera" => CAMERA,
     "orthogonal" => ORTHOGONAL,
     "perspective" => PERSPECTIVE,

     "transformation" => TRANSFORMATION,
     "identity" => IDENTITY,
     "translation" => TRANSLATION,
     "rotation_x" => ROTATION_X,
     "rotation_y" => ROTATION_Y,
     "rotation_z" => ROTATION_Z,
     "scaling" => SCALING,

     "bool" => BOOL,
     "true" => TRUE,
     "false" => FALSE,

     "plane" => PLANE,
     "sphere" => SPHERE,

     "print" => PRINT,
     "assert" => ASSERT,
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
     while ( (ch in WHITESPACE) || (ch == "#") || (ch == "@"))
          if ch == "#"
               # It's a comment! Keep reading until the end of the line 
               #(include the case "", the end-of-file)
               while read_char(inputstream) ∉ ["\r", "\n", ""]
                    nothing
               end
          end

          if ch == "@"
               # It's a comment! Keep reading until another @ is found
               #(include the case "", the end-of-file)
               while read_char(inputstream) ∉ ["@", ""]
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
function parse_float_token(inputstream::InputStream, first_char::String, token_location::SourceLocation)
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
          value = parse(Float64, token)
          return Token(token_location, LiteralNumberToken(value)) 
     catch ValueError
          throw(
               GrammarError(
                    token_location, 
                    """ "$(token)" is an invalid floating-point number"""
               )
          )
     end


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
     elseif ( isdecimal(ch) || (ch ∈ ["."]) )
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
    inputstream.saved_token = copy(token)
end

##########################################################################################92


"""
     Scene(
          materials::Dict{String, Material} = Dict{String, Material}(),
          world::World = World(),
          camera::Union{Camera, Nothing} = nothing,

          float_variables::Dict{String, Float64} = Dict{String, Float64}(),
          string_variables::Dict{String, String} = Dict{String, String}(),
          bool_variables::Dict{String, Bool} = Dict{String, Bool}(),
          vector_variables::Dict{String,Vec} = Dict{String,Vec}(),
          color_variables::Dict{String,RGB{Float32}} = Dict{String,RGB{Float32}}(),
          pigment_variables::Dict{String,Pigment} = Dict{String,Pigment}(),
          brdf_variables::Dict{String,BRDF} = Dict{String,BRDF}(),
          transformation_variables::Dict{String,Transformation} = Dict{String,Transformation}(),

          variable_names::Set{String} = Set{String}(),
          overridden_variables::Set{String} = Set{String}(),
     )

A scene read from a scene file.

See also: [`Material`](@ref), [`World`](@ref), [`Camera`](@ref), [`Vec`](@ref),
[`Pigment`](@ref), [`BRDF`](@ref), [`Transformation`](@ref)
"""
mutable struct Scene
     materials::Dict{String, Material}
     world::World
     camera::Union{Camera, Nothing}

     float_variables::Dict{String, Float64}
     string_variables::Dict{String, String}
     bool_variables::Dict{String,Bool}
     vector_variables::Dict{String,Vec}
     color_variables::Dict{String,RGB{Float32}}
     pigment_variables::Dict{String,Pigment}
     brdf_variables::Dict{String,BRDF}
     transformation_variables::Dict{String,Transformation}

     variable_names::Set{String}
     overridden_variables::Set{String}

     Scene(
          materials::Dict{String, Material} = Dict{String, Material}(),
          world::World = World(),
          camera::Union{Camera, Nothing} = nothing,

          float_variables::Dict{String, Float64} = Dict{String, Float64}(),
          string_variables::Dict{String, String} = Dict{String, String}(),
          bool_variables::Dict{String, Bool} = Dict{String, Bool}(),
          vector_variables::Dict{String,Vec} = Dict{String,Vec}(),
          color_variables::Dict{String,RGB{Float32}} = Dict{String,RGB{Float32}}(),
          pigment_variables::Dict{String,Pigment} = Dict{String,Pigment}(),
          brdf_variables::Dict{String,BRDF} = Dict{String,BRDF}(),
          transformation_variables::Dict{String,Transformation} = Dict{String,Transformation}(),

          variable_names::Set{String} = Set{String}(),
          overridden_variables::Set{String} = Set{String}(),

     ) = new(
          materials,
          world,
          camera,

          float_variables,
          string_variables,
          bool_variables,
          vector_variables,
          color_variables,
          pigment_variables,
          brdf_variables,
          transformation_variables,

          variable_names,
          overridden_variables,
     )
end

function expect_symbol(inputstream::InputStream, symbol::String)
     token = read_token(inputstream)
     if (typeof(token.value) ≠ SymbolToken) || (token.value.symbol ≠ symbol)
          throw(GrammarError(token.location, "got $(token) insted of $(symbol)"))
     end
end

function expect_symbol(inputstream::InputStream, vec_symbol::Vector{String})
     token = read_token(inputstream)
     if (typeof(token.value) ≠ SymbolToken) || (token.value.symbol ∉ vec_symbol)
          throw(GrammarError(token.location, "got $(token) insted of $(vec_symbol)"))
     end
     return token.value.symbol
end


"""
     expect_symbol(inputstream::InputStream, symbol::String)
     expect_symbol(inputstream::InputStream, vec_symbol::Vector{String}) :: String

Read a token from `inputstream` and check that its type is `SymbolToken` 
and its value is `symbol`(first method) or a value inside `vec_symbol`
(second method, and return it), throwing `GrammarError` otherwise.
Call internally [`read_token`](@ref).

See also: [`InputStream`](@ref), [`KeywordEnum`](@ref), [`SymbolToken`](@ref)
"""
expect_symbol


"""
     expect_keywords(inputstream::InputStream, keywords::Vector{KeywordEnum}) :: KeywordEnum

Read a token from `inputstream` and check that its type is `KeywordToken` 
and its value is one of the keywords in `keywords`, throwing `GrammarError` otherwise.
Call internally [`read_token`](@ref).

See also: [`InputStream`](@ref), [`KeywordEnum`](@ref), [`KeywordToken`](@ref)
"""
function expect_keywords(inputstream::InputStream, keywords::Vector{KeywordEnum})
     token = read_token(inputstream)
     if typeof(token.value) ≠ KeywordToken
          throw(GrammarError(token.location, "expected a keyword instead of '$(token)' "))
     end

     if token.value.keyword ∉ keywords
          throw(GrammarError(
               token.location,
               "expected one of the keywords $([String(x)*"," for x in keywords]...)) instead of '$(token)'"
          ))
     end

     return token.value.keyword
end


"""
     expect_number(inputstream::InputStream, scene::Scene) :: Float64

Read a token from `inputstream` and check that its type is `LiteralNumberToken` 
(i.e. a number) or `IdentifierToken` (i.e. a variable defined in `scene`), 
throwing  `GrammarError` otherwise.
Return the float64-parsed number or the identifier associated float64-parsed 
number, respectively.
Call internally [`read_token`](@ref).

See also: [`InputStream`](@ref), [`Scene`](@ref), [`LiteralNumberToken`](@ref), 
[`IdentifierToken`](@ref)
"""
function expect_number(inputstream::InputStream, scene::Scene, open::Bool=false)
     token = read_token(inputstream)
     result = ""

     if typeof(token.value) == SymbolToken && token.value.symbol == "("
          result *= "("*expect_number(inputstream, scene, true)
          expect_symbol(inputstream, ")")
          result *= ")"
          token = read_token(inputstream)
     end
     
     if typeof(token.value) == SymbolToken && token.value.symbol == "-"
          result *= "-"
          token = read_token(inputstream)
     end
          
     while true
          if (typeof(token.value) == SymbolToken) && (token.value.symbol ∈ OPERATIONS)
               result *= token.value.symbol
          elseif typeof(token.value) == IdentifierToken
               variable_name = token.value.identifier
               if variable_name ∉ keys(scene.float_variables)
                    throw(GrammarError(token.location, "unknown variable '$(token)'"))
               end
               next_number = scene.float_variables[variable_name]
               result *= repr(next_number)
          elseif typeof(token.value) == LiteralNumberToken
               result *= repr(token.value.number)
          elseif (typeof(token.value) == SymbolToken) && (token.value.symbol=="(")
               result *= "("*expect_number(inputstream, scene, true)
               expect_symbol(inputstream, ")")
               result *= ")"
          else
               unread_token(inputstream, token)
               break
          end

          #=
          elseif (typeof(token.value) == SymbolToken) && (token.value.symbol==")")
               unread_token(inputstream, token)
               break
          else
               throw(GrammarError(token.location, "unknown variable '$(token)'"))
          end
          =#

          token = read_token(inputstream)
     end

     if open == true
          return result
     else
          return eval(Meta.parse(result))
     end
end


"""
     expect_bool(inputstream::InputStream, scene::Scene) :: Bool

Read a token from `inputstream` and check that its type is `KeywordToken` 
or `IdentifierToken` (i.e. a variable defined in `scene`), 
throwing  `GrammarError` otherwise.
Return the parsed bool or the identifier associated parsed bool, respectively.
Call internally [`read_token`](@ref).

See also: [`InputStream`](@ref), [`Scene`](@ref), [`KeywordToken`](@ref), 
[`IdentifierToken`](@ref)
"""
function expect_bool(inputstream::InputStream, scene::Scene)
     token = read_token(inputstream)
     if typeof(token.value) == KeywordToken
          unread_token(inputstream, token)
          
          keyword = expect_keywords(inputstream, [ TRUE,  FALSE])

          if keyword == TRUE
               return true
          elseif keyword == FALSE
               return false
          end

          throw(ArgumentError("how did you come here?"))

     elseif typeof(token.value) == IdentifierToken
          variable_name = token.value.identifier
          if variable_name ∉ keys(scene.bool_variables)
               throw(GrammarError(token.location, "unknown bool variable '$(token)'"))
          end
          return scene.bool_variables[variable_name]
     end

     throw(GrammarError(token.location, "got '$(token)' instead of a number"))
end


"""
     expect_string(inputstream::InputStream, scene::Scene) :: String

Read a token from `inputstream` and check that its type is `StringToken`,
throwing  `GrammarError` otherwise.
Return the string associated with the readed `StringToken`.
Call internally [`read_token`](@ref).

See also: [`InputStream`](@ref), [`Scene`](@ref), [`StringToken`](@ref), 
"""
function expect_string(inputstream::InputStream, scene::Scene)
     token = read_token(inputstream)
     if typeof(token.value) == StringToken
          return token.value.string
     elseif typeof(token.value) == IdentifierToken
          variable_name = token.value.identifier
          if variable_name ∉ keys(scene.string_variables)
               throw(GrammarError(token.location, "unknown string variable '$(token)'"))
          end
          return scene.string_variables[variable_name]
     else
          throw(GrammarError(token.location, "got $(token) instead of a string"))
     end
end


"""
     expect_identifier(inputstream::InputStream) :: String

Read a token from `inputstream` and check that it is an identifier.
Return the name of the identifier.

Read a token from `inputstream` and check that its type is `IdentifierToken`,
throwing  `GrammarError` otherwise.
Return the name of the identifier as a `String`.
Call internally [`read_token`](@ref).

See also: [`InputStream`](@ref), [`Scene`](@ref), [`IdentifierToken`](@ref), 
"""
function expect_identifier(inputstream::InputStream)
     token = read_token(inputstream)
     if (typeof(token.value) ≠ IdentifierToken)
          throw(GrammarError(token.location, "got $(token) instead of an identifier"))
     end

     return token.value.identifier
end


"""
    parse_vector(inputstream::InputStream, scene::Scene) :: Vec

Parse a vector from the given `inputstream` and return it.
Call internally [`expect_number`](@ref) and [`expect_symbol`](@ref).
    
See also: [`InputStream`](@ref), [`Scene`](@ref), [`Vec`](@ref)
"""
function parse_vector(inputstream::InputStream, scene::Scene, open::Bool=false)
     token = read_token(inputstream)
     result = ""

     if typeof(token.value) == SymbolToken && token.value.symbol == "("
          result *= "("*parse_vector(inputstream, scene, true)
          expect_symbol(inputstream, ")")
          result *= ")"
          token = read_token(inputstream)
     end
     
     if typeof(token.value) == SymbolToken && token.value.symbol == "-"
          result *= "-"
          token = read_token(inputstream)
     end
          
     while true
          if (typeof(token.value) == SymbolToken) && (token.value.symbol ∈ OPERATIONS)
               result *= token.value.symbol
          elseif typeof(token.value) == IdentifierToken
               variable_name = token.value.identifier
               if variable_name ∉ union(keys(scene.vector_variables), keys(scene.float_variables))
                    throw(GrammarError(token.location, "unknown vector/float variable '$(token)'"))
               end
               next_value = variable_name ∈ keys(scene.vector_variables) ?
                    scene.vector_variables[variable_name] :
                    scene.float_variables[variable_name]
               result *= repr(next_value)
          elseif typeof(token.value) == SymbolToken && token.value.symbol =="["
               unread_token(inputstream, token)

               expect_symbol(inputstream, "[")
               x = expect_number(inputstream, scene)
               expect_symbol(inputstream, ",")
               y = expect_number(inputstream, scene)
               expect_symbol(inputstream, ",")
               z = expect_number(inputstream, scene)
               expect_symbol(inputstream, "]")
               result*= repr(Vec(x, y, z))

          elseif (typeof(token.value) == SymbolToken) && (token.value.symbol=="(")
               result *= "("*parse_vector(inputstream, scene, true)
               expect_symbol(inputstream, ")")
               result *= ")"

          elseif typeof(token.value) == LiteralNumberToken
               result *= repr(token.value.number)
          else
               unread_token(inputstream, token)
               break
          end

          #=
          elseif (typeof(token.value) == SymbolToken) && (token.value.symbol==")")
               unread_token(inputstream, token)
               break
          else
               throw(GrammarError(token.location, "unknown variable '$(token)'"))
          end
          =#

          token = read_token(inputstream)
     end

     if open == true
          return result
     else
          return eval(Meta.parse(result))
     end
end


#=
function parse_vector(inputstream::InputStream, scene::Scene)
     token = read_token(inputstream)

     if typeof(token.value) == SymbolToken
          unread_token(inputstream, token)

          expect_symbol(inputstream, "[")
          x = expect_number(inputstream, scene)
          expect_symbol(inputstream, ",")
          y = expect_number(inputstream, scene)
          expect_symbol(inputstream, ",")
          z = expect_number(inputstream, scene)
          expect_symbol(inputstream, "]")
          return Vec(x, y, z)

     elseif typeof(token.value) == IdentifierToken
          variable_name = token.value.identifier
          if variable_name ∉ keys(scene.vector_variables)
               throw(GrammarError(token.location, "unknown variable '$(token)'"))
          end
          return scene.vector_variables[variable_name]
     end

end
=#



"""
     parse_color(inputstream::InputStream, scene::Scene) :: RGB{Float32}

Read the color from the given `inputstream` and return it.
Call internally ['expect_symbol'](@ref) and ['expect_number'](@ref).

See also: ['InputStream'](@ref), ['Scene'](@ref)
"""
function parse_color(inputstream::InputStream, scene::Scene, open::Bool=false)
     token = read_token(inputstream)
     result = ""

     if typeof(token.value) == SymbolToken && token.value.symbol == "("
          result *= "("*parse_vector(inputstream, scene, true)
          expect_symbol(inputstream, ")")
          result *= ")"
          token = read_token(inputstream)
     end
     
     if typeof(token.value) == SymbolToken && token.value.symbol == "-"
          result *= "-"
          token = read_token(inputstream)
     end
          
     while true
          if (typeof(token.value) == SymbolToken) && (token.value.symbol ∈ OPERATIONS)
               result *= token.value.symbol
          elseif typeof(token.value) == IdentifierToken
               variable_name = token.value.identifier
               if variable_name ∉ union(keys(scene.color_variables), keys(scene.float_variables))
                    throw(GrammarError(token.location, "unknown vector/float variable '$(token)'"))
               end
               next_value = variable_name ∈ keys(scene.color_variables) ?
                    scene.color_variables[variable_name] :
                    scene.float_variables[variable_name]
               result *= repr(next_value)
          elseif typeof(token.value) == SymbolToken && token.value.symbol =="<"
               unread_token(inputstream, token)

               expect_symbol(inputstream, "<")
               x = expect_number(inputstream, scene)
               expect_symbol(inputstream, ",")
               y = expect_number(inputstream, scene)
               expect_symbol(inputstream, ",")
               z = expect_number(inputstream, scene)
               expect_symbol(inputstream, ">")
               result*= repr(RGB{Float32}(x, y, z))

          elseif (typeof(token.value) == SymbolToken) && (token.value.symbol=="(")
               result *= "("*parse_color(inputstream, scene, true)
               expect_symbol(inputstream, ")")
               result *= ")"

          elseif typeof(token.value) == LiteralNumberToken
               result *= repr(token.value.number)
          else
               unread_token(inputstream, token)
               break
          end

          #=
          elseif (typeof(token.value) == SymbolToken) && (token.value.symbol==")")
               unread_token(inputstream, token)
               break
          else
               throw(GrammarError(token.location, "unknown variable '$(token)'"))
          end
          =#

          token = read_token(inputstream)
     end

     if open == true
          return result
     else
          return eval(Meta.parse(result))
     end
end

#=
function parse_color(inputstream::InputStream, scene::Scene)
     token = read_token(inputstream)

     if typeof(token.value) == SymbolToken
          unread_token(inputstream, token)

          expect_symbol(inputstream, "<")
          red = expect_number(inputstream, scene)
          expect_symbol(inputstream, ",")
          green = expect_number(inputstream, scene)
          expect_symbol(inputstream, ",")
          blue = expect_number(inputstream, scene)
          expect_symbol(inputstream, ">")

          return RGB{Float32}(red, green, blue)

     elseif typeof(token.value) == IdentifierToken
          variable_name = token.value.identifier
          if variable_name ∉ keys(scene.color_variables)
               throw(GrammarError(token.location, "unknown variable '$(token)'"))
          end

          return scene.color_variables[variable_name]
     end

end
=#

"""
     parse_pigment(inputstream::InputStream, scene::Scene) :: Pigment

Parse a pigment from the given `inputstream` and return it.

Call internally the following parsing functions:
- [`expect_keywords`](@ref)
- [`expect_symbol`](@ref)
- [`parse_color`](@ref)
- [`expect_number`](@ref)
- [`expect_string`](@ref)

Call internally the following functions and structs of the program:
- [`UniformPigment`](@ref)
- [`CheckeredPigment`](@ref)
- [`ImagePigment`](@ref)
- [`load_image`](@ref)
    
See also: [`InputStream`](@ref), [`Scene`](@ref), [`Pigment`](@ref)
"""
function parse_pigment(inputstream::InputStream, scene::Scene)
     token = read_token(inputstream)
     if typeof(token.value) == IdentifierToken
          variable_name = token.value.identifier
          if variable_name ∉ keys(scene.pigment_variables)
               throw(GrammarError(token.location, "unknown pigment '$(token)'"))
          end

          return scene.pigment_variables[variable_name]
     else
          unread_token(inputstream, token)
     end

     keyword = expect_keywords(inputstream, [ UNIFORM,  CHECKERED,  IMAGE])

     expect_symbol(inputstream, "(")
     if keyword ==  UNIFORM
          color = parse_color(inputstream, scene)
          result = UniformPigment(color)
     elseif keyword ==  CHECKERED
          color1 = parse_color(inputstream, scene)
          expect_symbol(inputstream, ",")
          color2 = parse_color(inputstream, scene)
          expect_symbol(inputstream, ",")
          num_of_steps = Int(expect_number(inputstream, scene))
          result = CheckeredPigment(color1, color2, num_of_steps)
     elseif keyword ==  IMAGE
          file_name = expect_string(inputstream, scene)
          image = open(file_name, "r") do image_file; load_image(image_file); end
          result = ImagePigment(image)
     else
          @assert false "This line should be unreachable"
     end

     expect_symbol(inputstream, ")")
     
     return result
end

"""
     parse_brdf(inputstream::InputStream, scene::Scene) :: BRDF

Parse a BRDF from the given `inputstream` and return it.

Call internally the following parsing functions:
- [`expect_keywords`](@ref)
- [`expect_symbol`](@ref)
- [`parse_pigment`](@ref)

Call internally the following functions and structs of the program:
- [`DiffuseBRDF`](@ref)
- [`SpecularBRDF`](@ref)
    
See also: [`InputStream`](@ref), [`Scene`](@ref), [`BRDF`](@ref)
"""
function parse_brdf(inputstream::InputStream, scene::Scene)
     token = read_token(inputstream)
     if typeof(token.value) == IdentifierToken
          variable_name = token.value.identifier
          if variable_name ∉ keys(scene.brdf_variables)
               throw(GrammarError(token.location, "unknown BRDF '$(token)'"))
          end

          return scene.brdf_variables[variable_name]
     else
          unread_token(inputstream, token)
     end

     brdf_keyword = expect_keywords(inputstream, [ DIFFUSE,  SPECULAR])
     expect_symbol(inputstream, "(")
     pigment = parse_pigment(inputstream, scene)
     expect_symbol(inputstream, ")")

     if (brdf_keyword ==  DIFFUSE)
          return DiffuseBRDF(pigment)
     elseif (brdf_keyword ==  SPECULAR)
          return SpecularBRDF(pigment)
     else
          @assert false "This line should be unreachable"
     end
end


"""
     parse_material(inputstream::InputStream, scene::Scene) :: (String, Material)

Parse a Material from the given `inputstream` and return a tuple with the
identifier name of the material and the material itself.

Call internally the following parsing functions:
- [`expect_identifier`](@ref)
- [`expect_symbol`](@ref)
- [`parse_brdf`](@ref)
- [`parse_pigment`](@ref)

Call internally the following functions and structs of the program:
- [`Material`](@ref)
    
See also: [`InputStream`](@ref), [`Scene`](@ref), [`Token`](@ref), [`Material`](@ref)
"""
function parse_material(inputstream::InputStream, scene::Scene)
     name = expect_identifier(inputstream)

     expect_symbol(inputstream, "(")
     brdf = parse_brdf(inputstream, scene)
     expect_symbol(inputstream, ",")
     emitted_radiance = parse_pigment(inputstream, scene)
     expect_symbol(inputstream, ")")

     return name, Material(brdf, emitted_radiance)
end


"""
     parse_transformation(inputstream::InputStream, scene::Scene) :: Transformation

Parse a Transformation from the given `inputstream` and return it.

Call internally the following parsing functions:
- [`expect_keywords`](@ref)
- [`expect_symbol`](@ref)
- [`expect_number`](@ref)
- [`parse_vector`](@ref)
- [`read_token`](@ref)
- [`unread_token`](@ref)

Call internally the following functions and structs of the program:
- [`translation`](@ref)
- [`rotation_x`](@ref)
- [`rotation_y`](@ref)
- [`rotation_z`](@ref)
- [`scaling`](@ref)

See also: [`InputStream`](@ref), [`Scene`](@ref), [`Transformation`](@ref)
"""
function parse_transformation(inputstream::InputStream, scene::Scene)
     token = read_token(inputstream)
     if typeof(token.value) == IdentifierToken
          variable_name = token.value.identifier
          if variable_name ∉ keys(scene.transformation_variables)
               throw(GrammarError(token.location, "unknown pigment '$(token)'"))
          end

          return scene.transformation_variables[variable_name]
     else
          unread_token(inputstream, token)
     end

     result = Transformation()

     while true
          transformation_kw = expect_keywords(inputstream, [
               IDENTITY,
               TRANSLATION,
               ROTATION_X,
               ROTATION_Y,
               ROTATION_Z,
               SCALING,
          ])

          if transformation_kw == IDENTITY
               nothing # Do nothing (this is a primitive form of optimization!)
          elseif transformation_kw == TRANSLATION
               expect_symbol(inputstream, "(")
               result *= translation(parse_vector(inputstream, scene))
               expect_symbol(inputstream, ")")
          elseif transformation_kw == ROTATION_X
               expect_symbol(inputstream, "(")
               result *= rotation_x(expect_number(inputstream, scene))
               expect_symbol(inputstream, ")")
          elseif transformation_kw == ROTATION_Y
               expect_symbol(inputstream, "(")
               result *= rotation_y(expect_number(inputstream, scene))
               expect_symbol(inputstream, ")")
          elseif transformation_kw == ROTATION_Z
               expect_symbol(inputstream, "(")
               result *= rotation_z(expect_number(inputstream, scene))
               expect_symbol(inputstream, ")")
          elseif transformation_kw == SCALING
               expect_symbol(inputstream, "(")
               result *= scaling(parse_vector(inputstream, scene))
               expect_symbol(inputstream, ")")
          end

          # We must peek the next token to check if there is another transformation that is being
          # chained or if the sequence ends. Thus, this is a LL(1) parser.
          next_kw = read_token(inputstream)
          if (typeof(next_kw.value) ≠ SymbolToken) || (next_kw.value.symbol ≠ "*")
               # Pretend you never read this token and put it back!
               unread_token(inputstream, next_kw)
               break
          end
     end

     return result
end


"""
     parse_pointlight(inputstream::InputStream, scene::Scene) :: PointLight

Parse a PointLight from the given `inputstream` and return it.

Call internally the following parsing functions:
- [`read_token`](@ref)
- [`unread_token`](@ref)
- [`expect_number`](@ref)
- [`expect_symbol`](@ref)
- [`parse_vector`](@ref)
- [`parse_color`](@ref)
    
See also: [`InputStream`](@ref), [`Scene`](@ref), [`PointLight`](@ref)
"""
function parse_pointlight(inputstream::InputStream, scene::Scene)
     expect_symbol(inputstream, "(")
     point = parse_vector(inputstream, scene)
     expect_symbol(inputstream, ",")
     color = parse_color(inputstream, scene)

     token = read_token(inputstream)
     if typeof(token.value) == SymbolToken && token.value.symbol == ","
          unread_token(inputstream, token)

          expect_symbol(inputstream, ",")
          linear_radius = expect_number(inputstream, scene)
     else
          unread_token(inputstream, token)
          linear_radius = 0.0
     end
     expect_symbol(inputstream, ")")

     return PointLight(
               Point(point.x, point.y, point.z),
               color,
               linear_radius,
               )
end


"""
     parse_sphere(inputstream::InputStream, scene::Scene) :: Sphere

Parse a Sphere from the given `inputstream` and return it.
Throws `GrammarError` if the specified `Material` does not exist.

Call internally the following parsing functions:
- [`expect_symbol`](@ref)
- [`expect_identifier`](@ref)
- [`parse_transformation`](@ref)

See also: [`InputStream`](@ref), [`Scene`](@ref), [`Sphere`](@ref)
[`Material`](@ref)
"""
function parse_sphere(inputstream::InputStream, scene::Scene)
     expect_symbol(inputstream, "(")

     material_name = expect_identifier(inputstream)
     if material_name ∉ keys(scene.materials)
          # We raise the exception here because inputstream is pointing to the end of the wrong identifier
          throw(GrammarError(inputstream.location, "unknown material $(material_name)"))
     end
     expect_symbol(inputstream, ",")
     transformation = parse_transformation(inputstream, scene)

     token = read_token(inputstream)
     if typeof(token.value) == SymbolToken && token.value.symbol == ","
          unread_token(inputstream, token)

          expect_symbol(inputstream, ",")
          bool = expect_bool(inputstream, scene)
          expect_symbol(inputstream, ")")
     else
          unread_token(inputstream, token)
          expect_symbol(inputstream, ")")
          bool = false
     end

     return Sphere(transformation, scene.materials[material_name], bool)
end


"""
     parse_plane(inputstream::InputStream, scene::Scene) :: Plane

Parse a Plane from the given `inputstream` and return it.
Throws `GrammarError` if the specified `Material` does not exist.

Call internally the following parsing functions:
- [`expect_symbol`](@ref)
- [`expect_identifier`](@ref)
- [`parse_transformation`](@ref)

See also: [`InputStream`](@ref), [`Scene`](@ref), [`Plane`](@ref),
[`Material`](@ref)
"""
function parse_plane(inputstream::InputStream, scene::Scene)
     expect_symbol(inputstream, "(")

     material_name = expect_identifier(inputstream)
     if material_name ∉ keys(scene.materials)
          # We raise the exception here because inputstream is pointing to the end of the wrong identifier
          throw(GrammarError(inputstream.location, "unknown material $(material_name)"))
     end
     expect_symbol(inputstream, ",")
     transformation = parse_transformation(inputstream, scene)
     expect_symbol(inputstream, ")")

     return Plane(transformation, scene.materials[material_name])
end


"""
     parse_camera(inputstream::InputStream, scene::Scene) :: Camera

Parse a Camera from the given `inputstream` and return it.

Call internally the following parsing functions:
- [`expect_symbol`](@ref)
- [`expect_keywords`](@ref)
- [`expect_number`](@ref)
- [`parse_transformation`](@ref)

Call internally the following functions and structs of the program:
- [`OrthogonalCamera`](@ref)
- [`PerspectiveCamera`](@ref)

See also: [`InputStream`](@ref), [`Scene`](@ref),  [`Camera`](@ref)
"""
function parse_camera(inputstream::InputStream, scene::Scene)
     expect_symbol(inputstream, "(")
     type_kw = expect_keywords(inputstream, [ PERSPECTIVE,  ORTHOGONAL])
     expect_symbol(inputstream, ",")
     transformation = parse_transformation(inputstream, scene)
     expect_symbol(inputstream, ",")
     aspect_ratio = expect_number(inputstream, scene)
     expect_symbol(inputstream, ",")
     distance = expect_number(inputstream, scene)
     expect_symbol(inputstream, ")")

     if type_kw ==  PERSPECTIVE
          result = PerspectiveCamera(distance, aspect_ratio, transformation)
     elseif type_kw ==  ORTHOGONAL
          result = OrthogonalCamera(aspect_ratio, transformation)
     end

     return result
end


function println(location::SourceLocation)
     print("location = [")
     if location.filename == ""
          print("nothing, ")
     else
          print("$(location.filename), ")
     end
     print("(", location.line_num,",", location.col_num,")")
end

function println(inputstream::InputStream, scene::Scene)
     expect_symbol(inputstream, "(")
     token = read_token(inputstream)
     if typeof(token.value) == SymbolToken
          println("SymbolToken: ", token.location, ", ", token.value.symbol)
     elseif typeof(token.value) == LiteralNumberToken
          println("LiteralNumberToken: ", token.location, ",  ", token.value.number)
     elseif typeof(token.value) == StringToken
          println("StringToken: ", token.location, ",  ", token.value.string)
     elseif typeof(token.value) == KeywordToken
          println("KeywordToken: ", token.location, ",  ", token.value.keyword)
     elseif typeof(token.value) == IdentifierToken
          print("IdentifierToken: ", token.location, ", identifier = ", token.value.identifier, ", value =")
          if token.value.identifier ∈ keys(scene.float_variables)
               println(scene.float_variables[token.value.identifier])
          elseif token.value.identifier ∈ keys(scene.vector_variables)
               println(scene.vector_variables[token.value.identifier])
          elseif token.value.identifier ∈ keys(scene.color_variables)
               println(scene.color_variables[token.value.identifier])
          else
               println(typeof(token.value.identifier))
          end
     end
     expect_symbol(inputstream, ")")
end

"""
     return_token_value(
          inputstream::InputStream, 
          scene::Scene
          ) :: Union{Float64, Bool, String, Vec, RGB{Float32}, Pigment, BRDF}

Return the value of the token readed from `inputstream`.
If the token is an IdentifierToken, return the value associated with that 
identifier insdie the given `scene`.
Throws `GrammarError` if an error occurs.
Call internally the following parsing functions:
- [`read_token`](@ref)
- [`unread_token`](@ref)
- [`parse_vector`](@ref)
- [`parse_color`](@ref)
- [`parse_pigment`](@ref)
- [`parse_brdf`](@ref)

See also: [`Vec`](@ref), [`Pigment`](@ref), [`BRDF`](@ref), 
[`InputStream`](@ref), [`Scene`](@ref), [`GrammarError`](@ref)
"""
function return_token_value(inputstream::InputStream, scene::Scene, bool::Bool = false)
     token = read_token(inputstream)
     result = ""

     while true

          if typeof(token.value) == LiteralNumberToken
               result *= repr(token.value.number)

          elseif typeof(token.value) == StringToken
               result *= repr(token.value.string)

          elseif typeof(token.value) == SymbolToken && token.value.symbol ∈ OPERATIONS
               result *= token.value.symbol

          elseif typeof(token.value) == SymbolToken && token.value.symbol=="["
               unread_token(inputstream, token)
               result *= repr(parse_vector(inputstream, scene))

          elseif typeof(token.value) == SymbolToken && token.value.symbol=="<"
               unread_token(inputstream, token)
               result *= repr(parse_color(inputstream, scene))

          elseif typeof(token.value) == SymbolToken && token.value.symbol=="("
               result *= "("*return_token_value(inputstream, scene, true)
               expect_symbol(inputstream, ")")
               result *= ")"

          elseif typeof(token.value) == KeywordToken
               keyword = token.value.keyword
               if keyword ∈ [DIFFUSE,  SPECULAR]
                    unread_token(inputstream, token)
                    result *= repr(parse_brdf(inputstream, scene))
               elseif keyword ∈ [UNIFORM,  CHECKERED,  IMAGE]
                    unread_token(inputstream, token)
                    result *= repr(parse_pigment(inputstream, scene))
               else
                    throw(GrammarError(token.location, 
                    "keyword '$(keyword)' do not define anything that can be compared"))
               end


          elseif typeof(token.value) == IdentifierToken
               variable_name = token.value.identifier
               if variable_name ∈ keys(scene.float_variables)
                    result *= repr(scene.float_variables[variable_name])
               elseif variable_name ∈ keys(scene.string_variables)
                    result *= repr(scene.string_variables[variable_name])
               elseif variable_name ∈ keys(scene.bool_variables)
                    result *= repr(scene.bool_variables[variable_name])
               elseif variable_name ∈ keys(scene.vector_variables)
                    result *= repr(scene.vector_variables[variable_name])
               elseif variable_name ∈ keys(scene.color_variables)
                    result *= repr(scene.color_variables[variable_name])
               elseif variable_name ∈ keys(scene.pigment_variables)
                    result *= repr(scene.pigment_variables[variable_name])
               elseif variable_name ∈ keys(scene.brdf_variables)
                    result *= repr(scene.brdf_variables[variable_name])
               elseif variable_name ∈ keys(scene.transformation_variables)
                    result *= repr(scene.transformation_variables[variable_name])
               else
                    throw(GrammarError(token.location, 
                    "identifier '$(variable_name)' do not define anything that can be compared"))
               end
          else
               unread_token(inputstream, token)
               break
          end

          token = read_token(inputstream)
     end

     if open==true
          return result
     else
          return eval(Meta.parse(result))
     end
end     

function assert(inputstream::InputStream, scene::Scene)
     expect_symbol(inputstream, "(")
     value1 =  return_token_value(inputstream, scene)
     expect_symbol(inputstream, ",")
     value2 =  return_token_value(inputstream, scene)

     token = read_token(inputstream)
     if typeof(token.value) == SymbolToken && token.value.symbol == ","
          unread_token(inputstream, token)
          expect_symbol(inputstream,",")
          operator = expect_string(inputstream, scene)
          expect_symbol(inputstream, ")")

          if operator ∈ ["=", "=="]
               @assert value1 == value2 "$(value1) and $(value2) are not equal!"
          elseif operator == "<"
               @assert value1 < value2 "$(value1) is not < $(value2)!"
          elseif operator == "<="
               @assert value1 <= value2 "$(value1) is not <= $(value2)!"
          elseif operator == ">"
               @assert value1 > value2 "$(value1) is not > $(value2)!"
          elseif operator == ">="
               @assert value1 >= value2 "$(value1) is not >= $(value2)!"
          else
               throw(GrammarError(token.location, "operator $(operator)  is not valid"))
          end
     else
          unread_token(inputstream, token)
          expect_symbol(inputstream, ")")
          @assert value1 == value2 "$(value1) and $(value2) are not equal!"
     end
end

"""
     parse_scene(
          inputstream::InputStream, 
          variables::Dict{String, Float64} = Dict()
          ) :: Scene

Read a scene description from the given `inputstream` and 
return a `Scene` object.
Throws `GrammarError` if an error occurs.

Call internally the following parsing functions:
- [`read_token`](@ref)
- [`StopToken`](@ref)
- [`expect_identifier`](@ref)
- [`expect_symbol`](@ref)
- [`parse_number`](@ref)
- [`parse_sphere`](@ref)
- [`parse_plane`](@ref)
- [`parse_camera`](@ref)
- [`parse_material`](@ref)

Call internally the following functions and structs of the program:
- [`add_shape!`](@ref)
- [`add_pointlight!`](@ref)

See also: [`InputStream`](@ref), [`Scene`](@ref)
"""
function parse_scene(inputstream::InputStream, variables::Dict{String, Float64} = Dict{String, Float64}())
#function parse_scene(inputstream::InputStream, variables::Dict{T1, T2} = Dict{T1, T2}()) where {T1, T2}
     scene = Scene()
     scene.float_variables = copy(variables)
     scene.overridden_variables = keys(variables)

     while true
          what = read_token(inputstream)
          isa(what.value, StopToken) && (break)

          if !isa(what.value, KeywordToken)
               throw(GrammarError(what.location, "expected a keyword instead of '$(what)'"))
          end

          if what.value.keyword == FLOAT
               variable_name = expect_identifier(inputstream)

               # Save this for the error message
               variable_loc = inputstream.location

               expect_symbol(inputstream, "(")
               variable_value = expect_number(inputstream, scene)
               expect_symbol(inputstream, ")")

               if (variable_name ∈ scene.variable_names) && !(variable_name ∈ scene.overridden_variables)
                    throw(GrammarError(variable_loc, "variable «$(variable_name)» cannot be redefined"))
               end

               if variable_name ∉ scene.overridden_variables
                    # Only define the variable if it was not defined by the user *outside* the scene file
                    # (e.g., from the command line)
                    scene.float_variables[variable_name] = variable_value
                    push!(scene.variable_names, variable_name)
               end

          elseif what.value.keyword == STRING
               variable_name = expect_identifier(inputstream)
               variable_loc = inputstream.location
               expect_symbol(inputstream, "(")
               variable_value = expect_string(inputstream, scene)
               expect_symbol(inputstream, ")")

               if (variable_name ∈ scene.variable_names) && !(variable_name ∈ scene.overridden_variables)
                    throw(GrammarError(variable_loc, "variable «$(variable_name)» cannot be redefined"))
               end

               if variable_name ∉ scene.overridden_variables
                    scene.string_variables[variable_name] = variable_value
                    push!(scene.variable_names, variable_name)
               end

          elseif what.value.keyword == BOOL
               variable_name = expect_identifier(inputstream)
               variable_loc = inputstream.location
               expect_symbol(inputstream, "(")
               variable_value = expect_bool(inputstream, scene)
               expect_symbol(inputstream, ")")

               if (variable_name ∈ scene.variable_names) && !(variable_name ∈ scene.overridden_variables)
                    throw(GrammarError(variable_loc, "variable «$(variable_name)» cannot be redefined"))
               end

               if variable_name ∉ scene.overridden_variables
                    scene.bool_variables[variable_name] = variable_value
                    push!(scene.variable_names, variable_name)
               end

          elseif what.value.keyword == VECTOR
               variable_name = expect_identifier(inputstream)
               variable_loc = inputstream.location
               expect_symbol(inputstream, "(")
               variable_value = parse_vector(inputstream, scene)
               expect_symbol(inputstream, ")")

               if (variable_name ∈ scene.variable_names) && !(variable_name ∈ scene.overridden_variables)
                    throw(GrammarError(variable_loc, "variable «$(variable_name)» cannot be redefined"))
               end

               if variable_name ∉ scene.overridden_variables
                    scene.vector_variables[variable_name] = variable_value
                    push!(scene.variable_names, variable_name)
               end

          elseif what.value.keyword == COLOR
               variable_name = expect_identifier(inputstream)
               variable_loc = inputstream.location
               expect_symbol(inputstream, "(")
               variable_value = parse_color(inputstream, scene)
               expect_symbol(inputstream, ")")

               if (variable_name ∈ scene.variable_names) && !(variable_name ∈ scene.overridden_variables)
                    throw(GrammarError(variable_loc, "variable «$(variable_name)» cannot be redefined"))
               end

               if variable_name ∉ scene.overridden_variables
                    scene.color_variables[variable_name] = variable_value
                    push!(scene.variable_names, variable_name)
               end
               
          elseif what.value.keyword == BRDFS
               variable_name = expect_identifier(inputstream)
               variable_loc = inputstream.location
               expect_symbol(inputstream, "(")
               variable_value = parse_brdf(inputstream, scene)
               expect_symbol(inputstream, ")")

               if (variable_name ∈ scene.variable_names) && !(variable_name ∈ scene.overridden_variables)
                    throw(GrammarError(variable_loc, "variable «$(variable_name)» cannot be redefined"))
               end

               if variable_name ∉ scene.overridden_variables
                    scene.brdf_variables[variable_name] = variable_value
                    push!(scene.variable_names, variable_name)
               end

          elseif what.value.keyword == PIGMENT
               variable_name = expect_identifier(inputstream)
               variable_loc = inputstream.location
               expect_symbol(inputstream, "(")
               variable_value = parse_pigment(inputstream, scene)
               expect_symbol(inputstream, ")")

               if (variable_name ∈ scene.variable_names) && !(variable_name ∈ scene.overridden_variables)
                    throw(GrammarError(variable_loc, "variable «$(variable_name)» cannot be redefined"))
               end

               if variable_name ∉ scene.overridden_variables
                    scene.pigment_variables[variable_name] = variable_value
                    push!(scene.variable_names, variable_name)
               end

          elseif what.value.keyword == TRANSFORMATION
               variable_name = expect_identifier(inputstream)
               variable_loc = inputstream.location
               expect_symbol(inputstream, "(")
               variable_value = parse_transformation(inputstream, scene)
               expect_symbol(inputstream, ")")

               if (variable_name ∈ scene.variable_names) && !(variable_name ∈ scene.overridden_variables)
                    throw(GrammarError(variable_loc, "variable «$(variable_name)» cannot be redefined"))
               end

               if variable_name ∉ scene.overridden_variables
                    scene.transformation_variables[variable_name] = variable_value
                    push!(scene.variable_names, variable_name)
               end

          elseif what.value.keyword == POINTLIGHT
               add_light!(scene.world, parse_pointlight(inputstream, scene))

          elseif what.value.keyword == CAMERA
               if !isnothing(scene.camera)
                    throw(GrammarError(what.location, "You cannot define more than one camera"))
               end
               scene.camera = parse_camera(inputstream, scene)

          elseif what.value.keyword ==  MATERIAL
               name, material = parse_material(inputstream, scene)
               scene.materials[name] = material

          elseif what.value.keyword == SPHERE
               add_shape!(scene.world, parse_sphere(inputstream, scene))

          elseif what.value.keyword == PLANE
               add_shape!(scene.world, parse_plane(inputstream, scene))

          elseif what.value.keyword == PRINT
               println(inputstream, scene)

          elseif what.value.keyword == ASSERT
               assert(inputstream, scene)
          end
     end

     return scene
end


