# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


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
     while ( (ch in WHITESPACE) || (ch == "#"))

          if ch == "#"
               ch = read_char(inputstream)
               !(ch == "") || (return nothing)

               if ch =="="
                    while true
                         if read_char(inputstream) == "=" && read_char(inputstream)=="#"
                              break
                         end
                    end
               end


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

