# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


"""
    check_is_color(string::String="") :: Bool

Checks if the input `string` is a color written in RGB components
as "<R, G, B>".
"""
function check_is_color(string::String="")
    println(string)
	(string == "") && (return true)
	color = filter(x -> !isspace(x) && x≠"\"", string)

	(color[begin] == '<' && color[end] == '>') || (return false)

	color = color[begin+1:end-1]
	color = split(color, ",")
	(length(color)==3) || (return false)

	for c in color
		!isnothing(tryparse(Float64, c)) || (return false)
	end

	return true
end

"""
    string2color(string::String="") :: RGB{Float32}

Checks if the input `string` is a color written in RGB components
as "<R, G, B>" with [`check_is_color`](@ref), and return it.
"""
function string2color(string::String)
    if check_is_color(string)==false
        throw(ArgumentError(
            "invalid color sintax; must be: <R, G, B>\n"*
            "Example: --background_color=<1,2,3>"
        ))
    end

    if string==""
        return RGB{Float32}(0,0,0)
    end

	color = filter(x -> !isspace(x)&& x≠"\"", string)[begin+1:end-1]
	rgb = Vector{String}(split(color, ","))
    R, G, B = tuple(parse.(Float64, rgb)...)

    println(R,G,B)
	return RGB{Float32}(R,G,B)
end


"""
    check_is_vector(string::String="") :: Bool

Checks if the input `string` is a vector written in X,Y,Z components
as "[X, Y, Z]".
"""
function check_is_vector(string::String="")
	(string == "") && (return true)
	color = filter(x -> !isspace(x), string)

	(color[begin] == '[' && color[end] == ']') || (return false)

	color = color[begin+1:end-1]
	color = split(color, ",")
	(length(color)==3) || (return false)

	for c in color
		!isnothing(tryparse(Float64, c)) || (return false)
	end

	return true
end

"""
    string2vector(string::String="") :: Union{Vec, Nothing}

Checks if the input `string` is  a vector written in X,Y,Z components
as "[X, Y, Z]" with [`check_is_vector`](@ref), and return `Vec(X,Y,Z)`.

See also: [`Vec`](@ref)
"""
function string2vector(string::String)
    if check_is_vector(string)==false
        throw(ArgumentError(
            "invalid vector sintax; must be: [1,2,3]\n"*
            "Example: --camera_position=[1,2,3]"
        ))
    end

    if string==""
        return Vec(0,0,0)
    end

	color = filter(x -> !isspace(x) && x≠"\"", string)[begin+1:end-1]
	Vec = split(color, ",")
    x, y, z = parse.(Float64, RGB)

	return Vec(x, y, z)
end

"""
    check_is_declare_float(string::String="") 

Checks if the input `string` is a declaration of one (or more) floats
in the form "NAME:VALUE" with [`check_is_declare_float`](@ref).
Examples:
```bash
    --declare_float=name:1.0
    --declare_float=name1:1.0,name2:2.0
    --declare_float=" name1 : 1.0 , name2: 2.0"
```
"""
function check_is_declare_float(string::String="")
	(string == "") && (return true)
	string_without_spaces = filter(x -> !isspace(x), string)

	vec_nameval = split.(split(string_without_spaces, ","), ":" )
	for declare_float ∈ vec_nameval
		if !(length(declare_float)==2 && !isnothing(tryparse(Float64, declare_float[2])))
			return false
		end
	end

	return true
end

"""
    declare_float2dict(string::String) :: Union{Dict{String, Float64}, Nothing}

Checks if the input `string` is a declaration of one (or more) floats
in the form "NAME:VALUE" with [`check_is_declare_float`](@ref).
Return a `Dict{String, Float64}` that associates each NAME (as keys) with
its `Float64` value, or nothing if `string==""`.
"""
function declare_float2dict(string::String)
    if check_is_declare_float(string)==false
        throw(ArgumentError(
            "invalid declare_float usage. Correct usage: \n"*
            "\t--declare_float=name:1.0\n"*
            "\t--declare_float=name1:1.0,name2:2.0\n"*
            """\t--declare_float=" name1 : 1.0 , name2: 2.0\n"""
        ))
    end

    if string==""
        return nothing
    end

	string_without_spaces = filter(x -> !isspace(x), string)
    vec_nameval = split.(split(string_without_spaces, ","), ":" )
    declare_float = Dict{String, Float64}([v[1]=>parse(Float64, v[2]) for v in vec_nameval]...)
    return declare_float
end
