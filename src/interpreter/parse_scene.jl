# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


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
- [`expect_number`](@ref)
- [`parse_sphere`](@ref)
- [`parse_plane`](@ref)
- [`parse_camera`](@ref)
- [`parse_material`](@ref)

Call internally the following functions and structs of the program:
- [`add_shape!`](@ref)
- [`add_light!`](@ref)

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


