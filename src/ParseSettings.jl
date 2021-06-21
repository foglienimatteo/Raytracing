# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


"""
    parse_tonemapping_settings(dict::Dict{String, Any}) 
        :: (String, String, Float64, Float64)

Parse a `Dict{String, T} where {T}` for the [`tone_mapping`](@ref) function.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(pfm, png, a, γ)` containing:

- `pfm::String = dict["infile"]` : input pfm filename (required)

- `png::String = dict["outfile"]` : output LDR filename (required)

- `a::Float64 = dict["alpha"]` : scale factor (default = 0.18)

- `γ::Float64 = dict["gamma"]` : gamma factor (default = 1.0)

See also:  [`tone_mapping`](@ref)
"""
function parse_tonemapping_settings(dict::Dict{String, T}) where {T}

    keys = ["infile", "outfile", "alpha", "gamma"]

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

    haskey(dict, "alpha") ? 
        a::Float64 = dict["alpha"] : 
        a = 0.18

    haskey(dict, "gamma") ? 
        γ::Float64 = dict["gamma"] : 
        γ = 1.0

    return (pfm, png, a, γ)
end

"""
    parse_demo_settings(dict::Dict{String, Any}) 
        :: (
            String, Point, String, Float64, Int64, Int64, String, String,
            Bool, Bool, String, Int64, Int64, Int64
            )

Parse a `Dict{String, T} where {T}` for the [`demo`](@ref) function.

## Input

A `dict::Dict{String, T} where {T}

## Returns

A tuple `(ct, cp, al, α, w, h, pfm, png, bp, bs, wt, ist, ise, spp)`
containing the following variables; the corresponding keys are also showed:

- `ct::String = dict["camera_type"]` : set the perspective projection view:
  - `ct=="per"` -> set [`PerspectiveCamera`](@ref)  (default value)
  - `ct=="ort"`  -> set [`OrthogonalCamera`](@ref)

- `cp::String = dict["camera_position"]` : "X,Y,Z" coordinates of the 
  choosen observation point of view 

- `al::String = dict["algorithm"]` : algorithm to be used in the rendered:
  - `al=="onoff"` -> [`OnOffRenderer`](@ref) algorithm 
  - `al=="flat"` -> [`FlatRenderer`](@ref) algorithm (default value)
  - `al=="pathtracing"` -> [`PathTracer`](@ref) algorithm 
  - `algorithm=="pointlight"` -> [`PointLightRenderer`](@ref) algorithm

- `α::String = dict["alpha"]` : choosen angle of rotation respect to vertical 
  (i.e. z) axis

- `w::Int64 = dict["width"]` : number of pixels on the horizontal axis to be rendered

- `h::Int64 = dict["height"]` : number of pixels on the vertical axis to be rendered 

- `pfm::String = dict["set_pfm_name"]` : output pfm filename

- `png::String` = dict["set_png_name"]` : output LDR filename

- `bp::Bool = dict["bool_print"]` : if `true`, WIP message of `demo` 
  function are printed (otherwise no)

- `bs::Bool = dict["bool_savepfm"]` : if `true`, `demo` function saves the 
  pfm file to disk

- `wt::String = dict["world_type"]` : type of the world to be rendered

- `ist::Int64 = dict["init_state"]` : initial state of the PCG generator

- `ise::Int64 = dict["init_seq"]` : initial sequence of the PCG generator

- `spp::Int64  = dict["samples_per_pixel"]` : number of ray to be 
  generated for each pixel

See also:  [`demo`](@ref), [`Point`](@ref), [`PCG`](@ref)
"""
function parse_demo_settings(dict::Dict{String, T}) where {T}

    keys = [
        "camera_type", "camera_position",
        "algorithm", "alpha", "width", "height",
        "set_pfm_name", "set_png_name", 
        "bool_print", "bool_savepfm",  "world_type",
        "init_state", "init_seq", "samples_per_pixel"
    ]

    for pair in dict
        if (pair[1] in keys) ==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for demo function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    camera_type::String = haskey(dict, "camera_type") ? dict["camera_type"] : "per"

    camera_position::Vec = haskey(dict, "camera_position") ?
        string2vector(dict["camera_position"]) : 
        Vec(-1.0 , 0. , 0.)

    algorithm::String = haskey(dict, "algorithm") ? dict["algorithm"] : "flat"

    α::Float64 = haskey(dict, "alpha") ? string2positive(dict["alpha"]) : 0.

    width::Int64 = haskey(dict, "width") ? string2evenint64(dict["width"]) : 640

    height::Int64 = haskey(dict, "height") ? string2evenint64(dict["height"]) : 480

    pfm::String = haskey(dict, "set_pfm_name") ? dict["set_pfm_name"] : "demo.pfm"

    png::String = haskey(dict, "set_png_name") ? dict["set_png_name"] : "demo.png"

    bool_print::Bool = haskey(dict, "bool_print") ?  dict["bool_print"] : true
    
    bool_savepfm::Bool = haskey(dict, "bool_savepfm") ? dict["bool_savepfm"] : true

    haskey(dict, "world_type") ? 
        world_type::String = dict["world_type"] : 
        world_type = "A"

    haskey(dict, "init_state") ? 
        init_state::Int64 = dict["init_state"] : 
        init_state = 54

    haskey(dict, "init_seq") ? 
        init_seq::Int64 = dict["init_seq"] : 
        init_seq = 45

    haskey(dict, "samples_per_pixel") ? 
        samples_per_pixel::Int64 = dict["samples_per_pixel"] : 
        samples_per_pixel = 0


    return (
            camera_type,
            camera_position, 
            algorithm, 
            α, 
            width, height, 
            pfm, png, 
            bool_print, bool_savepfm, 
            world_type,
            init_state, init_seq,
            samples_per_pixel
        )
end


"""
    parse_demoanimation_settings(dict::Dict{String, T}) where {T}
        :: (String, String, Int64, Int64, String, String, Int64)

Parse a `Dict{String, T} where {T}` for the [`demo_animation`](@ref) function.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(ct, al, w, h, wt, anim, spp)` containing the following
variables; the corresponding keys are also showed:

- `ct::String = dict["camera_type"]` : set the perspective projection view:
		- `ct=="per"` -> set [`PerspectiveCamera`](@ref)  (default value)
		- `ct=="ort"`  -> set [`OrthogonalCamera`](@ref)

- `al::String = dict["algorithm"]` : algorithm to be used in the rendered:
  - `al=="onoff"` -> [`OnOffRenderer`](@ref) algorithm 
  - `al=="flat"` -> [`FlatRenderer`](@ref) algorithm (default value)
  - `al=="pathtracing"` -> [`PathTracer`](@ref) algorithm 
  - `algorithm=="pointlight"` -> [`PointLightRenderer`](@ref) algorithm

- `w::Int64 = dict["width"]` : number of pixels on the horizontal axis to be rendered 

- `h::Int64 = dict["height"]` : width and height of the rendered image

- `wt::String = dict["world_type"]` : type of the world to be rendered

- `anim::String = dict["set_anim_name"]` : output animation name

- `spp::Int64  = dict["samples_per_pixel"]` : number of ray to be 
  generated for each pixel

See also:  [`demo_animation`](@ref), [`demo`](@ref)
"""
function parse_demoanimation_settings(dict::Dict{String, T}) where {T}

    keys = [
        "camera_type", "algorithm",
        "width", "height",  "world_type",
        "set_anim_name", "samples_per_pixel",
    ]

    for pair in dict
        if (pair[1] in keys) ==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for demo_animation function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    haskey(dict, "camera_type") ? 
        camera_type::String = dict["camera_type"] : 
        camera_type = "per"

    haskey(dict, "algorithm") ? 
        algorithm::String = dict["algorithm"] : 
        algorithm = "flat"

    haskey(dict, "width") ? 
        width::Int64 = dict["width"] : 
        width = 200

    haskey(dict, "height") ? 
        height::Int64 = dict["height"] : 
        height= 150

    haskey(dict, "world_type") ? 
        world_type::String = dict["world_type"] : 
        world_type = "A"

    haskey(dict, "set_anim_name") ? 
        anim::String = dict["set_anim_name"] : 
        anim = "demo_animation.mp4"

    haskey(dict, "samples_per_pixel") ? 
        samples_per_pixel::Int64 = dict["samples_per_pixel"] : 
        samples_per_pixel = 0

    return (camera_type, algorithm, 
            width, height, world_type, 
            anim, samples_per_pixel)
end


##########################################################################################92



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

    haskey(dict, "background_color") ? 
        background_color = string2color(dict["background_color"]) : 
        background_color = RGB{Float32}(0.0, 0.0, 0.0)

    haskey(dict, "color") ? 
        color = string2color(dict["color"]) : 
        color = RGB{Float32}(0.0, 0.0, 0.0)

  
    return (World(), background_color, color)
end

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

    haskey(dict, "background_color") ? 
        background_color = string2color(dict["background_color"]) : 
        background_color = RGB{Float32}(0.0, 0.0, 0.0)

  
    return (World(), background_color)
end

function parse_pathtracer_settings(dict::Dict{String, T}) where {T}

    keys = [
        "init_state", "init_seq", 
        "background_color", "num_of_rays", "max_depth",
        "russian_roulette_limit"
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

    init_state = UInt64(haskey(dict, "init_state") ? dict["init_state"] : 45)

    init_seq = UInt64(haskey(dict, "init_seq") ? dict["init_seq"] : 54)

    haskey(dict, "background_color") ?
        background_color = string2color(dict["background_color"]) : 
        background_color = RGB{Float32}(0.0, 0.0, 0.0)

    haskey(dict, "num_of_rays") ? 
        num_of_rays::Int64 = dict["num_of_rays"] : 
        num_of_rays= 10

    haskey(dict, "max_depth") ? 
        max_depth::Int64 = dict["max_depth"] : 
        max_depth = 2

     haskey(dict, "russian_roulette_limit") ? 
        russian_roulette_limit::Int64 = dict["russian_roulette_limit"] : 
        russian_roulette_limit = 3

    return (World(),
            background_color,
            PCG(init_state, init_seq), 
            num_of_rays, max_depth, 
            russian_roulette_limit
            )
end

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

    haskey(dict, "background_color") ? 
        background_color = string2color(dict["background_color"]) : 
        background_color = RGB{Float32}(0.0, 0.0, 0.0)

    haskey(dict, "ambient_color") ? 
        ambient_color = string2color(dict["ambient_color"]) : 
        ambient_color = RGB{Float32}(0.0, 0.0, 0.0)

  
    return (World(), background_color, ambient_color)
end


"""
    parse_render_settings(dict::Dict{String, Any}) 
        :: (
            String, Union{String, Nothing}, Union{Point, Nothing}, String,
            Float64, Int64, Int64, String, String, Bool, Bool, Int64, 
            Int64, Int64
            )

Parse a `Dict{String, T} where {T}` for the [`render`](@ref) function.

## Input

A `dict::Dict{String, T} where {T}

## Returns

A tuple `(sf, ct, cp, al, α, w, h, pfm, png, bp, bs,  ist, ise, spp)`
containing the following variables; the corresponding keys are also showed:

- `sf::String = dict["scenefile"]` : input scene file name (required)

- `ct::Union{String, Nothing} = dict["camera_type"]` : set the perspective projection view:
  - `ct=="per"` -> set [`PerspectiveCamera`](@ref) 
  - `ct=="ort"`  -> set [`OrthogonalCamera`](@ref)
  - `nothing` : default return value if not specified

- `cp::Union{String, Nothing} = dict["camera_position"]` : "X,Y,Z" coordinates of the 
  choosen observation point of view (`nothing` default return value, else `Point(X,Y,Z)`)

- `al::String = dict["algorithm"]` : algorithm to be used in the rendered:
  - `al=="onoff"` -> [`OnOffRenderer`](@ref) algorithm 
  - `al=="flat"` -> [`FlatRenderer`](@ref) algorithm (default value)
  - `al=="pathtracing"` -> [`PathTracer`](@ref) algorithm 
  - `algorithm=="pointlight"` -> [`PointLightRenderer`](@ref) algorithm

- `α::String = dict["alpha"]` : choosen angle of rotation respect to vertical 
  (i.e. z) axis

- `w::Int64 = dict["width"]` : number of pixels on the horizontal axis to be rendered

- `h::Int64 = dict["height"]` : number of pixels on the vertical axis to be rendered 

- `pfm::String = dict["set_pfm_name"]` : output pfm filename

- `png::String` = dict["set_png_name"]` : output LDR filename

- `bp::Bool = dict["bool_print"]` : if `true`, WIP message of `render` 
  function are printed (otherwise no)

- `bs::Bool = dict["bool_savepfm"]` : if `true`, `render` function saves the 
  pfm file to disk

- `ist::Int64 = dict["init_state"]` : initial state of the PCG generator

- `ise::Int64 = dict["init_seq"]` : initial sequence of the PCG generator

- `spp::Int64  = dict["samples_per_pixel"]` : number of ray to be 
  generated for each pixel

See also:  [`render`](@ref), [`Point`](@ref), [`PCG`](@ref)
"""
function parse_render_settings(dict::Dict{String, T}) where {T}

    keys = [
        "scenefile", 
        "camera_type", "camera_position", 
        "alpha", "width", "height",
        "set_pfm_name", "set_png_name", 
        "bool_print", "bool_savepfm", 
        "init_state", "init_seq", "samples_per_pixel",
        "declare_float",
        "%COMMAND%",
        "onoff", "flat", "pathtracer", "pointlight",
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

    haskey(dict, "camera_type") ? 
        camera_type::String = dict["camera_type"] : 
        camera_type = nothing

    haskey(dict, "camera_position") ?
        begin
            obs::String = dict["camera_position"]
            (x,y,z) = Tuple(parse.(Float64, split(obs, ","))) 
            camera_position = Point(x,y,z)
        end : 
        camera_position = nothing

    haskey(dict, "alpha") ? 
        α::Float64 = dict["alpha"] : 
        α = 0.

    haskey(dict, "width") ? 
        width::Int64 = dict["width"] : 
        width = 640

    haskey(dict, "height") ? 
        height::Int64 = dict["height"] : 
        height= 480

    haskey(dict, "set_pfm_name") ? 
        pfm::String = dict["set_pfm_name"] : 
        pfm = "scene.pfm"

    haskey(dict, "set_png_name") ? 
        png::String = dict["set_png_name"] : 
        png = "scene.png"

    haskey(dict, "bool_print") ? 
        bool_print::Bool = dict["bool_print"] : 
        bool_print = true
    
    haskey(dict, "bool_savepfm") ? 
        bool_savepfm::Bool = dict["bool_savepfm"] : 
        bool_savepfm = true

    haskey(dict, "samples_per_pixel") ? 
        samples_per_pixel::Int64 = dict["samples_per_pixel"] : 
        samples_per_pixel = 0

    haskey(dict, "declare_float") ?
        declare_float = declare_float2dict(dict["declare_float"]) : 
        declare_float = nothing

    if haskey(dict, "%COMMAND%")
        if dict["%COMMAND%"] == "onoff"
            renderer = OnOffRenderer(parse_onoff_settings(dict["onoff"])...)
        elseif dict["%COMMAND%"] == "flat"
            renderer = FlatRenderer(parse_flat_settings(dict["flat"])...)
        elseif dict["%COMMAND%"] == "pathtracer"
            renderer = PathTracer(parse_pathtracer_settings(dict["pathtracer"])...)
        elseif dict["%COMMAND%"] == "pointlight"
            renderer = PointLightRenderer(parse_pointlight_settings(dict["pointlight"])...)
        end
	else
		renderer = FlatRenderer()
	end

    return (
            scenefile,
            renderer,
            camera_type,
            camera_position,
            α, 
            width, height, 
            pfm, png, 
            bool_print, bool_savepfm, 
            samples_per_pixel, 
            declare_float,
        )
end
