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
# IN THE SOFTWARE.


using Pkg
Pkg.activate(normpath(@__DIR__))

using Colors, Images, ImageIO, ArgParse
using ColorTypes:RGB
import FileIO: @format_str, query
using Raytracing

FILE_NAME = split(PROGRAM_FILE, "/")[end]
RENDERERS = ["onoff", "flat", "pathtracing"]

function parse_commandline_error_handler(settings::ArgParseSettings, err, err_code::Int = 1)
	help_string = 
		"execute one of the following to get the help instructions:\n"*
		"\t- from the CLI: \t\tjulia $(FILE_NAME) --help\n"*
		"\t- from the CLI: \t\t./$FILE_NAME --help\n"*
		"\t- inside the Julia REPL: \tinclude(\"$(FILE_NAME)\n)"

    if occursin("no command given", err.text)
     	println("\nERROR: no input command were given.\n"*help_string)
	elseif occursin("unknown command", err.text)
		println(
			"\nERROR, $(err.text)\n"*
			usage_string(settings)*"\n\n"*
			help_string)
    elseif occursin("out of range input for input_file:", err.text)
     	println(stderr, "input_file is not a PFM file")
	elseif  occursin("too many", err.text) &&  occursin("usage: $(FILE_NAME) demo", usage_string(settings))
		ArgParse.show_help(settings)
	else
     	println(stderr, err.text, "\n" , usage_string(settings))
		#ArgParse.show_help(settings)
    	end
	 
	throw(ArgumentError("error code : $err_code"))
	#exit(err_code)
	#return err_code
end

function ArgParse_command_line(arguments)
	s = ArgParseSettings()

	s.description = "Raytracer for the generation of photorealistic images in Julia."
	s.exc_handler = parse_commandline_error_handler
	s.version = @project_version

	@add_arg_table! s begin
		"demo"
			action = :command
			help = "create a standard image that checks the correct behaviour of the program"
		"demo-animation"
			action = :command
			help = "create an animation of a 360 degree rotation of the demo image"
		"tonemapping"
			action = :command
			help = "apply tone mapping to a pfm image and save it as a ldr file"
	end

	s["tonemapping"].description = "Apply tone mapping to a pfm image and save it as a ldr file"
	add_arg_group!(s["tonemapping"], "tonemapping settings");
	@add_arg_table! s["tonemapping"] begin
		"--alpha", "-a"
			help = "scaling factor for the normalization process"
			arg_type = Float64
			default = 0.18
		"--gamma", "-g"
			help = "gamma value for the tone mapping process"
			arg_type = Float64
			default = 1.27
	end
	add_arg_group!(s["tonemapping"], "tonemapping filenames");
	@add_arg_table! s["tonemapping"] begin
		"pfm_infile"
			help = "path to input file, it must be a PFM file"
			#range_tester = input -> (typeof(query(input))<:File{format"PFM"})
			required = true
		"outfile"
			help = "output file name"
			required = true
	end

	s["demo"].description = "Creates a demo.png and a demo.pfm files of 10 white spheres on a dark backgroud. "*
					"8 spheres are placed at the 8 vertexes of a cube, 1 in the middle "*
					"of the left face and the last in the lower one. "*
					"Execute it in order to check the correct placement of the spheres."
	#=
	add_arg_group!(s["demo"], "demo mutually exclusive flags for the viewpoint tipe", exclusive=true)
    	@add_arg_table! s["demo"] begin
    		"--orthogonal", "--ort"
			help = "flag for the Orthogonal projection view"
          	action = :store_true
		"--perspective", "--per"
			help = "flag for the Perspective projection view"
			action = :store_true
    	end
	=#

    	
	add_arg_group!(s["demo"], "demo options");
	@add_arg_table! s["demo"] begin
		"--camera_type", "-t"
			help = "option for the camera type:\n"*
	    				"ort -> Orthogonal camera, per -> Perspective camera"
          	arg_type = String
			default = "per"
			range_tester = input -> (input ∈ ["ort", "per"])
    		"--algorithm", "-r"
			help = "option for the renderer algorithm"
          	arg_type = String
			default = "onoff"
			range_tester = input -> (input ∈ RENDERERS)
		"--world-type", "-l"
			help = "flag for the world to be rendered"
          	arg_type = String
			default = "A"
			range_tester = input -> (input ∈ ["A", "B"])
		"--alpha", "-a"
			help = "angle of view, in degrees"
			arg_type = Float64
			default = 0.
		"--width", "-o"
			help = "pixel number on the width of the resulting demo image."
			arg_type = Int64
			default = 640
			range_tester = iseven
		"--height", "-v"
			help = "pixel number on the height of the resulting demo image."
			arg_type = Int64
			default = 480
			range_tester = iseven
	end
	add_arg_group!(s["demo"], "demo optional filenames");
	@add_arg_table! s["demo"] begin
		"--set-pfm-name", "-A"
			help = "name of the pfm file to be saved"
			nargs = '?'
			arg_type = String
			default = "demo.pfm"
			constant = "demo.pfm"
		"--set-png-name", "-B"
			help = "name of the png file to be saved"
			nargs = '?'
			arg_type = String
			default = "demo.png"
			constant = "demo.png"
	end

	s["demo-animation"].description = "creates an animation of a 360 degree rotation around"*
								"vertical axis of the demo image."
	add_arg_group!(s["demo-animation"], "demo-animation settings");
	@add_arg_table! s["demo-animation"] begin
		"--camera_type", "-t"
			help = "flag for the camera type:\n"*
	    				"ort -> Orthogonal camera, per -> Perspective camera"
          	arg_type = String
			default = "per"
			range_tester = input -> (input ∈ ["ort", "per"])
    		"--algorithm", "-r"
			help = "flag for the renderer algorithm"
          	arg_type = String
			default = "onoff"
			range_tester = input -> (input ∈ RENDERERS)
		"--width", "-o"
			help = "pixel number on the width of the resulting demo image animation."
			arg_type = Int64
			default = 200
			range_tester = iseven
		"--height", "-v"
			help = "pixel number on the height of the resulting demo image animation."
			arg_type = Int64
			default = 150
			range_tester = iseven
	end
	add_arg_group!(s["demo-animation"], "demo-animation optional filename");
	@add_arg_table! s["demo-animation"] begin
		"--set-anim-name", "-A"
			help = "name of the animation file to be saved"
			nargs = '?'
			arg_type = String
			default = "demo-animation.mp4"
			constant = "demo-animation.mp4"
	end

	parse_args(arguments, s)
end

function print_ArgParseSettings(vec::Dict{String,Any})
	parsed_command = vec["%COMMAND%"]
	parsed_args = vec[parsed_command]
     println("\nparsed_command : ", parsed_command)
	println("Parsed args:")
	for (key,val) in parsed_args
		println("  $key \t=>  $(repr(val))")
	end
	print("\n")
end


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
	end

	if parsed_command=="tonemapping"
		#println(parse_tonemapping_settings(parsed_settings))
		tone_mapping(parse_tonemapping_settings(parsed_settings)...)
	end

	if parsed_command=="demo-animation"
		#println(parse_tonemapping_settings(parsed_settings))
		demo_animation(parse_demoanimation_settings(parsed_settings)...)
	end

	return nothing
end

if (ARGS==String[])
	println("\nwithout input arguments/commands, show this help message and exit\n")
	main(["--help"])
else
	main(ARGS)
end