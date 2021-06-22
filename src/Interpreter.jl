# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


module Interpreter

using StaticArrays: eachindex
import Base: println, print, copy #, IteratorSize

using Raytracing, FileIO, Test
using ColorTypes:RGB
using LinearAlgebra, StaticArrays
using Printf, ProgressBars
using Documenter, DocStringExtensions, JSON

export KeywordEnum, GrammarError, InputStream
export Token, KeywordToken, IdentifierToken, StringToken
export LiteralNumberToken, SymbolToken, StopToken
export read_token, skip_whitespaces_and_comments
export Scene, parse_scene


import Raytracing.SYM_NUM
WHITESPACE = [" ", "\t", "\n", "\r"]
OPERATIONS = ["*", "/", "+", "-"]
OPEN_BRACKETS = ["{", "[", "(", "<"]
CLOSED_BRACKETS = ["}", "]", ")", ">"]
SYMBOLS = union(OPEN_BRACKETS, CLOSED_BRACKETS, [",", "@"], OPERATIONS)
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


"""
     closed_bracket(open::String) :: String

Given in input a string of an open braket ($(OPEN_BRACKETS)) return
the corresponding closed one ($(CLOSED_BRACKETS)).
"""
function closed_bracket(open::String)
     (open ∈ OPEN_BRACKETS) || (throw(ArgumentError("you must insert an open braket!")))
     
     for i in eachindex(OPEN_BRACKETS)
          (open == OPEN_BRACKETS[i]) || (return CLOSED_BRACKETS[i])
     end

     #=
     (open == "{") || (return "}")
     (open == "[") || (return "]")
     (open == "(") || (return ")")
     (open == "<") || (return ">")
     =#

     throw(ArgumentError("you must insert an open braket!"))
end


const interpreter_dir = "interpreter"
include(joinpath(interpreter_dir, "tokens.jl"))
include(joinpath(interpreter_dir, "lexer.jl"))
include(joinpath(interpreter_dir, "parser_functions.jl"))
include(joinpath(interpreter_dir, "utilities.jl"))
include(joinpath(interpreter_dir, "parse_scene.jl"))

end # module


