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

#=
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
=#


function ArgParse_command_line(arguments)
	s = ArgParseSettings()

	s.description = "Raytracer for the generation of photorealistic images in Julia."
	#s.exc_handler = parse_commandline_error_handler
	s.version = @project_version

	@add_arg_table! s begin
		"demo"
			action = :command
			help = "create a standard image that checks the correct behaviour of the program"
		"demo_animation"
			action = :command
			help = "create an animation of a 360 degree rotation of the demo image"
		"tonemapping"
			action = :command
			help = "apply tone mapping to a pfm image and save it as a ldr file"
		"render"
			action = :command
			help = "render an image from a file"
		"animation"
			action = :command
			help = "render an animation from a file"
	end


	#### TONE MAPPING ###################################################################92


	s["tonemapping"].description = "Apply tone mapping to a pfm image and save it as a ldr file"
	
	add_arg_group!(s["tonemapping"], "tonemapping filenames");
	@add_arg_table! s["tonemapping"] begin
		"infile"
			help = "path to input file, it must be a PFM file"
			#range_tester = input -> (typeof(query(input))<:File{format"PFM"})
			required = true
		"outfile"
			help = "output file name"
			required = true
	end

	add_arg_group!(s["tonemapping"], "tonemapping settings");
	@add_arg_table! s["tonemapping"] begin
		"--alpha", "-a"
			help = "scaling factor for the normalization process; must be positive"
			arg_type = Float64
			range_tester = check_is_positive
			default = 0.18
		"--gamma", "-g"
			help = "gamma value for the tone mapping process; must be positive"
			arg_type = Float64
			range_tester = check_is_positive
			default = 1.27
		"--ONLY_FOR_TESTS"
			help = "only for testing flag; do not use it"
			action = :store_true
	end


	#### DEMO ###########################################################################92


	s["demo"].description = 
		"""Creates a demo image with the specified options.\n"""*
		"""There are two possible demo image "world" to be """*
		"""rendered, specified through the input string `--world-type`.\n\n"""*
		"""The `type=="A"` demo image world consist in a set of 10 spheres of equal radius 0.1:"""*
		"""8 spheres are placed at the verteces of a cube of side 1.0, one in the center of"""*
		"""the lower cube face and the last one in the center of the left cube face.\n\n"""*
		"""The `type=="B"` demo image world consists in a checked x-y plane, a blue opaque"""* 
		"""sphere, a red reflecting sphere, and a green oblique reflecting plane, all"""*
		"""inside a giant emetting sphere.\n\n"""*
		"""The creation of the demo image has the objective to check the correct behaviour of
		the rendering software, specifically the orientation upside-down and left-right."""

	add_arg_group!(s["demo"], "render options");
	@add_arg_table! s["demo"] begin
		"--camera_type"
			help = "option for the camera type:\n"*
	    				"ort -> Orthogonal camera, per -> Perspective camera"
          	arg_type = String
			default = "per"
			range_tester = input -> check_is_one_of(input, CAMERAS)
		"--camera_position"
          	help = "camera position in the scene as '[X,Y,Z]'"
          	arg_type = String
          	default = "[-1,0,0]"
          	range_tester = check_is_vector
		"--alpha"
			help = "angle of view around z-axis, in degrees"
			arg_type = Float64
			default = 0.
		"--width"
			help = "pixel number on the width of the resulting demo image."
			default = 640
			range_tester = check_is_even_uint64
		"--height"
			help = "pixel number on the height of the resulting demo image."
			default = 480
			range_tester = check_is_even_uint64
     	"--samples_per_pixel"
			help = "Number of samples per pixel for the antialiasing algorithm\n"*
					"It must be an integer perfect square, i.e. 0,1,4,9,16,...\n"*
					"If =0 (default value), antialiasing does not occurs."
     		default = 0
			range_tester = check_is_square
		"--world_type"
          	help = "world type to be rendered; valid values: $(DEMO_WORLD_TYPES)"
          	arg_type = String
          	default = "A"
          	range_tester = input -> check_is_one_of(input, DEMO_WORLD_TYPES)
		"--set_pfm_name"
			help = "name of the pfm file to be saved"
			nargs = '?'
			arg_type = String
			default = "demo.pfm"
			constant = "demo.pfm"
		"--set_png_name"
			help = "name of the png file to be saved"
			nargs = '?'
			arg_type = String
			default = "demo.png"
			constant = "demo.png"
		"--ONLY_FOR_TESTS"
			help = "only for testing flag; do not use it"
			action = :store_true
	end
	
	
	add_arg_group!(s["demo"], "renderer to be used");
	@add_arg_table! s["demo"] begin
		"onoff"
			action = :command
			help = "onoff renderer"
			#dest_name = "onoff"
		"flat"
			action = :command
			help = "flat-renderer"
			#dest_name = "flat"
		"pathtracer"
			action = :command
			help = "path tracing renderer"
			#dest_name = "pathtracer"
		"pointlight"
			action = :command
			help = "point-light tracing renderer"
			#dest_name = "pointlight"
	end

	add_arg_group!(s["demo"]["onoff"], "onoff renderer options");
	@add_arg_table! s["demo"]["onoff"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--color"
			help = "hit color specified as '<R,G,B>' components. Example: --ambient_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end

	add_arg_group!(s["demo"]["flat"], "flat renderer options");
	@add_arg_table! s["demo"]["flat"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end

	add_arg_group!(s["demo"]["pathtracer"], "pathtracing renderer options");
	@add_arg_table! s["demo"]["pathtracer"] begin
		"--init_state"
    			help = "Initial seed for the random number generator (positive integer number)."
    			default = 45
			range_tester = check_is_uint64
    		"--init_seq"
    			help = "Identifier of the sequence produced by the "*
			    "random number generator (positive integer number)."
    			default = 54
			range_tester = check_is_uint64
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--num_of_rays" 
			help = "number of `Ray`s generated for each integral evaluation"
			default = 10
			range_tester = check_is_uint64
		"--max_depth"
			help = "maximal number recursive integrations"
			default = 3
			range_tester = check_is_uint64
		"--russian_roulette_limit"
			help = "depth at whitch the Russian Roulette algorithm begins"
			default = 2
			range_tester = check_is_uint64
	end

	add_arg_group!(s["demo"]["pointlight"], "pointlight renderer options");
	@add_arg_table! s["demo"]["pointlight"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--ambient_color"
			help = "ambient color specified as '<R,G,B>' components. Example: --ambient_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end


	#### DEMO_ANIMATION #################################################################92


	s["demo_animation"].description = "creates an animation of a 360 degree rotation around"*
								"vertical axis of the demo image."

	add_arg_group!(s["demo_animation"], "demo_animation settings");
	@add_arg_table! s["demo_animation"] begin
		"--camera_type"
			help = "option for the camera type:\n"*
	    				"ort -> Orthogonal camera, per -> Perspective camera"
          	arg_type = String
			default = "per"
			range_tester = input -> check_is_one_of(input, CAMERAS)
		"--camera_position"
          	help = "camera position in the scene as '[X,Y,Z]'"
          	arg_type = String
          	default = "[-1,0,0]"
          	range_tester = check_is_vector
		"--width"
			help = "pixel number on the width of the resulting demo image."
			default = 640
			range_tester = check_is_even_uint64
		"--height"
			help = "pixel number on the height of the resulting demo image."
			default = 480
			range_tester = check_is_even_uint64
     	"--samples_per_pixel"
			help = "Number of samples per pixel for the antialiasing algorithm\n"*
					"It must be an integer perfect square, i.e. 0,1,4,9,16,...\n"*
					"If =0 (default value), antialiasing does not occurs."
     		default = 0
			range_tester = check_is_square
		"--world_type"
          	help = "world type to be rendered; valid values: $(DEMO_WORLD_TYPES)"
          	arg_type = String
          	default = "A"
          	range_tester = input -> check_is_one_of(input, DEMO_WORLD_TYPES)
		"--set_anim_name"
			help = "name of the animation file to be saved"
			nargs = '?'
			arg_type = String
			default = "demo_animation.mp4"
			constant = "demo_animation.mp4"
		"--ONLY_FOR_TESTS"
			help = "only for testing flag; do not use it"
			action = :store_true
	end

	add_arg_group!(s["demo_animation"], "renderer to be used");
	@add_arg_table! s["demo_animation"] begin
		"onoff"
			action = :command
			help = "onoff renderer"
			#dest_name = "onoff"
		"flat"
			action = :command
			help = "flat-renderer"
			#dest_name = "flat"
		"pathtracer"
			action = :command
			help = "path tracing renderer"
			#dest_name = "pathtracer"
		"pointlight"
			action = :command
			help = "point-light tracing renderer"
			#dest_name = "pointlight"
	end

	add_arg_group!(s["demo_animation"]["onoff"], "onoff renderer options");
	@add_arg_table! s["demo_animation"]["onoff"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--color"
			help = "hit color specified as '<R,G,B>' components. Example: --ambient_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end

	add_arg_group!(s["demo_animation"]["flat"], "flat renderer options");
	@add_arg_table! s["demo_animation"]["flat"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end

	add_arg_group!(s["demo_animation"]["pathtracer"], "pathtracing renderer options");
	@add_arg_table! s["demo_animation"]["pathtracer"] begin
		"--init_state"
    			help = "Initial seed for the random number generator (positive integer number)."
    			default = 45
			range_tester = check_is_uint64
    		"--init_seq"
    			help = "Identifier of the sequence produced by the "*
			    "random number generator (positive integer number)."
    			default = 54
			range_tester = check_is_uint64
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--num_of_rays" 
			help = "number of `Ray`s generated for each integral evaluation"
			default = 10
			range_tester = check_is_uint64
		"--max_depth"
			help = "maximal number recursive integrations"
			default = 3
			range_tester = check_is_uint64
		"--russian_roulette_limit"
			help = "depth at whitch the Russian Roulette algorithm begins"
			default = 2
			range_tester = check_is_uint64
	end

	add_arg_group!(s["demo_animation"]["pointlight"], "pointlight renderer options");
	@add_arg_table! s["demo_animation"]["pointlight"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--ambient_color"
			help = "ambient color specified as '<R,G,B>' components. Example: --ambient_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end


	#### RENDER #########################################################################92

	@add_arg_table! s["render"] begin
		"scenefile"
			help = "path to the file describing the scene to be rendered."
			arg_type = String
			#range_tester = input -> (typeof(query(input))<:File{format"PFM"})
			required = true
	end

	add_arg_group!(s["render"], "render options");
	@add_arg_table! s["render"] begin
		"--camera_type"
			help = "option for the camera type:\n"*
	    				"ort -> Orthogonal camera, per -> Perspective camera"
          	arg_type = String
			default = "per"
			range_tester = input -> check_is_one_of(input, CAMERAS)
		"--camera_position"
          	help = "camera position in the scene as '[X,Y,Z]'"
          	arg_type = String
          	default = "[-1,0,0]"
          	range_tester = check_is_vector
		"--alpha"
			help = "angle of view around z-axis, in degrees"
			arg_type = Float64
			default = 0.
		"--width"
			help = "pixel number on the width of the resulting demo image."
			default = 640
			range_tester = check_is_even_uint64
		"--height"
			help = "pixel number on the height of the resulting demo image."
			default = 480
			range_tester = check_is_even_uint64
     	"--samples_per_pixel"
			help = "Number of samples per pixel for the antialiasing algorithm\n"*
					"It must be an integer perfect square, i.e. 0,1,4,9,16,...\n"*
					"If =0 (default value), antialiasing does not occurs."
     		default = 0
			range_tester = check_is_square
		"--ONLY_FOR_TESTS"
			help = "only for testing flag; do not use it"
			action = :store_true
	end

	add_arg_group!(s["render"], 
		"render declare options for a scene; this options"*
		"allows to modify values of the scene without changing"*
		"the scenefile directly."
	);
	@add_arg_table! s["render"] begin
		"--declare_float"
			help = "Declare a variable. The syntax is «--declare-float=VAR:VALUE». Example: --declare_float=clock:150"
          	arg_type = String
			default = ""
			range_tester = check_is_declare_float
		end

	add_arg_group!(s["render"], "renderer to be used");
	@add_arg_table! s["render"] begin
		"onoff"
			action = :command
			help = "onoff renderer"
			#dest_name = "onoff"
		"flat"
			action = :command
			help = "flat-renderer"
			#dest_name = "flat"
		"pathtracer"
			action = :command
			help = "path tracing renderer"
			#dest_name = "pathtracer"
		"pointlight"
			action = :command
			help = "point-light tracing renderer"
			#dest_name = "pointlight"
	end

	add_arg_group!(s["render"]["onoff"], "onoff renderer options");
	@add_arg_table! s["render"]["onoff"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--color"
			help = "hit color specified as '<R,G,B>' components. Example: --ambient_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end

	add_arg_group!(s["render"]["flat"], "flat renderer options");
	@add_arg_table! s["render"]["flat"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end

	add_arg_group!(s["render"]["pathtracer"], "pathtracing renderer options");
	@add_arg_table! s["render"]["pathtracer"] begin
		"--init_state"
    			help = "Initial seed for the random number generator (positive integer number)."
    			default = 45
			range_tester = check_is_uint64
    		"--init_seq"
    			help = "Identifier of the sequence produced by the "*
			    "random number generator (positive integer number)."
    			default = 54
			range_tester = check_is_uint64
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--num_of_rays" 
			help = "number of `Ray`s generated for each integral evaluation"
			default = 10
			range_tester = check_is_uint64
		"--max_depth"
			help = "maximal number recursive integrations"
			default = 3
			range_tester = check_is_uint64
		"--russian_roulette_limit"
			help = "depth at whitch the Russian Roulette algorithm begins"
			default = 2
			range_tester = check_is_uint64
	end

	add_arg_group!(s["render"]["pointlight"], "pointlight renderer options");
	@add_arg_table! s["render"]["pointlight"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--ambient_color"
			help = "ambient color specified as '<R,G,B>' components. Example: --ambient_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end

	#### RENDER_ANIMATION #########################################################################92

	@add_arg_table! s["animation"] begin
		"--function"
			help = "name of the function that will be used to render the animation."
			arg_type = String
			range_tester = check_is_function
			required = true
		"--vec_variables"
			help = "vector of variable names that will change from frame to frame.\n"*
					"Must be declared as:  --vec_variables= \"[name1, name2, ...] \""
			arg_type = String
			range_tester = check_is_vec_variables
			required = true
		"--iterable"
			help = "iterable object from with the function will calcuate le variable values."
			arg_type = String
			range_tester = check_is_iterable
			required = true
		"scenefile"
			help = "path to the file describing the scene to be rendered."
			arg_type = String
			#range_tester = input -> (typeof(query(input))<:File{format"PFM"})
			required = true
	end

	add_arg_group!(s["animation"], "animation options");
	@add_arg_table! s["animation"] begin
		"--camera_type"
			help = "option for the camera type:\n"*
	    				"ort -> Orthogonal camera, per -> Perspective camera"
          	arg_type = String
			default = "per"
			range_tester = input -> check_is_one_of(input, CAMERAS)
		"--camera_position"
          	help = "camera position in the scene as '[X,Y,Z]'"
          	arg_type = String
          	default = "[-1,0,0]"
          	range_tester = check_is_vector
		"--alpha"
			help = "angle of view around z-axis, in degrees"
			arg_type = Float64
			default = 0.
		"--width"
			help = "pixel number on the width of the resulting demo image."
			default = 640
			range_tester = check_is_even_uint64
		"--height"
			help = "pixel number on the height of the resulting demo image."
			default = 480
			range_tester = check_is_even_uint64
     	"--samples_per_pixel"
			help = "Number of samples per pixel for the antialiasing algorithm\n"*
					"It must be an integer perfect square, i.e. 0,1,4,9,16,...\n"*
					"If =0 (default value), antialiasing does not occurs."
     		default = 0
			range_tester = check_is_square
		"--ONLY_FOR_TESTS"
			help = "only for testing flag; do not use it"
			action = :store_true
	end

	add_arg_group!(s["animation"], 
		"animation declare options for a scene; this options"*
		"allows to modify values of the scene without changing"*
		"the scenefile directly."
	);
	@add_arg_table! s["animation"] begin
		"--declare_float"
			help = "Declare a variable. The syntax is «--declare-float=VAR:VALUE». Example: --declare_float=clock:150"
          	arg_type = String
			default = ""
			range_tester = check_is_declare_float
		end

	add_arg_group!(s["animation"], "renderer to be used");
	@add_arg_table! s["animation"] begin
		"onoff"
			action = :command
			help = "onoff renderer"
			#dest_name = "onoff"
		"flat"
			action = :command
			help = "flat-renderer"
			#dest_name = "flat"
		"pathtracer"
			action = :command
			help = "path tracing renderer"
			#dest_name = "pathtracer"
		"pointlight"
			action = :command
			help = "point-light tracing renderer"
			#dest_name = "pointlight"
	end

	add_arg_group!(s["animation"]["onoff"], "onoff renderer options");
	@add_arg_table! s["animation"]["onoff"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--color"
			help = "hit color specified as '<R,G,B>' components. Example: --ambient_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end

	add_arg_group!(s["animation"]["flat"], "flat renderer options");
	@add_arg_table! s["animation"]["flat"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end

	add_arg_group!(s["animation"]["pathtracer"], "pathtracing renderer options");
	@add_arg_table! s["animation"]["pathtracer"] begin
		"--init_state"
    			help = "Initial seed for the random number generator (positive integer number)."
    			default = 45
			range_tester = check_is_uint64
    		"--init_seq"
    			help = "Identifier of the sequence produced by the "*
			    "random number generator (positive integer number)."
    			default = 54
			range_tester = check_is_uint64
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--num_of_rays" 
			help = "number of `Ray`s generated for each integral evaluation"
			default = 10
			range_tester = check_is_uint64
		"--max_depth"
			help = "maximal number recursive integrations"
			default = 3
			range_tester = check_is_uint64
		"--russian_roulette_limit"
			help = "depth at whitch the Russian Roulette algorithm begins"
			default = 2
			range_tester = check_is_uint64
	end

	add_arg_group!(s["animation"]["pointlight"], "pointlight renderer options");
	@add_arg_table! s["animation"]["pointlight"] begin
		"--background_color"
			help = "background color specified as '<R,G,B>' components. Example: --background_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
		"--ambient_color"
			help = "ambient color specified as '<R,G,B>' components. Example: --ambient_color=<1,2,3>"
          	arg_type = String
          	default = "<0,0,0>"
          	range_tester = check_is_color
	end


	#### parse_args #####################################################################92

##########################################################################################92


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
	print_ArgParseSettings(parsed_arguments)

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