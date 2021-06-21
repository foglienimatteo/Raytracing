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

    background_color::RGB{Float32} = haskey(dict, "background_color") ? 
        string2color(dict["background_color"]) : 
        RGB{Float32}(0.0, 0.0, 0.0)

    color::RGB{Float32} = haskey(dict, "color") ? 
        string2color(dict["color"]) : 
        RGB{Float32}(0.0, 0.0, 0.0)

  
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

    background_color::RGB{Float32} =haskey(dict, "background_color") ? 
        string2color(dict["background_color"]) : 
        RGB{Float32}(0.0, 0.0, 0.0)

  
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

    keys = union([
        "%COMMAND%", "renderer",
        "camera_type", "camera_position",
        "alpha", "width", "height",
        "set_pfm_name", "set_png_name", 
        "samples_per_pixel", "world_type",
        "bool_print", "bool_savepfm",  
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
            OnOffRenderer(parse_onoff_settings(dict["onoff"])...)
        elseif dict["%COMMAND%"] == "flat"
            FlatRenderer(parse_flat_settings(dict["flat"])...)
        elseif dict["%COMMAND%"] == "pathtracer"
            PathTracer(parse_pathtracer_settings(dict["pathtracer"])...)
        elseif dict["%COMMAND%"] == "pointlight"
            PointLightRenderer(parse_pointlight_settings(dict["pointlight"])...)
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

    α::Float64 = haskey(dict, "alpha") ? begin 
        typeof(dict["alpha"]) <: Number ?
            dict["alpha"] : 
            parse(Float64, dict["alpha"])
        end : 0.

    width::Int64 = haskey(dict, "width") ? string2evenint64(dict["width"]) : 640

    height::Int64 = haskey(dict, "height") ? string2evenint64(dict["height"]) : 480

    pfm::String = haskey(dict, "set_pfm_name") ? dict["set_pfm_name"] : "demo.pfm"

    png::String = haskey(dict, "set_png_name") ? dict["set_png_name"] : "demo.png"

    world_type::String = haskey(dict, "world_type") ? 
        string2stringoneof(dict["world_type"], DEMO_WORLD_TYPES) : "A"

    samples_per_pixel::Int64 = haskey(dict, "samples_per_pixel") ? string2evenint64(dict["samples_per_pixel"]) : 0

    bool_print::Bool = haskey(dict, "bool_print") ?  dict["bool_print"] : true
    
    bool_savepfm::Bool = haskey(dict, "bool_savepfm") ? dict["bool_savepfm"] : true

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

    keys = union([
        "%COMMAND%", "renderer",
        "camera_type", "camera_position",
        "width", "height",  "world_type",
        "set_anim_name", "samples_per_pixel",
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
            OnOffRenderer(parse_onoff_settings(dict["onoff"])...)
        elseif dict["%COMMAND%"] == "flat"
            FlatRenderer(parse_flat_settings(dict["flat"])...)
        elseif dict["%COMMAND%"] == "pathtracer"
            PathTracer(parse_pathtracer_settings(dict["pathtracer"])...)
        elseif dict["%COMMAND%"] == "pointlight"
            PointLightRenderer(parse_pointlight_settings(dict["pointlight"])...)
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

    samples_per_pixel::Int64 = haskey(dict, "samples_per_pixel") ? string2evenint64(dict["samples_per_pixel"]) : 0

    world_type::String = haskey(dict, "world_type") ? 
        string2stringoneof(dict["world_type"], DEMO_WORLD_TYPES) : "A"


    return (renderer, 
            camera_type, camera_position,
            width, height, anim, 
            samples_per_pixel, world_type)
end


##########################################################################################92


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
        "%COMMAND%",
        "onoff", "flat", "pathtracer", "pointlight",
        "camera_type", "camera_position", 
        "alpha", "width", "height",
        "set_pfm_name", "set_png_name", 
        "bool_print", "bool_savepfm", 
        "init_state", "init_seq", "samples_per_pixel",
        "declare_float",
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

    camera_type::Union{String, Nothing} = haskey(dict, "camera_type") ? 
        string2stringoneof(dict["camera_type"], CAMERAS) : 
        nothing

    camera_position::Vec = haskey(dict, "camera_position") ? begin
            typeof(dict["camera_position"]) ∈ [Vec, Point] ?
            dict["camera_position"] :
            string2vector(dict["camera_position"]) 
        end : Vec(-1.0 , 0. , 0.)

    α::Float64 = haskey(dict, "alpha") ? begin 
        typeof(dict["alpha"]) <: Number ?
            dict["alpha"] : 
            parse(Float64, dict["alpha"])
        end : 0.

    width::Int64 = haskey(dict, "width") ? string2evenint64(dict["width"]) : 640

    height::Int64 = haskey(dict, "height") ? string2evenint64(dict["height"]) : 480

    pfm::String = haskey(dict, "set_pfm_name") ? dict["set_pfm_name"] : "scene.pfm"

    png::String = haskey(dict, "set_png_name") ? dict["set_png_name"] : "scene.png"

    bool_print::Bool = haskey(dict, "bool_print") ?  dict["bool_print"] : true
    
    bool_savepfm::Bool = haskey(dict, "bool_savepfm") ? dict["bool_savepfm"] : true

    samples_per_pixel::Int64 = haskey(dict, "samples_per_pixel") ? string2evenint64(dict["samples_per_pixel"]) : 0

    declare_float::Union{Dict{String, Float64}, Nothing} = haskey(dict, "declare_float") ?
        declare_float2dict(dict["declare_float"]) : 
        nothing

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
