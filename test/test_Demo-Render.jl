# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

@testset "test_parse_demo_settings" begin
     @test isnothing(demo( 
                         "%COMMAND%"=>"onoff",
                         "camera_type"=>"per",
                         "camera_position"=>"[1 , 2 , 3]",
                         "alpha"=>30.,
                         "width"=>40,
                         "height"=>30,
                         "world_type"=>"B" ,
                         "set_pfm_name"=>"prova.pfm",
                         "set_png_name"=>"prova.png",
                         "samples_per_pixel"=>16,
                         "ONLY_FOR_TESTS"=>true,
                    ))

      @test isnothing(demo(
                         "alpha"=>"30.",
                         "width"=>"40",
                         "height"=>"30",
                         "ONLY_FOR_TESTS"=>true
                    ))

     @test isnothing(demo("ONLY_FOR_TESTS"=>true))

     @test_throws ArgumentError demo("infile"=>"prova.pfm", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo("camera_type"=>"new", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo("camera_position"=>"[1 , 2 , 3" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo("alpha"=>"pi greco" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo("width"=>"13" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo("height"=>"14.5" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo("world_type"=>"C", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo("samples_per_pixel"=>3 , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo("world_type"=>"C", "ONLY_FOR_TESTS"=>true)
end


@testset "test_parse_demo_renderer_settings" begin
     @test isnothing(demo(
                    "ONLY_FOR_TESTS"=>true,
                    "%COMMAND%"=>"onoff",
                    "onoff"=>Dict(
                         "background_color"=>"<1,2,3>",
                         "color"=>"<4,  5,  6>",
                         )
                    ))

     @test isnothing(demo(
                    "ONLY_FOR_TESTS"=>true,
                    "%COMMAND%"=>"flat",
                    "flat"=>Dict(
                         "background_color"=>"<1,2,3>",
                         )
                    ))
     
     @test isnothing(demo(
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
     
     @test isnothing(demo(
                    "ONLY_FOR_TESTS"=>true,
                    "%COMMAND%"=>"pointlight",
                    "pointlight"=>Dict(
                         "background_color"=>"<1,2,3>",
                         "ambient_color"=>"<4,  5,  6>",
                         )
                    ))

     @test isnothing(demo("%COMMAND%"=>"onoff", "ONLY_FOR_TESTS"=>true))
     @test isnothing(demo("%COMMAND%"=>"flat", "ONLY_FOR_TESTS"=>true))
     @test isnothing(demo("%COMMAND%"=>"pathtracer", "ONLY_FOR_TESTS"=>true))
     @test isnothing(demo("%COMMAND%"=>"pointlight", "ONLY_FOR_TESTS"=>true))

     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"onoff", "onoff"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"onoff", "onoff"=>Dict("color"=>"[1,2,3]"))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"flat", "flat"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"flat", "flat"=>Dict("background_color"=>"[1,2,3]"))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("init_state"=>"3.14"))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("init_seq"=>-5))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("num_of_rays"=>-1))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("max_depth"=>π))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("russian_roulette_limit"=>-3))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pointlight", "pointlight"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError demo("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pointlight", "pointlight"=>Dict("ambient_color"=>"[1,2,3]"))
end


##########################################################################################92


@testset "test_parse_demoanimation_settings" begin
     @test isnothing(demo_animation( 
                         "%COMMAND%"=>"onoff",
                         "camera_type"=>"per",
                         "camera_position"=>"[1 , 2 , 3]",
                         "width"=>40,
                         "height"=>30,
                         "world_type"=>"B" ,
                         "set_anim_name"=>"prova.mp4",
                         "samples_per_pixel"=>16,
                         "ONLY_FOR_TESTS"=>true,
                    ))

     @test isnothing(demo_animation(
                         "width"=>"40",
                         "height"=>"30",
                         "ONLY_FOR_TESTS"=>true
                    ))

     @test isnothing(demo_animation("ONLY_FOR_TESTS"=>true))

     @test_throws ArgumentError demo_animation("infile"=>"prova.pfm", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo_animation("camera_type"=>"new", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo_animation("camera_position"=>"[1 , 2 , 3" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo_animation("alpha"=>"pi greco" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo_animation("width"=>"13" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo_animation("height"=>"14.5" , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo_animation("world_type"=>"C", "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo_animation("samples_per_pixel"=>3 , "ONLY_FOR_TESTS"=>true)
     @test_throws ArgumentError demo_animation("world_type"=>"C", "ONLY_FOR_TESTS"=>true)
end



@testset "test_parse_demoanimation_renderer_settings" begin
     @test isnothing(demo_animation(
                    "ONLY_FOR_TESTS"=>true,
                    "%COMMAND%"=>"onoff",
                    "onoff"=>Dict(
                         "background_color"=>"<1,2,3>",
                         "color"=>"<4,  5,  6>",
                         )
                    ))

     @test isnothing(demo_animation(
                    "ONLY_FOR_TESTS"=>true,
                    "%COMMAND%"=>"flat",
                    "flat"=>Dict(
                         "background_color"=>"<1,2,3>",
                         )
                    ))
     
     @test isnothing(demo_animation(
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
     
     @test isnothing(demo_animation(
                    "ONLY_FOR_TESTS"=>true,
                    "%COMMAND%"=>"pointlight",
                    "pointlight"=>Dict(
                         "background_color"=>"<1,2,3>",
                         "ambient_color"=>"<4,  5,  6>",
                         )
                    ))

     @test isnothing(demo_animation("%COMMAND%"=>"onoff", "ONLY_FOR_TESTS"=>true))
     @test isnothing(demo_animation("%COMMAND%"=>"flat", "ONLY_FOR_TESTS"=>true))
     @test isnothing(demo_animation("%COMMAND%"=>"pathtracer", "ONLY_FOR_TESTS"=>true))
     @test isnothing(demo_animation("%COMMAND%"=>"pointlight", "ONLY_FOR_TESTS"=>true))

     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"onoff", "onoff"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"onoff", "onoff"=>Dict("color"=>"[1,2,3]"))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"flat", "flat"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"flat", "flat"=>Dict("background_color"=>"[1,2,3]"))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("init_state"=>"3.14"))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("init_seq"=>-5))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("num_of_rays"=>-1))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("max_depth"=>π))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pathtracer", "pathtracer"=>Dict("russian_roulette_limit"=>-3))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pointlight", "pointlight"=>Dict("background_color"=>"<1,2,3"))
     @test_throws ArgumentError demo_animation("ONLY_FOR_TESTS"=>true, "%COMMAND%"=>"pointlight", "pointlight"=>Dict("ambient_color"=>"[1,2,3]"))
end


##########################################################################################92


@testset "test_parse_render_settings" begin
     @test isnothing(render(
                         "scenefile"=>"p",
                         "%COMMAND%"=>"onoff",
                         "camera_type"=>"per",
                         "camera_position"=>"[1 , 2 , 3]",
                         "alpha"=>30.,
                         "width"=>40,
                         "height"=>30,

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
