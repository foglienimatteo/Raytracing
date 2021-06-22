# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


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
          throw(GrammarError(token.location, "got $(token) instead of $(vec_symbol)"))
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
               "expected one of the keywords $([x for x in keywords]) instead of '$(token)'"
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
          elseif (typeof(token.value) == IdentifierToken) && (token.value.identifier ∈ keys(SYM_NUM))
               result *=  string(SYM_NUM[token.value.identifier])
          elseif typeof(token.value) == IdentifierToken
               variable_name = token.value.identifier


               if (variable_name ∈ keys(scene.float_variables) )
                    next_number = scene.float_variables[variable_name]
                    result *= repr(next_number)
               elseif isdefined(Raytracing, Symbol(variable_name)) || isdefined(Base, Symbol(variable_name))
                    unread_token(inputstream, token)
                    result *= parse_function(inputstream, scene)
               else
                    throw(GrammarError(token.location, "unknown variable '$(token)'"))
               end

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
  
          (variable_name ∈ keys(scene.bool_variables) ) ||
               throw(GrammarError(token.location, "unknown bool variable '$(token)'"))
          next_number = scene.bool_variables[variable_name]
          result *= repr(next_number)
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
          elseif (typeof(token.value) == IdentifierToken) && (token.value.identifier ∈ keys(SYM_NUM))
               result *=  string(SYM_NUM[token.value.identifier])
          elseif typeof(token.value) == IdentifierToken
               variable_name = token.value.identifier

               if (variable_name ∈ keys(scene.vector_variables) )
                    next_vector = scene.vector_variables[variable_name]
                    result *= repr(next_vector)
               elseif (variable_name ∈ keys(scene.float_variables) )
                    next_number = scene.float_variables[variable_name]
                    result *= repr(next_number)
               elseif isdefined(Raytracing, Symbol(variable_name)) || isdefined(Base, Symbol(variable_name))
                    unread_token(inputstream, token)
                    result *= parse_function(inputstream, scene)
               else
                    throw(GrammarError(token.location, "unknown float/vector variable '$(token)'"))
               end

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
          elseif (typeof(token.value) == IdentifierToken) && (token.value.identifier ∈ keys(SYM_NUM))
               result *=  string(SYM_NUM[token.value.identifier])
          elseif typeof(token.value) == IdentifierToken
               variable_name = token.value.identifier
               
               if (variable_name ∈ keys(scene.color_variables) )
                    next_color = scene.color_variables[variable_name]
                    result *= repr(next_color)
               elseif (variable_name ∈ keys(scene.float_variables) )
                    next_number = scene.float_variables[variable_name]
                    result *= repr(next_number)
               elseif isdefined(Raytracing, Symbol(variable_name)) || isdefined(Base, Symbol(variable_name))
                    unread_token(inputstream, token)
                    result *= parse_function(inputstream, scene)
               else
                    throw(GrammarError(token.location, "unknown float/color variable '$(token)'"))
               end
               
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
