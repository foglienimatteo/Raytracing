# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

@testset "test_parse_render_settings" begin
     @test isnothing(render(
                         "scenefile"=>"p",
                         "%COMMAND%"=>"onoff",
                         "camera_type"=>"per",
                         "camera_position"=>"[1 , 2 , 3]",
                         "alpha"=>30.,
                         "width"=>40,
                         "height"=>30,

                         "normalization"=>0.18,
                         "gamma"=>1.0,
                         "avg_lum"=>0.15,

                         "set_pfm_name"=>"prova.pfm",
                         "set_png_name"=>"prova.png",
                         "samples_per_pixel"=>16,
                         "ONLY_FOR_TESTS"=>true,
                    ))

     @test isnothing(render("scenefile"=>"p", 
                         "alpha"=>"30.",
                         "width"=>"40",
                         "height"=>"30",
                         "ONLY_FOR_TESTS"=>true
                    ))

     @test isnothing(render("scenefile"=>"p", "ONLY_FOR_TESTS"=>true))

     @test_throws ArgumentError render("ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render("scenefile"=>"p", "camera_type"=>"new", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render("scenefile"=>"p", "camera_position"=>"[1 , 2 , 3" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render("scenefile"=>"p", "alpha"=>"pi greco" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render("scenefile"=>"p", "width"=>"13" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render("scenefile"=>"p", "height"=>"14.5" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render("scenefile"=>"p", "world_type"=>"B", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render("scenefile"=>"p", "samples_per_pixel"=>3 , "ONLY_FOR_TESTS"=>true)
end

@testset "test_parse_render_renderer_settings" begin
     @test isnothing(render(
                    "ONLY_FOR_TESTS"=>true,
                    "scenefile"=>"p",
                    "%COMMAND%"=>"onoff",
                    "onoff"=>Dict(
                         "background_color"=>"<1,2,3>",
                         "color"=>"<4,  5,  6>",
                         )
                    ))

     @test isnothing(render(
                    "ONLY_FOR_TESTS"=>true,
                    "scenefile"=>"p",
                    "%COMMAND%"=>"flat",
                    "flat"=>Dict(
                         "background_color"=>"<1,2,3>",
                         )
                    ))
     
     @test isnothing(render(
                    "scenefile"=>"p",
                    "ONLY_FOR_TESTS"=>true,
                    "%COMMAND%"=>"pathtracer",
                    "pathtracer"=>Dict(
                         "init_state"=>1,
                         "init_seq"=>1,
                         "background_color"=>"<1,2,3>",
                         "num_of_rays"=>15,
                         "max_depth"=>5,
                         "russian_roulette_limit"=>3,
                         )
                    ))
     
     @test isnothing(render(
                    "ONLY_FOR_TESTS"=>true,
                    "scenefile"=>"p",
                    "%COMMAND%"=>"pointlight",
                    "pointlight"=>Dict(
                         "background_color"=>"<1,2,3>",
                         "ambient_color"=>"<4,  5,  6>",
                         "dark_parameter"=>"1.0",
                         )
                    ))

     @test isnothing(render("scenefile"=>"p","%COMMAND%"=>"onoff", "ONLY_FOR_TESTS"=>true))
     @test isnothing(render("scenefile"=>"p","%COMMAND%"=>"flat", "ONLY_FOR_TESTS"=>true))
     @test isnothing(render("scenefile"=>"p","%COMMAND%"=>"pathtracer", "ONLY_FOR_TESTS"=>true))
     @test isnothing(render("scenefile"=>"p","%COMMAND%"=>"pointlight", "ONLY_FOR_TESTS"=>true))

     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"onoff", "onoff"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"onoff", "onoff"=>Dict("color"=>"[1,2,3]"))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"flat", "flat"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"flat", "flat"=>Dict("background_color"=>"[1,2,3]"))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("init_state"=>"3.14"))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("init_seq"=>-5))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("num_of_rays"=>-1))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("max_depth"=>π))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("russian_roulette_limit"=>-3))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pointlight", "pointlight"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError render("scenefile"=>"p","ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pointlight", "pointlight"=>Dict("ambient_color"=>"[1,2,3]"))
end



##########################################################################################92


@testset "test_parse_render_animation_settings" begin
     # cd("..")
     @test isnothing(render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         
                         "%COMMAND%"=>"onoff",
                         "camera_type"=>"per",
                         "camera_position"=>"[1 , 2 , 3]",
                         "alpha"=>30.,
                         "width"=>40,
                         "height"=>30,

                         "normalization"=>0.18,
                         "gamma"=>1.0,
                         "avg_lum"=>0.15,

                         "set_anim_name"=>"prova.pfm",
                         "samples_per_pixel"=>16,
                         "ONLY_FOR_TESTS"=>true,
                    ))

     @test isnothing(render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt"      ,
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          , 
                         "alpha"=>"30.",
                         "width"=>"40",
                         "height"=>"30",
                         "ONLY_FOR_TESTS"=>true
                    ))

     @test isnothing(render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt"      ,
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          ,
                          "ONLY_FOR_TESTS"=>true))

     @test_throws ArgumentError render_animation("ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt"      ,
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          ,
                          "camera_type"=>"new", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt"      ,
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          ,
                          "camera_position"=>"[1 , 2 , 3" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt"      ,
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          ,
                          "alpha"=>"pi greco" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt"      ,
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          ,
                          "width"=>"13" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt"      ,
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          ,
                          "height"=>"14.5" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt"      ,
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          ,
                          "world_type"=>"B", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt"      ,
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          ,
                          "samples_per_pixel"=>3 , "ONLY_FOR_TESTS"=>true)
     # cd("test")
end

@testset "test_parse_render_animation_renderer_settings" begin
     # cd("..")
     @test isnothing(render_animation(
                    "ONLY_FOR_TESTS"=>true,
                    "function"=>"my_function",
                    "iterable"=>"1:3",
                    "vec_variables"=>"[float]",
                    # "scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                    "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                    "%COMMAND%"=>"onoff",
                    "onoff"=>Dict(
                         "background_color"=>"<1,2,3>",
                         "color"=>"<4,  5,  6>",
                         )
                    ))

     @test isnothing(render_animation(
                    "ONLY_FOR_TESTS"=>true,
                    "function"=>"my_function",
                    "iterable"=>"1:3",
                    "vec_variables"=>"[float]",
                    #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                    "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                    "%COMMAND%"=>"flat",
                    "flat"=>Dict(
                         "background_color"=>"<1,2,3>",
                         )
                    ))
     
     @test isnothing(render_animation(
                    "function"=>"my_function",
                    "iterable"=>"1:3",
                    "vec_variables"=>"[float]",
                    #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                    "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                    "ONLY_FOR_TESTS"=>true,
                    "%COMMAND%"=>"pathtracer",
                    "pathtracer"=>Dict(
                         "init_state"=>1,
                         "init_seq"=>1,
                         "background_color"=>"<1,2,3>",
                         "num_of_rays"=>15,
                         "max_depth"=>5,
                         "russian_roulette_limit"=>3,
                         )
                    ))
     
     @test isnothing(render_animation(
                    "ONLY_FOR_TESTS"=>true,
                    "function"=>"my_function",
                    "iterable"=>"1:3",
                    "vec_variables"=>"[float]",
                    #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                    "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                    "%COMMAND%"=>"pointlight",
                    "pointlight"=>Dict(
                         "background_color"=>"<1,2,3>",
                         "ambient_color"=>"<4,  5,  6>",
                         "dark_parameter"=>"1.0",
                         )
                    ))

     @test isnothing(render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "%COMMAND%"=>"onoff", "ONLY_FOR_TESTS"=>true))
     @test isnothing(render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "%COMMAND%"=>"flat", "ONLY_FOR_TESTS"=>true))
     @test isnothing(render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "%COMMAND%"=>"pathtracer", "ONLY_FOR_TESTS"=>true))
     @test isnothing(render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "%COMMAND%"=>"pointlight", "ONLY_FOR_TESTS"=>true))

     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"onoff", "onoff"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt"          ,
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"onoff", "onoff"=>Dict("color"=>"[1,2,3]"))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"flat", "flat"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"flat", "flat"=>Dict("background_color"=>"[1,2,3]"))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("init_state"=>"3.14"))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("init_seq"=>-5))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("num_of_rays"=>-1))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("max_depth"=>π))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("russian_roulette_limit"=>-3))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pointlight", "pointlight"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError render_animation(
                         "function"=>"my_function",
                         "iterable"=>"1:3",
                         "vec_variables"=>"[float]",
                         #"scenefile"=>"/home/runner/work/Raytracing/Raytracing/examples/tutorial_basic_syntax.txt",
                         "scenefile"=>"./examples/tutorial_basic_syntax.txt",
                         "ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pointlight", "pointlight"=>Dict("ambient_color"=>"[1,2,3]"))
     # cd("test")
end
