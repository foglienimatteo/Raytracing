# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

@testset "test_parse_tonemapping_settings" begin
     string="""./Raytracer.jl tonemapping --normalization=0.1 --gamma=1.0 --avg_lum=1.0 """*
     """--ONLY_FOR_TESTS prova.pfm prova.png"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "tonemapping"
          @test 1==1
          tone_mapping(parse_tonemapping_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end


##########################################################################################92


@testset "test_parse_demo_settings" begin
     string="""./Raytracer.jl demo --camera_type=per --camera_position="[1 , 2 , 3]" """*
     """--alpha=30. --width=40 --height=30 --normalization=0.1 --gamma=1.0 --avg_lum=1.0 """*
     """--world_type="B" --set_pfm_name="prova.pfm" --set_png_name="prova.png" --samples_per_pixel=16 --ONLY_FOR_TESTS onoff"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo"
          @test 1==1
          demo(parse_demo_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end


@testset "test_parse_demo_onoff_settings" begin
     string="""./Raytracer.jl demo --ONLY_FOR_TESTS onoff --background_color="<1,2,3>" """*
     """--color="<4,  5,  6>" """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo"
          @test 1==1
          demo(parse_demo_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end

@testset "test_parse_demo_flat_settings" begin
     string="""./Raytracer.jl demo --ONLY_FOR_TESTS flat --background_color="<1,2,3>" """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo"
          @test 1==1
          demo(parse_demo_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end 
end

@testset "test_parse_demo_pathtracer_settings" begin
     string="""./Raytracer.jl demo --ONLY_FOR_TESTS pathtracer --background_color="<1,2,3>" """*
     """--init_state=1 --init_seq=2 --num_of_rays=15 --max_depth=3 --russian_roulette_limit=1"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo"
          @test 1==1
          demo(parse_demo_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end

@testset "test_parse_demo_pointlight_settings" begin
     string="""./Raytracer.jl demo --ONLY_FOR_TESTS pointlight --background_color="<1,2,3>" """*
     """--ambient_color="<4,  5,  6>" --dark_parameter=0.01"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo"
          @test 1==1
          demo(parse_demo_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end 
end


##########################################################################################92


@testset "test_parse_demoanimation_settings" begin
     string="""./Raytracer.jl demo_animation --camera_type="per" --camera_position="[1 , 2 , 3]" """*
     """--width=40 --height=30 --world_type="B" --set_anim_name="prova.mp4" """*
     """--samples_per_pixel=16 --ONLY_FOR_TESTS --normalization=0.1 --gamma=1.0 --avg_lum=1.0 onoff"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo_animation"
          @test 1==1
          demo_animation(parse_demoanimation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end


@testset "test_parse_demoanimation_onoff_settings" begin
     string="""./Raytracer.jl demo_animation --ONLY_FOR_TESTS onoff --background_color="<1,2,3>" """*
     """--color="<4,  5,  6>" """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo_animation"
          @test 1==1
          demo_animation(parse_demoanimation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end

@testset "test_parse_demoanimation_flat_settings" begin
     string="""./Raytracer.jl demo_animation --ONLY_FOR_TESTS flat --background_color="<1,2,3>" """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo_animation"
          @test 1==1
          demo_animation(parse_demoanimation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end 
end

@testset "test_parse_demoanimation_pathtracer_settings" begin
     string="""./Raytracer.jl demo_animation --ONLY_FOR_TESTS pathtracer --background_color="<1,2,3>" """*
     """--init_state=1 --init_seq=2 --num_of_rays=15 --max_depth=3 --russian_roulette_limit=1"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo_animation"
          @test 1==1
          demo_animation(parse_demoanimation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end

@testset "test_parse_demoanimation_pointlight_settings" begin
     string="""./Raytracer.jl demo_animation --ONLY_FOR_TESTS pointlight --background_color="<1,2,3>" """*
     """--ambient_color="<4,  5,  6>" --dark_parameter=0.01 """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "demo_animation"
          @test 1==1
          demo_animation(parse_demoanimation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end 
end



##########################################################################################92


@testset "test_parse_render_settings" begin
     string="""./Raytracer.jl render --camera_type="per" --camera_position="[1 , 2 , 3]" """*
     """--alpha=30. --width=40 --height=30 --set_pfm_name="prova.pfm" """*
     """--set_png_name="prova.png" --samples_per_pixel=16 --ONLY_FOR_TESTS """*
     """--normalization=0.1 --gamma=1.0 --avg_lum=1.0 examples/tutorial_basic_syntax.txt onoff """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "render"
          @test 1==1
          render(parse_render_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end


@testset "test_parse_render_onoff_settings" begin
     string="""./Raytracer.jl render --ONLY_FOR_TESTS examples/tutorial_basic_syntax.txt onoff """*
     """--background_color="<1,2,3>" --color="<4,  5,  6>" """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "render"
          @test 1==1
          render(parse_render_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end

@testset "test_parse_render_flat_settings" begin
     string="""./Raytracer.jl render --ONLY_FOR_TESTS examples/tutorial_basic_syntax.txt flat """*
     """--background_color="<1,2,3>" """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "render"
          @test 1==1
          render(parse_render_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end 
end

@testset "test_parse_render_pathtracer_settings" begin
     string="""./Raytracer.jl render --ONLY_FOR_TESTS examples/tutorial_basic_syntax.txt pathtracer """*
     """--background_color="<1,2,3>" --init_state=1 --init_seq=2 --num_of_rays=15 --max_depth=3 --russian_roulette_limit=1"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "render"
          @test 1==1
          render(parse_render_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
end

@testset "test_parse_render_pointlight_settings" begin
     string="""./Raytracer.jl render --ONLY_FOR_TESTS examples/tutorial_basic_syntax.txt pointlight """*
     """--background_color="<1,2,3>" --ambient_color="<4,  5,  6>" --dark_parameter=0.01"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "render"
          @test 1==1
          render(parse_render_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end 
end



##########################################################################################92


@testset "test_parse_render_animation_settings" begin
     # cd("..")

     try
          file = open("./examples/tutorial_basic_syntax.txt", "r") do file	# read( ) legge già di base i bytes grezzi,
               read(file)
          end
          global tut_file_name_3 = """./examples/tutorial_basic_syntax.txt"""

     catch SystemError

          global tut_file_name_3 = """tutorial_basic_syntax.txt"""

     end

     string="""./Raytracer.jl animation --camera_type="per" --camera_position="[1 , 2 , 3]" """*
     """--alpha=30. --width=40 --height=30 --set_anim_name="prova.mp4" """*
     """--normalization=0.1 --gamma=1.0 --avg_lum=1.0 --samples_per_pixel=16 --ONLY_FOR_TESTS """*
     """--function=my_function --vec_variables=[float] --iterable=1:2 """*
     tut_file_name_3 * """ onoff """
     #"""tutorial_basic_syntax.txt onoff """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "animation"
          @test 1==1
          render_animation(parse_render_animation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
     # cd("..")
end


@testset "test_parse_animation_onoff_settings" begin
     # cd("..")

     try
          file = open("./examples/tutorial_basic_syntax.txt", "r") do file	# read( ) legge già di base i bytes grezzi,
               read(file)
          end
          global tut_file_name_4 = """./examples/tutorial_basic_syntax.txt"""

     catch SystemError

          global tut_file_name_4 = """tutorial_basic_syntax.txt"""

     end

     string="""./Raytracer.jl animation --ONLY_FOR_TESTS --function=my_function --vec_variables=[float] --iterable=1:2 """*
     tut_file_name_4 * """ onoff """*
     """--background_color="<1,2,3>" --color="<4,  5,  6>" """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "animation"
          @test 1==1
          render_animation(parse_render_animation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
     # cd("..")
end

@testset "test_parse_animation_flat_settings" begin
     # cd("..")

     try
          file = open("./examples/tutorial_basic_syntax.txt", "r") do file	# read( ) legge già di base i bytes grezzi,
               read(file)
          end
          global tut_file_name_5 = """./examples/tutorial_basic_syntax.txt"""

     catch SystemError

          global tut_file_name_5 = """tutorial_basic_syntax.txt"""

     end

     string="""./Raytracer.jl animation --ONLY_FOR_TESTS --function=my_function --vec_variables=[float] --iterable=1:2 """*
     tut_file_name_5 * """ flat """*
     """--background_color="<1,2,3>" """
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "animation"
          @test 1==1
          render_animation(parse_render_animation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end 
     # cd("..")
end

@testset "test_parse_animation_pathtracer_settings" begin
     # cd("..")

     try
          file = open("./examples/tutorial_basic_syntax.txt", "r") do file	# read( ) legge già di base i bytes grezzi,
               read(file)
          end
          global tut_file_name_6 = """./examples/tutorial_basic_syntax.txt"""

     catch SystemError

          global tut_file_name_6 = """tutorial_basic_syntax.txt"""
     
     end


     string="""./Raytracer.jl animation --ONLY_FOR_TESTS --function=my_function --vec_variables=[float] --iterable=1:2 """*
     tut_file_name_6 * """ pathtracer """*
     """--background_color="<1,2,3>" --init_state=1 --init_seq=2 --num_of_rays=15 --max_depth=3 --russian_roulette_limit=1"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "animation"
          @test 1==1
          render_animation(parse_render_animation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
     # cd("..")
end

@testset "test_parse_animation_pointlight_settings" begin
     # cd("..")

     try
          file = open("./examples/tutorial_basic_syntax.txt", "r") do file	# read( ) legge già di base i bytes grezzi,
               read(file)
          end
          global tut_file_name_7 = """./examples/tutorial_basic_syntax.txt"""

     catch SystemError

          global tut_file_name_7 = """tutorial_basic_syntax.txt"""
     
     end

     string="""./Raytracer.jl animation --ONLY_FOR_TESTS --function=my_function --vec_variables=[float] --iterable=1:2 """*
     tut_file_name_7 * """ pointlight """*
     """--background_color="<1,2,3>" --ambient_color="<4,  5,  6>" --dark_parameter=0.01"""
     args = Raytracing.from_CLI_to_vecstring(string)
     parsed_arguments = ArgParse_command_line(args)
	(isnothing(parsed_arguments)) && (return nothing)

	parsed_command = parsed_arguments["%COMMAND%"]
	parsed_settings = parsed_arguments[parsed_command]

     if parsed_command == "animation"
          @test 1==1
          render_animation(parse_render_animation_settings(parsed_settings)...)
          @test 1==1
     else
          @test 1==2
     end
     # cd("..") 
end

