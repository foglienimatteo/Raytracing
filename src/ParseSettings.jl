# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


"""
    parse_tonemapping_settings(dict::Dict{String, Any}) 
        :: (String, String, Float64, Float64, Bool)

Parse a `Dict{String, T} where {T}` for the [`tone_mapping`](@ref) function.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(pfm, png, a, γ, ONLY_FOR_TESTS)` containing:

- `pfm::String = dict["infile"]` : input pfm filename (required)

- `png::String = dict["outfile"]` : output LDR filename (required)

- `a::Float64 = string2positive(dict["alpha"])` : scale factor (default = 0.18); it's converted 
  through `string2positive` to a positive floating point number.

- `γ::Float64 = string2positive(dict["gamma"])` : gamma factor (default = 1.0); it's converted 
  through `string2positive` to a positive floating point number.

- `ONLY_FOR_TESTS::Bool = dict["ONLY_FOR_TESTS"]` : it's a bool variable conceived only to
  test the correct behaviour of the renderer for the input arguments; if set to `true`, 
  no rendering is made!

See also:  [`tone_mapping`](@ref), [`string2positive`](@ref)
"""
function parse_tonemapping_settings(dict::Dict{String, T}) where {T}

    keys = ["infile", "outfile", "alpha", "gamma", "ONLY_FOR_TESTS"]

    for pair in dict
        if (pair[1] in keys) ==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for tonemapping function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    haskey(dict, "infile") ? 
        pfm::String = dict["infile"] : 
        throw(ArgumentError("need to specify the input pfm file to be tonemapped"))

    haskey(dict, "outfile") ? 
        png::String = dict["outfile"] : 
        throw(ArgumentError("need to specify the output LDR filename to be saved"))

    a::Float32 = haskey(dict, "alpha") ? string2positive(dict["alpha"]) : 0.18f0

    γ::Float32 = haskey(dict, "gamma") ? string2positive(dict["gamma"]) : 1.0f0

    ONLY_FOR_TESTS::Bool = haskey(dict, "ONLY_FOR_TESTS") ? dict["ONLY_FOR_TESTS"] : false

    return (pfm, png, a, γ, ONLY_FOR_TESTS)
end


##########################################################################################92


"""
    parse_onoff_settings(dict::Dict{String, T}) where {T}
        :: (World, RGB{Float32}, RGB{Float32})

Parse a `Dict{String, T} where {T}` for the initialisation of a `OnOffRenderer`.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(World(), background_color, color)` containing the  
following variables (the corresponding keys are also showed):

- `World():: World` : is the default constructor of the `World` class, which creates
  an empty world; it will be populated in the function that will use the renderer.

- `background_color::RGB{Float32} = string2color(dict["background_color"])` : set the 
  color returned by a light ray which does not hit any object in the scene; the default
  value is `BLACK`, i.e. `RGB{Float32}(0.0, 0.0, 0.0)`.
  The input color value `dict["background_color"]` must be a `String` written in RGB
  components as `"< R , G , B >"`, and it's parsed with the `string2color` function.

- `color::RGB{Float32} = string2color(dict["color"])` : set the color returned by a 
  light ray which does hit any object in the scene; the default value is `WHITE`, i.e. 
  `RGB{Float32}(1.0, 1.0, 1.0)`.
  The input color value `dict["color"]` must be a `String` written in RGB
  components as `"< R , G , B >"`, and it's parsed with the `string2color` function.

See also:  [`Renderer`](@ref), [`OnOffRenderer`](@ref), 
[`World`](@ref), [`string2color`](@ref)
"""
function parse_onoff_settings(dict::Dict{String, T}) where {T}

    keys = [
        "background_color", "color",
    ]

    for pair in dict
        if (pair[1] in keys)==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for onoff-renderer function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    background_color::RGB{Float32} = haskey(dict, "background_color") ? 
        string2color(dict["background_color"]) : 
        RGB{Float32}(0.0, 0.0, 0.0)

    color::RGB{Float32} = haskey(dict, "color") ? 
        string2color(dict["color"]) : 
        RGB{Float32}(1.0, 1.0, 1.0)

    return (World(), background_color, color)
end



"""
    parse_flat_settings(dict::Dict{String, T}) where {T}
        :: (World, RGB{Float32})

Parse a `Dict{String, T} where {T}` for the initialisation of a `FlatRenderer`.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(World(), background_color)` containing the following variables 
(the corresponding keys are also showed):

- `World():: World` : is the default constructor of the `World` class, which creates
  an empty world; it will be populated in the function that will use the renderer.

- `background_color::RGB{Float32} = string2color(dict["background_color"])` : set the 
  color returned by a light ray which does not hit any object in the scene; the default
  value is `BLACK`, i.e. `RGB{Float32}(0.0, 0.0, 0.0)`.
  The input color value `dict["background_color"]` must be a `String` written in RGB
  components as `"< R , G , B >"`, and it's parsed with the `string2color` function.

See also:  [`Renderer`](@ref), [`FlatRenderer`](@ref), 
[`World`](@ref), [`string2color`](@ref)
"""
function parse_flat_settings(dict::Dict{String, T}) where {T}

    keys = [
        "background_color",
    ]

    for pair in dict
        if (pair[1] in keys)==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for onoff-renderer function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    background_color::RGB{Float32} =haskey(dict, "background_color") ? 
        string2color(dict["background_color"]) : 
        RGB{Float32}(0.0, 0.0, 0.0)

    return (World(), background_color,)
end


"""
    parse_pathtracer_settings(dict::Dict{String, T}) where {T}
        :: (World(), RGB{Float32}, PCG, Int64, Int64, Int64)

Parse a `Dict{String, T} where {T}` for the initialisation of a `PathTracer`.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(World(), background_color, PCG(init_state, init_seq), num_of_rays, 
max_depth, russian_roulette_limit, ONLY_FOR_TESTS)` containing the following variables 
(the corresponding keys are also showed):

- `World():: World` : is the default constructor of the `World` class, which creates
  an empty world; it will be populated in the function that will use the renderer.

- `background_color::RGB{Float32} = string2color(dict["background_color"])` : set the 
  color returned by a light ray which does not hit any object in the scene; the default
  value is `BLACK`, i.e. `RGB{Float32}(0.0, 0.0, 0.0)`.
  The input color value `dict["background_color"]` must be a `String` written in RGB
  components as `"< R , G , B >"`, and it's parsed with the `string2color` function.

- `PCG(init_state, init_seq)::PCG` : a mutable struct of the Permuted Congruential 
  Generator (PCG), which is a uniform pseudo-random number generator; you can pass as 
  input two usigned integer that initialize the generator:
  - `init_state::UInt64 = string2int64(dict["init_state"], true)` : set the initial state
    of the PCG; the input value `dict["init_state"]` is parsed thanks to the `string2int64`
    function.
  - `init_seq::UInt64 = string2int64(dict["init_seq"], true)` : set the initial sequence
    of the PCG; the input value `dict["init_seq"]` is parsed thanks to the `string2int64`
    function.

- `num_of_rays::Int64 = string2int64(dict["num_of_rays"])` : set the number of secondary 
  rays that will be fired from each surface point hitted by a light ray; the input value 
  `dict["num_of_rays"]` is parsed thanks to the `string2int64` function.

- `max_depth::Int64 = string2int64(dict["max_depth"])` : set the maximum depth number that 
  the secondary rays are allowed to have; if that value is exceeded, no more secondary rays
  are generated in the hitten points, and the returned color is `BLACK`; the input value 
  `dict["max_depth"]` is parsed thanks to the `string2int64` function.

- `russian_roulette_limit::Int64 = string2int64(dict["russian_roulette_limit"])` : set the 
  depth over which a secondary ray is created with the russian roulette algorithm; the input 
  value `dict["russian_roulette_limit"]` is parsed thanks to the `string2int64` function. 

See also:  [`Renderer`](@ref), [`PathTracer`](@ref), 
[`World`](@ref), [`PCG`](@ref), [`string2color`](@ref), [`string2int64`](@ref)
"""
function parse_pathtracer_settings(dict::Dict{String, T}) where {T}

    keys = [
        "init_state", "init_seq", 
        "background_color", "num_of_rays", "max_depth",
        "russian_roulette_limit",
    ]

    for pair in dict
        if (pair[1] in keys) ==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for path-renderer function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    init_state::UInt64 = haskey(dict, "init_state") ? string2int64(dict["init_state"], true) : UInt64(54)

    init_seq::UInt64 = haskey(dict, "init_seq") ? string2int64(dict["init_seq"], true) : UInt64(45)

    background_color::RGB{Float32} =haskey(dict, "background_color") ? 
        string2color(dict["background_color"]) : 
        RGB{Float32}(0.0, 0.0, 0.0)


    num_of_rays::Int64 = haskey(dict, "num_of_rays") ? string2int64(dict["num_of_rays"]) : 10

    max_depth::Int64 = haskey(dict, "max_depth") ? string2int64(dict["max_depth"]) : 2

    russian_roulette_limit::Int64 = haskey(dict, "russian_roulette_limit") ? 
        string2int64(dict["russian_roulette_limit"]) : 2

    return (World(),
            background_color,
            PCG(init_state, init_seq), 
            num_of_rays, max_depth, 
            russian_roulette_limit,
            )
end



"""
    parse_pointlight_settings(dict::Dict{String, T}) where {T}
        :: (World, RGB{Float32}, RGB{Float32})

Parse a `Dict{String, T} where {T}` for the initialisation of a `PointLightRenderer`.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(World(), background_color, color, ONLY_FOR_TESTS)` containing the following variables 
(the corresponding keys are also showed):

- `World():: World` : is the default constructor of the `World` class, which creates
  an empty world; it will be populated in the function that will use the renderer.

- `background_color::RGB{Float32} = string2color(dict["background_color"])` : set the 
  color returned by a light ray which does not hit any object in the scene;
  the default value is `BLACK`, i.e. `RGB{Float32}(0.0, 0.0, 0.0)`.
  The input color value `dict["background_color"]` must be a `String` written in RGB
  components as `"< R , G , B >"`, and it's parsed with the `string2color` function.

- `ambient_color::RGB{Float32} = string2color(dict["ambient_color"])` : set the minimum 
  color returned by a light ray which hits an object on a point, indipendently that is 
  or is not directy visible from any of the point-light sources in the scene; the default 
  value is `BLACK`, i.e. `RGB{Float32}(0.0, 0.0, 0.0)`.
  The input color value `dict["ambient_color"]` must be a `String` written in RGB
  components as `"< R , G , B >"`, and it's parsed with the `string2color` function.

See also:  [`Renderer`](@ref), [`PointLightRenderer`](@ref), 
[`World`](@ref), [`string2color`](@ref)
"""
function parse_pointlight_settings(dict::Dict{String, T}) where {T}

    keys = [
        "background_color", "ambient_color",
    ]

    for pair in dict
        if (pair[1] in keys)==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for onoff-renderer function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    background_color::RGB{Float32} =haskey(dict, "background_color") ? 
        string2color(dict["background_color"]) : 
        RGB{Float32}(0.0, 0.0, 0.0)

    ambient_color::RGB{Float32} =haskey(dict, "ambient_color") ? 
        string2color(dict["ambient_color"]) : 
        RGB{Float32}(0.0, 0.0, 0.0)

    return (World(), background_color, ambient_color)
end


##########################################################################################92


"""
    parse_demo_settings(dict::Dict{String, T}) where {T}
        :: (
            Renderer, Point, Vec, Float64, Int64, Int64, String, String,
            Int64, String, Bool, Bool, Bool,
            )

Parse a `Dict{String, T} where {T}` for the `demo` function.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(renderer, camera_type, camera_position, α, width, height, pfm, png,
samples_per_pixel, world_type, bool_print, bool_savepfm)` containing the 
following variables (the corresponding keys are also showed):

- `renderer::Renderer = haskey(dict, "renderer") ? dict["renderer"] : dict["%COMMAND%"]` :
  it's the renderer to be used (with a default empy `World` that will be populated
  in the `demo` function); the possible keys are two, and must be used differently:
    - the `dict["renderer"]` must contain the renderer itself (i.e. a `Renderer` object);
      if this key exists, it has the priority on the latter key
    - the `dict["%COMMAND%"]` must contain a string that identifies the type of renderer
      to be used, i.e. one of the following strings:
      - `"dict["%COMMAND%"]=>onoff"` -> [`OnOffRenderer`](@ref) algorithm 
      - `"dict["%COMMAND%"]=>"flat"` -> [`FlatRenderer`](@ref) algorithm (default value)
      - `"dict["%COMMAND%"]=>"pathtracing"` -> [`PathTracer`](@ref) algorithm 
      - `"dict["%COMMAND%"]=>"pointlight"` -> [`PointLightRenderer`](@ref) algorithm
      Moreover, in this second case, you can specify the options for the correspoding
      renderer through another dictionary associated with the kkey of the renderer name;
      that options will be parsed thanks to the corresponding functions.
      We shows in the next lines the key-value syntax described:
      - `"onoff"=>Dict{String, T} where {T}` : parsed with [`parse_onoff_settings`](@ref)
      - `"flat"=>Dict{String, T} where {T}` : parsed with [`parse_flat_settings`](@ref)
      - `"pathtracer"=>Dict{String, T} where {T}` : parsed with [`parse_pathtracer_settings`](@ref)
      - `"pointlight"=>Dict{String, T} where {T}` : parsed with [`parse_pointlight_settings`](@ref)

- `camera_type::String = dict["camera_type"]` : set the perspective projection view;
  it must be one of the following values, and this is checked with the 
  `string2stringoneof` function:
  - `"per"` -> set [`PerspectiveCamera`](@ref)  (default value)
  - `"ort"`  -> set [`OrthogonalCamera`](@ref)

- `camera_position::String = typeof(dict["camera_position"]) ∈ [Vec, Point] ? dict["camera_position"] :
  string2vector(dict["camera_position"]) ` : "[X, Y, Z]" coordinates of the 
  choosen observation point of view; it can be specified in two ways:
  - if `typeof(dict["camera_position"])` is a `Vec` or a `Point`, it's passed as-is
  - else, it must be a `String` written in the form "[X, Y, Z]" , and it's parsed through 
    string2vector` to a `Vec` object

- `α::String = dict["alpha"]` : choosen angle of rotation _*IN RADIANTS*_ respect to vertical (i.e. z) 
  axis with a right-handed rule convention (clockwise rotation for entering (x,y,z)-axis 
  corresponds to a positive input rotation angle)

- `width::Int64 = string2evenint64(dict["width"])` : number of pixels on the horizontal 
  axis to be rendered; it's converted through `string2evenint64` to a even positive integer.

- `height::Int64 = string2evenint64(dict["height"])` : number of pixels on the vertical
  axis to be rendered; it's converted through `string2evenint64` to a even positive integer.

- `pfm::String = dict["set_pfm_name"]` : output pfm filename (default `"demo.pfm"`)

- `png::String` = dict["set_png_name"]` : output LDR filename (default `"demo.png"`)

- `samples_per_pixel::Int64  = dict["samples_per_pixel"]` : number of ray to be 
  generated for each pixel, implementing the anti-aliasing algorithm; it must be 
  a perfect integer square (0,1,4,9,...) and this is checked with the 
  `string2rootint64` function; if 0 (default value) is choosen, no anti-aliasing 
  occurs, and only one pixel-centered ray is fired for each pixel.

- `world_type::String = dict["world_type"]` : type of the world to be rendered; it
  must be `"A"` or `"B"`, and this is checked with the `string2stringoneof` function

- `bool_print::Bool = dict["bool_print"]` : if `true` (default value), WIP message of 
  `demo` function are printed (otherwise no; it's useful for the `demo_animation` 
  function)

- `bool_savepfm::Bool = dict["bool_savepfm"]` : if `true` (default value), `demo` 
  function saves the pfm file to disk (otherwise no; it's useful for the 
  `demo_animation` function)

- `ONLY_FOR_TESTS::Bool = dict["ONLY_FOR_TESTS"]` : it's a bool variable conceived only to
  test the correct behaviour of the renderer for the input arguments; if set to `true`, 
  no rendering is made!

See also:  [`demo`](@ref), [`demo_animation`](@ref), [`Renderer`](@ref),
[`Vec`](@ref), [`string2evenint64`](@ref), [`string2stringoneof`](@ref), 
[`string2positive`](@ref), [`string2vector`](@ref), [`string2rootint64`](@ref)
"""
function parse_demo_settings(dict::Dict{String, T}) where {T}

    keys = union([
        "%COMMAND%", "renderer",
        "camera_type", "camera_position",
        "alpha", "width", "height",
        "set_pfm_name", "set_png_name", 
        "samples_per_pixel", "world_type",
        "bool_print", "bool_savepfm",  
        "ONLY_FOR_TESTS",
    ], RENDERERS)

    for pair in dict
        if (pair[1] in keys) ==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for demo function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    renderer = if haskey(dict, "renderer")
        dict["renderer"]
    elseif haskey(dict, "%COMMAND%")
        if dict["%COMMAND%"] == "onoff"
            options = haskey(dict, "onoff") ? dict["onoff"] : Dict{String, Any}()
            OnOffRenderer(parse_onoff_settings(options)...)
        elseif dict["%COMMAND%"] == "flat"
            options = haskey(dict, "flat") ? dict["flat"] : Dict{String, Any}()
            FlatRenderer(parse_flat_settings(options)...)
        elseif dict["%COMMAND%"] == "pathtracer"
            options = haskey(dict, "pathtracer") ? dict["pathtracer"] : Dict{String, Any}()
            PathTracer(parse_pathtracer_settings(options)...)
        elseif dict["%COMMAND%"] == "pointlight"
            options = haskey(dict, "pointlight") ? dict["pointlight"] : Dict{String, Any}()
            PointLightRenderer(parse_pointlight_settings(options)...)
        end
	else
		FlatRenderer()
	end

    camera_type::String = haskey(dict, "camera_type") ? string2stringoneof(dict["camera_type"], CAMERAS) : "per"

    camera_position::Vec = haskey(dict, "camera_position") ? begin
            typeof(dict["camera_position"]) ∈ [Vec, Point] ?
            dict["camera_position"] :
            string2vector(dict["camera_position"]) 
        end : Vec(-1.0 , 0. , 0.)

    α::Float32 = haskey(dict, "alpha") ? begin 
        typeof(dict["alpha"]) <: Number ?
            dict["alpha"] : 
            parse(Float32, dict["alpha"])
        end : 0.0f0

    width::Int64 = haskey(dict, "width") ? string2evenint64(dict["width"]) : 640

    height::Int64 = haskey(dict, "height") ? string2evenint64(dict["height"]) : 480

    pfm::String = haskey(dict, "set_pfm_name") ? dict["set_pfm_name"] : "demo.pfm"

    png::String = haskey(dict, "set_png_name") ? dict["set_png_name"] : "demo.png"

    world_type::String = haskey(dict, "world_type") ? 
        string2stringoneof(dict["world_type"], DEMO_WORLD_TYPES) : "A"

    samples_per_pixel::Int64 = haskey(dict, "samples_per_pixel") ? begin
        check = string2rootint64(dict["samples_per_pixel"])
        string2evenint64(dict["samples_per_pixel"]) 
        end : 0

    bool_print::Bool = haskey(dict, "bool_print") ?  dict["bool_print"] : true
    
    bool_savepfm::Bool = haskey(dict, "bool_savepfm") ? dict["bool_savepfm"] : true

    ONLY_FOR_TESTS::Bool = haskey(dict, "ONLY_FOR_TESTS") ? dict["ONLY_FOR_TESTS"] : false


    return (
            renderer,
            camera_type,
            camera_position, 
            α, 
            width, height, 
            pfm, png,
            samples_per_pixel,
            world_type,
            bool_print, bool_savepfm, 
            ONLY_FOR_TESTS,
        )
end


"""
    parse_demoanimation_settings(dict::Dict{String, T}) where {T}
        :: (
            Renderer, String, Vec, Int64, Int64, String,
            Int64, String, Bool,
            )

Parse a `Dict{String, T} where {T}` for the `demo_animation` function.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(renderer, camera_type, camera_position, width, height, anim, 
samples_per_pixel, world_type)` containing the following variables 
(the corresponding keys are also showed):

- `renderer::Renderer = haskey(dict, "renderer") ? dict["renderer"] : dict["%COMMAND%"]` :
  it's the renderer to be used (with a default empy `World` that will be populated
  in the `demo` function); the possible keys are two, and must be used differently:
    - the `dict["renderer"]` must contain the renderer itself (i.e. a `Renderer` object);
      if this key exists, it has the priority on the latter key
    - the `dict["%COMMAND%"]` must contain a string that identifies the type of renderer
      to be used, i.e. one of the following strings:
      - `"dict["%COMMAND%"]=>onoff"` -> [`OnOffRenderer`](@ref) algorithm 
      - `"dict["%COMMAND%"]=>"flat"` -> [`FlatRenderer`](@ref) algorithm (default value)
      - `"dict["%COMMAND%"]=>"pathtracing"` -> [`PathTracer`](@ref) algorithm 
      - `"dict["%COMMAND%"]=>"pointlight"` -> [`PointLightRenderer`](@ref) algorithm
      Moreover, in this second case, you can specify the options for the correspoding
      renderer through another dictionary associated with the kkey of the renderer name;
      that options will be parsed thanks to the corresponding functions.
      We shows in the next lines the key-value syntax described:
      - `"onoff"=>Dict{String, T} where {T}` : parsed with [`parse_onoff_settings`](@ref)
      - `"flat"=>Dict{String, T} where {T}` : parsed with [`parse_flat_settings`](@ref)
      - `"pathtracer"=>Dict{String, T} where {T}` : parsed with [`parse_pathtracer_settings`](@ref)
      - `"pointlight"=>Dict{String, T} where {T}` : parsed with [`parse_pointlight_settings`](@ref)

- `camera_type::String = dict["camera_type"]` : set the perspective projection view;
  it must be one of the following values, and this is checked with the 
  `string2stringoneof` function:
  - `"per"` -> set [`PerspectiveCamera`](@ref)  (default value)
  - `"ort"`  -> set [`OrthogonalCamera`](@ref)

- `camera_position::String = typeof(dict["camera_position"]) ∈ [Vec, Point] ? dict["camera_position"] :
  string2vector(dict["camera_position"]) ` : "[X, Y, Z]" coordinates of the 
  choosen observation point of view; it can be specified in two ways:
  - if `typeof(dict["camera_position"])` is a `Vec` or a `Point`, it's passed as-is
  - else, it must be a `String` written in the form "[X, Y, Z]" , and it's parsed through 
    string2vector` to a `Vec` object

- `width::Int64 = string2evenint64(dict["width"])` : number of pixels on the horizontal 
  axis to be rendered; it's converted through `string2evenint64` to a even positive integer.

- `height::Int64 = string2evenint64(dict["height"])` : number of pixels on the vertical
  axis to be rendered; it's converted through `string2evenint64` to a even positive integer.

- `anim::String = dict["set_anim_name"]` : output animation filename (default 
  `"demo_animation.mp4"`)

- `samples_per_pixel::Int64  = dict["samples_per_pixel"]` : number of ray to be 
  generated for each pixel, implementing the anti-aliasing algorithm; it must be 
  a perfect integer square (0,1,4,9,...) and this is checked with the 
  `string2rootint64` function; if 0 (default value) is choosen, no anti-aliasing 
  occurs, and only one pixel-centered ray is fired for each pixel.

- `world_type::String = dict["world_type"]` : type of the world to be rendered; it
  must be `"A"` or `"B"`, and this is checked with the `string2stringoneof` function

- `ONLY_FOR_TESTS::Bool = dict["ONLY_FOR_TESTS"]` : it's a bool variable conceived only to
  test the correct behaviour of the renderer for the input arguments; if set to `true`, 
  no rendering is made!

See also:  [`demo`](@ref), [`demo_animation`](@ref), [`Renderer`](@ref),
[`Vec`](@ref), [`string2evenint64`](@ref), [`string2stringoneof`](@ref), 
[`string2positive`](@ref), [`string2vector`](@ref), [`string2rootint64`](@ref)
"""
function parse_demoanimation_settings(dict::Dict{String, T}) where {T}

    keys = union([
        "%COMMAND%", "renderer",
        "camera_type", "camera_position",
        "width", "height",  "world_type",
        "set_anim_name", "samples_per_pixel",
        "ONLY_FOR_TESTS",
    ], RENDERERS)

    for pair in dict
        if (pair[1] in keys) ==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for demo_animation function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    renderer = if haskey(dict, "renderer")
        dict["renderer"]
    elseif haskey(dict, "%COMMAND%")
        if dict["%COMMAND%"] == "onoff"
            options = haskey(dict, "onoff") ? dict["onoff"] : Dict{String, Any}()
            OnOffRenderer(parse_onoff_settings(options)...)
        elseif dict["%COMMAND%"] == "flat"
            options = haskey(dict, "flat") ? dict["flat"] : Dict{String, Any}()
            FlatRenderer(parse_flat_settings(options)...)
        elseif dict["%COMMAND%"] == "pathtracer"
            options = haskey(dict, "pathtracer") ? dict["pathtracer"] : Dict{String, Any}()
            PathTracer(parse_pathtracer_settings(options)...)
        elseif dict["%COMMAND%"] == "pointlight"
            options = haskey(dict, "pointlight") ? dict["pointlight"] : Dict{String, Any}()
            PointLightRenderer(parse_pointlight_settings(options)...)
        end
	else
		FlatRenderer()
	end

    camera_type::String = haskey(dict, "camera_type") ? string2stringoneof(dict["camera_type"], CAMERAS) : "per"
     
    camera_position::Vec = haskey(dict, "camera_position") ? begin
            typeof(dict["camera_position"]) ∈ [Vec, Point] ?
            dict["camera_position"] :
            string2vector(dict["camera_position"]) 
        end : Vec(-1.0 , 0. , 0.)

    width::Int64 = haskey(dict, "width") ? string2evenint64(dict["width"]) : 640

    height::Int64 = haskey(dict, "height") ? string2evenint64(dict["height"]) : 480

    anim::String = haskey(dict, "set_anim_name") ? dict["set_anim_name"] : "demo_animation.mp4"

    samples_per_pixel::Int64 = haskey(dict, "samples_per_pixel") ? begin
        check = string2rootint64(dict["samples_per_pixel"])
        string2evenint64(dict["samples_per_pixel"]) 
        end : 0

    world_type::String = haskey(dict, "world_type") ? 
        string2stringoneof(dict["world_type"], DEMO_WORLD_TYPES) : "A"

    ONLY_FOR_TESTS::Bool = haskey(dict, "ONLY_FOR_TESTS") ? dict["ONLY_FOR_TESTS"] : false


    return (renderer, 
            camera_type, camera_position,
            width, height, anim, 
            samples_per_pixel, world_type, 
            ONLY_FOR_TESTS
            )
end


##########################################################################################92



"""
    parse_render_settings(dict::Dict{String, T}) where {T}
        :: (
            String, Renderer, String, Vec, Float64, Int64, Int64, String,
            String, Int64, Bool, Bool, Dict{String, Float64}, Bool,
            )

Parse a `Dict{String, T} where {T}` for the `render` function.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(scenefile, renderer, camera_type, camera_position, α, width, height, pfm, png,
samples_per_pixel, world_type, bool_print, bool_savepfm, declare_float, ONLY_FOR_TESTS)` 
containing the following variables (the corresponding keys are also showed):

- `scenefile::String = dict["scenefile"]` : name of the scene file to be rendered;
  it must be written with the correct syntax, see the [`tutorial_basic_sintax.txt`](../examples/tutorial_basic_sintax.txt)
  and the [`demo_world_B.txt`](../examples/demo_world_B.txt) files.

- `renderer::Renderer = haskey(dict, "renderer") ? dict["renderer"] : dict["%COMMAND%"]` :
  it's the renderer to be used (with a default empy `World` that will be populated
  in the `demo` function); the possible keys are two, and must be used differently:
    - the `dict["renderer"]` must contain the renderer itself (i.e. a `Renderer` object);
      if this key exists, it has the priority on the latter key
    - the `dict["%COMMAND%"]` must contain a string that identifies the type of renderer
      to be used, i.e. one of the following strings:
      - `"dict["%COMMAND%"]=>onoff"` -> [`OnOffRenderer`](@ref) algorithm 
      - `"dict["%COMMAND%"]=>"flat"` -> [`FlatRenderer`](@ref) algorithm (default value)
      - `"dict["%COMMAND%"]=>"pathtracing"` -> [`PathTracer`](@ref) algorithm 
      - `"dict["%COMMAND%"]=>"pointlight"` -> [`PointLightRenderer`](@ref) algorithm
      Moreover, in this second case, you can specify the options for the correspoding
      renderer through another dictionary associated with the kkey of the renderer name;
      that options will be parsed thanks to the corresponding functions.
      We shows in the next lines the key-value syntax described:
      - `"onoff"=>Dict{String, T} where {T}` : parsed with [`parse_onoff_settings`](@ref)
      - `"flat"=>Dict{String, T} where {T}` : parsed with [`parse_flat_settings`](@ref)
      - `"pathtracer"=>Dict{String, T} where {T}` : parsed with [`parse_pathtracer_settings`](@ref)
      - `"pointlight"=>Dict{String, T} where {T}` : parsed with [`parse_pointlight_settings`](@ref)

- `camera_type::String = dict["camera_type"]` : set the perspective projection view;
  it must be one of the following values, and this is checked with the 
  `string2stringoneof` function:
  - `"per"` -> set [`PerspectiveCamera`](@ref)  (default value)
  - `"ort"`  -> set [`OrthogonalCamera`](@ref)

- `camera_position::String = typeof(dict["camera_position"]) ∈ [Vec, Point] ? dict["camera_position"] :
  string2vector(dict["camera_position"]) ` : "[X, Y, Z]" coordinates of the 
  choosen observation point of view; it can be specified in two ways:
  - if `typeof(dict["camera_position"])` is a `Vec` or a `Point`, it's passed as-is
  - else, it must be a `String` written in the form "[X, Y, Z]" , and it's parsed through 
    string2vector` to a `Vec` object

- `α::String = dict["alpha"]` : choosen angle of rotation _*IN RADIANTS*_ respect to vertical (i.e. z) 
  axis with a right-handed rule convention (clockwise rotation for entering (x,y,z)-axis 
  corresponds to a positive input rotation angle)

- `width::Int64 = string2evenint64(dict["width"])` : number of pixels on the horizontal 
  axis to be rendered; it's converted through `string2evenint64` to a even positive integer.

- `height::Int64 = string2evenint64(dict["height"])` : number of pixels on the vertical
  axis to be rendered; it's converted through `string2evenint64` to a even positive integer.

- `pfm::String = dict["set_pfm_name"]` : output pfm filename (default `"scene.pfm"`)

- `png::String` = dict["set_png_name"]` : output LDR filename (default `"scene.png"`)

- `samples_per_pixel::Int64  = dict["samples_per_pixel"]` : number of ray to be 
  generated for each pixel, implementing the anti-aliasing algorithm; it must be 
  a perfect integer square (0,1,4,9,...) and this is checked with the 
  `string2rootint64` function; if 0 (default value) is choosen, no anti-aliasing 
  occurs, and only one pixel-centered ray is fired for each pixel.

- `bool_print::Bool = dict["bool_print"]` : if `true` (default value), WIP message of 
  `demo` function are printed (otherwise no; it's useful for the `demo_animation` 
  function)

- `bool_savepfm::Bool = dict["bool_savepfm"]` : if `true` (default value), `demo` 
  function saves the pfm file to disk (otherwise no; it's useful for the 
  `demo_animation` function)

- `declare_float::Union{Dict{String, Float64}, Nothing} = declare_float2dict(dict["declare_float"])` 
  : an option for the command line to manually override the values of the float variables in 
  the scene file.
  The input `dict["declare_float"]` must be a `String` written such as `"var1:0.1, var2 : 2.5"`; 
  such a string is parsed through the `declare_float2dict` in a `Dict{String, Float64}` 
  where each overriden variable name (the key) is associated with its float value 
  (`declare_float=>Dict("var1"=>0.1, "var2"=>2.5)`)

- `ONLY_FOR_TESTS::Bool = dict["ONLY_FOR_TESTS"]` : it's a bool variable conceived only to
  test the correct behaviour of the renderer for the input arguments; if set to `true`, 
  no rendering is made!

See also:  [`render`](@ref),  [`Renderer`](@ref),
[`Vec`](@ref), [`string2evenint64`](@ref), [`string2stringoneof`](@ref), 
[`string2positive`](@ref), [`string2vector`](@ref), [`string2rootint64`](@ref),
[`declare_float2dict`](@ref)
"""
function parse_render_settings(dict::Dict{String, T}) where {T}

    keys = [
        "scenefile",
        "%COMMAND%",
        "onoff", "flat", "pathtracer", "pointlight",
        "camera_type", "camera_position", 
        "alpha", "width", "height",
        "set_pfm_name", "set_png_name", 
        "bool_print", "bool_savepfm", 
        "init_state", "init_seq", "samples_per_pixel",
        "declare_float",
        "ONLY_FOR_TESTS",
    ]
  
    for pair in dict
        if (pair[1] in keys)==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for demo function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    haskey(dict, "scenefile") ? 
        scenefile::String = dict["scenefile"] : 
        throw(ArgumentError("need to specify the input scenefile to be rendered"))

    renderer = if haskey(dict, "renderer")
        dict["renderer"]
    elseif haskey(dict, "%COMMAND%")
    if dict["%COMMAND%"] == "onoff"
        options = haskey(dict, "onoff") ? dict["onoff"] : Dict{String, Any}()
        OnOffRenderer(parse_onoff_settings(options)...)
    elseif dict["%COMMAND%"] == "flat"
        options = haskey(dict, "flat") ? dict["flat"] : Dict{String, Any}()
        FlatRenderer(parse_flat_settings(options)...)
    elseif dict["%COMMAND%"] == "pathtracer"
        options = haskey(dict, "pathtracer") ? dict["pathtracer"] : Dict{String, Any}()
        PathTracer(parse_pathtracer_settings(options)...)
    elseif dict["%COMMAND%"] == "pointlight"
        options = haskey(dict, "pointlight") ? dict["pointlight"] : Dict{String, Any}()
        PointLightRenderer(parse_pointlight_settings(options)...)
    end
    else
        FlatRenderer()
    end

    camera_type::Union{String, Nothing} = haskey(dict, "camera_type") ? 
        string2stringoneof(dict["camera_type"], CAMERAS) : 
        nothing

    camera_position::Vec = haskey(dict, "camera_position") ? begin
            typeof(dict["camera_position"]) ∈ [Vec, Point] ?
            dict["camera_position"] :
            string2vector(dict["camera_position"]) 
        end : Vec(-1.0 , 0. , 0.)

    α::Float32 = haskey(dict, "alpha") ? begin 
        typeof(dict["alpha"]) <: Number ?
            dict["alpha"] : 
            parse(Float32, dict["alpha"])
        end : 0.0f0

    width::Int64 = haskey(dict, "width") ? string2evenint64(dict["width"]) : 640

    height::Int64 = haskey(dict, "height") ? string2evenint64(dict["height"]) : 480

    pfm::String = haskey(dict, "set_pfm_name") ? dict["set_pfm_name"] : "scene.pfm"

    png::String = haskey(dict, "set_png_name") ? dict["set_png_name"] : "scene.png"

    bool_print::Bool = haskey(dict, "bool_print") ?  dict["bool_print"] : true
    
    bool_savepfm::Bool = haskey(dict, "bool_savepfm") ? dict["bool_savepfm"] : true

    samples_per_pixel::Int64 = haskey(dict, "samples_per_pixel") ? begin
        check = string2rootint64(dict["samples_per_pixel"])
        string2evenint64(dict["samples_per_pixel"]) 
        end : 0

    declare_float::Union{Dict{String, Float32}, Nothing} = haskey(dict, "declare_float") ?
        declare_float2dict(dict["declare_float"]) : 
        nothing

    ONLY_FOR_TESTS::Bool = haskey(dict, "ONLY_FOR_TESTS") ? dict["ONLY_FOR_TESTS"] : false


    return (
            scenefile,
            renderer,
            camera_type,
            camera_position,
            α, 
            width, height, 
            pfm, png, 
            samples_per_pixel, 
            bool_print, bool_savepfm, 
            declare_float,
            ONLY_FOR_TESTS,
        )
end