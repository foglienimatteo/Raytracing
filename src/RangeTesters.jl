# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

SYM_NUM = Dict("e"=>ℯ, "pi"=>π)


"""
    check_is_positive(string::String="") :: Bool

Checks if the input `string` is a number that can be parsed as 
a positive Float64.
"""
function check_is_positive(string::String="")
	var = filter(x -> !isspace(x) && x≠"\"", string)
     (var == "") && (return true)

	!isnothing(tryparse(Float64, var)) || (return false)

     return parse(Float64, var)>0 ? true : false
end


"""
    string2positive(string::String) :: Float64

Checks if the input `string` is a number that can be parsed as 
a positive Float64 with [`check_is_positive`](@ref), and return it as
a `Float64`.
"""
function string2positive(string::String, uint::Bool=false)
     if check_is_positive(string)==false
          throw(ArgumentError(
               "invalid number; it must be parsed as a positive Int64"
          ))
     end
     var = filter(x -> !isspace(x) && x≠"\"", string)

     !(var=="") || (return 0)

	return parse(Float64, var)
end


##########################################################################################92


"""
    check_is_uint64(string::String="") :: Bool

Checks if the input `string` is a number that can be parsed as 
a positive Int64.
"""
function check_is_uint64(string::String="")
	var = filter(x -> !isspace(x) && x≠"\"", string)
     (var == "") && (return true)

	!isnothing(tryparse(Float64, var)) || (return false)
     number = parse(Float64, var)
     (number - floor(number) ≈ 0.0 ) || (return false)

     return convert(Int64, number)>0 ? true : false
end


"""
    string2int64(string::String, uint::Bool=false) :: Union{Int64, UInt64}

Checks if the input `string` is a number that can be parsed as 
a positive Int64 with [`check_is_uint64`](@ref), and return it as
a `Int64` if `uint==false`or as a `UInt64` if `uint==true`.
"""
function string2int64(string::String, uint::Bool=false)
     if check_is_uint64(string)==false
          throw(ArgumentError(
               "invalid number; it must be parsed as a positive Int64"
          ))
     end
     var = filter(x -> !isspace(x) && x≠"\"", string)

     !(var=="") || (return uint==false ? Int64(0) : UInt64(0) )

	return uint==false ? 
          convert(Int64,parse(Float64, var)) : 
          convert(UInt64,parse(Float64, var))
end


##########################################################################################92


"""
    check_is_even_uint64(string::String="") :: Bool

Checks if the input `string` is a number that can be parsed as 
an even positive Int64.
"""
function check_is_even_uint64(string::String="")
	var = filter(x -> !isspace(x) && x≠"\"", string)
     (var == "") && (return true)

	!isnothing(tryparse(Float64, var)) || (return false)
     number = parse(Float64, var)
     (number - floor(number) ≈ 0.0 ) || (return false)
     even = convert(Int64, number)

     return (even>0 && iseven(even)) ? true : false
end


"""
    string2evenint64(string::String, uint::Bool=false) :: Union{Int64, UInt64}

Checks if the input `string` is a number that can be parsed as 
an even positive Int64 with [`check_is_even_uint64`](@ref), and return it as
a `Int64` if `uint==false`or as a `UInt64` if `uint==true`.
"""
function string2evenint64(string::String, uint::Bool=false)
     if check_is_even_uint64(string)==false
          throw(ArgumentError(
               "invalid number; it must be parsed as an even positive Int64"
          ))
     end
     var = filter(x -> !isspace(x) && x≠"\"", string)

     if var==""
          return uint==false ? Int64(0) : UInt64(0)
     end

	return uint==false ? 
          convert(Int64,parse(Float64, var)) : 
          convert(UInt64,parse(Float64, var))
end


##########################################################################################92


"""
    check_is_square(string::String="") :: Bool

Checks if the input `string` is a number that can be parsed as 
a squared positive Int64.
"""
function check_is_square(string::String="")
	var = filter(x -> !isspace(x) && x≠"\"", string)
     (var == "") && (return true)

	!isnothing(tryparse(Float64, var)) || (return false)
     square = parse(Float64,var)
     (square >= 0) || (return false)

     return √square - floor(√square) ≈ 0. ? true : false
end


"""
    string2rootint64(string::String) :: Int64

Checks if the input `string` is a number that can be parsed as 
a squared positive Int64 with [`check_is_square`](@ref), and return
the square root as a `Int64`.
"""
function string2rootint64(string::String)
     if check_is_square(string)==false
          throw(ArgumentError(
               "invalid number; it must be parsed as a squared positive Int64"
          ))
     end

     var = filter(x -> !isspace(x) && x≠"\"", string)
     !(var=="") || (return 0)
     return convert(Int64, √parse(Float64,var))
end


##########################################################################################92



"""
    check_is_color(string::String="") :: Bool

Checks if the input `string` is a color written in RGB components
as "<R, G, B>".
"""
function check_is_color(string::String="")
	color = filter(x -> !isspace(x) && x≠"\"", string)
     (color == "") && (return true)

	(color[begin] == '<' && color[end] == '>') || (return false)

	color = color[begin+1:end-1]
	color = split(color, ",")
	(length(color)==3) || (return false)

	for c in color
		if isnothing(tryparse(Float64, c)) && c ∉ keys(SYM_NUM)
               return false
          end 
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

     var = filter(x -> !isspace(x) && x≠"\"", string)

     !(var=="") || (return RGB{Float32}(0,0,0) )

	rgb = Vector{String}(split(var[begin+1:end-1], ","))

     R = isnothing(tryparse(Float64, rgb[1])) ? SYM_NUM[rgb[1]] : parse(Float64, rgb[1])
     G = isnothing(tryparse(Float64, rgb[2])) ? SYM_NUM[rgb[2]] : parse(Float64, rgb[2])
     B = isnothing(tryparse(Float64, rgb[3])) ? SYM_NUM[rgb[3]] : parse(Float64, rgb[3])

     return RGB{Float32}(R,G,B)
end


##########################################################################################92


"""
    check_is_vector(string::String="") :: Bool

Checks if the input `string` is a vector written in X,Y,Z components
as "[X, Y, Z]".
"""
function check_is_vector(string::String="")
	vector = filter(x -> !isspace(x), string)
     (vector == "") && (return true)

	(vector[begin] == '[' && vector[end] == ']') || (return false)

	vector = vector[begin+1:end-1]
	vector = split(vector, ",")
	(length(vector)==3) || (return false)

	for c in vector
		if isnothing(tryparse(Float64, c)) && c ∉ keys(SYM_NUM)
               return false
          end 
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

     var = filter(x -> !isspace(x) && x≠"\"", string)

     !(var=="") || ( return Vec(0.0, 0, 0) )
     
     vector = filter(x -> !isspace(x) && x≠"\"", var)[begin+1:end-1]
	vec = split(vector, ",")
     x = isnothing(tryparse(Float64, vec[1])) ? SYM_NUM[vec[1]] : parse(Float64, vec[1])
     y = isnothing(tryparse(Float64, vec[2])) ? SYM_NUM[vec[2]] : parse(Float64, vec[2])
     z = isnothing(tryparse(Float64, vec[3])) ? SYM_NUM[vec[3]] : parse(Float64, vec[3])

	return Vec(x, y, z)
end


##########################################################################################92


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

     string_without_spaces = filter(x -> !isspace(x), string)

     !(string_without_spaces=="") || (return nothing)

     vec_nameval = split.(split(string_without_spaces, ","), ":" )
     declare_float = Dict{String, Float64}([v[1]=>parse(Float64, v[2]) for v in vec_nameval]...)
     return declare_float
end


##########################################################################################92

