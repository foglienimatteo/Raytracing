#!/usr/bin/env julia

# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE
#


using Pkg
Pkg.activate(normpath(@__DIR__))

using Colors, Images, ImageIO, ArgParse, Polynomials, Documenter
using ColorTypes:RGB
import FileIO: @format_str, query
using Raytracing

FILE_NAME = split(PROGRAM_FILE, "/")[end]


main(x::Union{String, Float64, Int64}...) = main([string(var) for var in [x...]])
function main(args)
	parsed_arguments = ArgParse_command_line(args) # the result is a Dict{String,Any}
	(isnothing(parsed_arguments)) && (return nothing)
	#print_ArgParseSettings(parsed_arguments)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

	if parsed_command=="demo"
		#println(parse_demo_settings(parsed_settings))
		demo(parse_demo_settings(parsed_settings)...)
	elseif parsed_command=="tonemapping"
		#println(parse_tonemapping_settings(parsed_settings))
		tone_mapping(parse_tonemapping_settings(parsed_settings)...)
	elseif parsed_command=="demo_animation"
		#println(parse_tonemapping_settings(parsed_settings))
		demo_animation(parse_demoanimation_settings(parsed_settings)...)
	elseif parsed_command=="render"
		#println(parse_render_settings(parsed_settings))
		render(parse_render_settings(parsed_settings)...)
	elseif parsed_command=="animation"
		#println(parse_render_settings(parsed_settings))
		render_animation(parse_render_animation_settings(parsed_settings)...)
	else
		throw(ArgumentError("unknown command $(parsed_command)"))
	end

	return nothing
end

if (ARGS==String[])
	println("\nwithout input arguments/commands, show this help message and exit\n")
	main(["--help"])
else
	main(ARGS)
end