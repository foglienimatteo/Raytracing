# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


# SourceLocation print functions
function println(io::IO, location::SourceLocation)
     print(io, "location = [")
     if location.file_name == ""
          print(io, "nothing, ")
     else
          print(io, "$(location.file_name), ")
     end
     print(io, "(", location.line_num,",", location.col_num, ")")
end
print(io::IO, location::SourceLocation) = println(io, location)
println(location::SourceLocation) = println(stdout, location)
print(location::SourceLocation) = print(stdout,location)



# Token print functions
function println(io::IO, token::Token)
     print(io, "Token: \t")
     println(io, "token.location = ", token.location, " , token.value = ", token.value)
end
print(io::IO, token::Token) = println(io, token)
println(token::Token) = println(stdout, token)
print(token::Token) = print(stdout, token)

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
function return_token_value(inputstream::InputStream, scene::Scene, open::Bool = false)
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
               if (variable_name ∈ keys(SYM_NUM))
                    result *=  string(SYM_NUM[token.value.identifier])
               elseif isdefined(Raytracing, Symbol(variable_name))
                    result *= "Raytracing."*variable_name
                    expect_symbol(inputstream, "{")
                    result *= "("*parse_function(inputstream, scene)
                    expect_symbol(inputstream, "}")
                    result *= ")"
               elseif isdefined(Base, Symbol(variable_name))
                    result *= "Base."*variable_name
                    expect_symbol(inputstream, "{")
                    result *= "("*parse_function(inputstream, scene)
                    expect_symbol(inputstream, "}")
                    result *= ")"
               elseif variable_name ∈ keys(scene.float_variables)
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

"""
     assert(inputstream::InputStream, scene::Scene)

Parse an assertion from the given `inputstream` and return it.
Throws `AssertionError` if the assertion is false, nothing otherwise.

Call internally the following parsing functions:
- [`expect_symbol`](@ref)
- [`expect_keywords`](@ref)
- [`expect_number`](@ref)
- [`expect_string`](@ref)
- [`return_token_value`](@ref)

## Examples

```text
assert(1, 1)             # Checks that 1==1
assert(1, 2, "<")        # Checks that 1<2
float var(1.0)           # Define var as a variable with value 1.0
assert(var, 2, "<=")     # Checks that var<=2
```

See also: [`InputStream`](@ref), [`Scene`](@ref)
"""
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


function parse_function(inputstream::InputStream, scene::Scene)
     token = read_token(inputstream)
     result = ""
     while true
          token = read_token(inputstream)
          
          if typeof(token.value) == LiteralNumberToken
               result *= repr(token.value.number)

          elseif typeof(token.value) == StringToken
               result *= repr(token.value.string)

          elseif typeof(token.value) == SymbolToken && token.value.symbol ∈ OPEN_BRACKETS
               result *= token.value.symbol*parse_function(inputstream, scene)
               expect_symbol(inputstream, closed_bracket(token.value.symbol))
               result *= closed_bracket(token.value.symbol)

          elseif typeof(token.value) == SymbolToken && token.value.symbol ∉ CLOSED_BRACKETS
               result *= token.value.symbol

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
                    "keyword '$(keyword)' do not define anything that can be inside a function"))
               end


          elseif typeof(token.value) == IdentifierToken
               variable_name = token.value.identifier

               if (variable_name ∈ keys(SYM_NUM))
                    result *=  string(SYM_NUM[token.value.identifier])
               elseif variable_name ∈ keys(scene.float_variables)
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

               elseif isdefined(Raytracing, Symbol(variable_name))
                    result *= variable_name
                    var = eval(Symbol(variable_name))

                    if var isa Function
                         open_sym = expect_symbol(inputstream, ["{", "[", "("])
                         result *= sym*parse_function(inputstream, scene)
                         closed_sym = closed_bracket(open_sym)
                         expect_symbol(inputstream, closed_sym)
                         result *= closed_sym
                    else
                         nothing
                    end

               elseif isdefined(Base, Symbol(variable_name))
                    result *= variable_name
                    var = eval(Symbol(variable_name))

                    if var isa Function
                         open_sym = expect_symbol(inputstream, ["{", "[", "("])
                         result *= sym*parse_function(inputstream, scene)
                         closed_sym = closed_bracket(open_sym)
                         expect_symbol(inputstream, closed_sym)
                         result *= closed_sym
                    else
                         nothing
                    end

               else
                    throw(GrammarError(token.location, 
                    "identifier '$(variable_name)' do not define anything that can be compared"))
               end
          else
               unread_token(inputstream, token)
               break
          end

     end
     return result
end


