# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


##########################################################################################92

"""
    valid_coordinates(hdr::HDRimage, x::Int, y::Int) :: Bool

Return `true` if (`x`, `y`) are valid coordinates for the 
2D matrix of the `HDRimage`, else return `false`.

See also: [`HDRimage`](@ref)
"""
function valid_coordinates(hdr::HDRimage, x::Int, y::Int)
    x>=0 && y>=0 && x<hdr.width && y<hdr.height
end

"""
    pixel_offset(hdr::HDRimage, x::Int, y::Int) :: Int64

Return the index in the 1D array of the specified pixel (`x`, `y`) 
for the given `HDRimage`.

See also: [`valid_coordinates`](@ref), [`HDRimage`](@ref)
"""
function pixel_offset(hdr::HDRimage, x::Int, y::Int)
    @assert valid_coordinates(hdr, x, y)
    y*hdr.width + (x+1)
end

"""
    get_pixel(hdr::HDRimage, x::Int, y::Int) :: RBG{Float32}

Return the `RBG{Float32}` color for the (`x`, `y`) pixel in the 
given [`HDRimage`](@ref). The indexes for a `HDRimage` pixel matrix 
with `w` width and `h` height follow this sketch:
```ditaa
|  (0,0)    (0,1)    (0,2)   ...   (0,w-1)  |
|  (1,0)    (1,1)    (1,2)   ...   (1,w-1)  |
|   ...      ...      ...    ...     ...    |
| (h-1,0)  (h-1,1)  (h-1,2)  ...  (h-1,w-1) |
```

See also: [`pixel_offset`](@ref), [`valid_coordinates`](@ref), 
[`HDRimage`](@ref)
"""
function get_pixel(hdr::HDRimage, x::Int, y::Int)
    return hdr.rgb_m[pixel_offset(hdr, x, y)]
end

function set_pixel(hdr::HDRimage, x::Int, y::Int, c::RGB{Float32}) 
    hdr.rgb_m[pixel_offset(hdr, x,y)] = c
    return nothing
end

function set_pixel(hdr::HDRimage, x::Int, y::Int, c::RGB{T}) where {T}
    hdr.rgb_m[pixel_offset(hdr,x,y)] = convert(RGB{Float32}, c)
    return nothing
end

"""
    set_pixel(hdr::HDRimage, x::Int, y::Int, c::RGB{Float32})
    set_pixel(hdr::HDRimage, x::Int, y::Int, c::RGB{T}) where {T}

Set the new RGB color `c` for the (`x`, `y`) pixel in 
the given [`HDRimage`](@ref). The indexes for a `HDRimage` pixel 
matrix with `w` width and `h` height follow this sketch:
```ditaa
|  (0,0)    (0,1)    (0,2)   ...   (0,w-1)  |
|  (1,0)    (1,1)    (1,2)   ...   (1,w-1)  |
|   ...      ...      ...    ...     ...    |
| (h-1,0)  (h-1,1)  (h-1,2)  ...  (h-1,w-1) |
```

See also: [`pixel_offset`](@ref), [`valid_coordinates`](@ref), 
[`HDRimage`](@ref)
"""
set_pixel

##########################################################################################92

"""
    write(io::IO, img::HDRimage)

Write the given [`HDRimage`](@ref) image using the given `IO` stream.
The `endianness` used for writing the file is Little Endian (`-1.0`).

See also: [`get_pixel`](@ref), [`HDRimage`](@ref)
"""
function write(io::IO, img::HDRimage)
    endianness=-1.0
    w = img.width
    h = img.height

    # The PFM header, as a Julia string (UTF-8)
    header = "PF\n$w $h\n$endianness\n"

    # Convert the header into a sequence of bytes
    # PS: transcode writes a "raw" sequence of bytes (8bit)
    bytebuf = transcode(UInt8, header) 

    # Write on io the header in binary code
    # PS: reinterpret  writes a "raw" sequence of bytes (8bit)
    write(io, reinterpret(UInt8, bytebuf))  

    # Write the image (bottom-to-up, left-to-right)
    for y in h-1:-1:0, x in 0:w-1         
        color = get_pixel(img, x, y)
        write(io, reinterpret(UInt8,  [color.r]))  
        write(io, reinterpret(UInt8,  [color.g]))   
        write(io, reinterpret(UInt8,  [color.b]))
    end

end

##########################################################################################92

struct InvalidPfmFileFormat <: Exception
    var::String
end

"""
    parse_img_size(line::String) :: (Int64, Int64)

Return the size (width and height) parsed from a given `String`, throwing 
`InvalidPfmFileFormat` exception if encounters invalid values.
It works inside the [`read_line`](@ref)(::IO) function.
"""
function parse_img_size(line::String)
    elements = split(line, " ")
    length(elements) == 2 || throw(InvalidPfmFileFormat(
                                "invalid image size specification: "*
                                "$(length(elements)) instead of 2"))

    try
        width, height = convert.(Int, parse.(Float64, elements))
        (width > 0 && height > 0) || throw(ErrorException)
        return width, height
    catch e
        isa(e, InexactError) || throw(InvalidPfmFileFormat(
                                    "cannot convert width/height "*
                                    "$(elements) to Tuple{Int, Int}")
        )
        isa(e, ErrorException) || throw(InvalidPfmFileFormat(
                                    "width/height cannot be negative,"*
                                    "but in $(elements) at least one of them is <0.")
        )
    end

end

"""
    parse_endianness(ess::String) :: Float64

Return the endianness  parsed from a given `String`, throwing 
`InvalidPfmFileFormat` exception if encounters an invalid value.
It works inside the [`read_line`](@ref)(::IO) function.
"""
function parse_endianness(ess::String)
    try
        val = parse(Float64, ess)
        val in [1.0, -1.0] || throw(InvalidPfmFileFormat(
                                "invalid endianness in PFM file:"*
                                " $(val) instead of +1.0 or -1.0.\n")
        )
        return val
    catch e
        throw(InvalidPfmFileFormat(
            "missing endianness in PFM file: $ess instead of ±1.0"))
    end
end

"""
    read_float(io::IO, ess::Float64) :: Float32
    
Return a `Float32`, readed from the given IO stream `io` with the 
(required) endianness `ess`; `ess` must be `+1.0` (Big Endian) or 
`-1.0` (Little Endian).

Controls also if there are enough bits in order to form a `Float32`, 
otherwise throw `InvalidPfmFileFormat`.
"""
function read_float(io::IO, ess::Float64)
    # controllo che in ingresso abbia una stringa che sia cnovertibile in Float32
    ess == 1.0 || ess == -1.0 || throw(InvalidPfmFileFormat(
                                    "endianness $ess not acceptable."))
    try
        value = read(io, Float32) 
        ess == 1.0 ? value=ntoh(value) : value=ltoh(value) # convert machine's endianness
        return value
    catch e
        throw(InvalidPfmFileFormat("color is not Float32, it's a $(typeof(io))"))
    end
end 

"""
    read_line(io::IO) :: String

Reads a line from the file whose the given IO object `io` refers to. 
Do understand when the file is ended and when a new line begins.
Return the readed line as a `String`.
"""
function read_line(io::IO)
    result = b""
    while eof(io) == false
        cur_byte = read(io, UInt8)
        if [cur_byte] in [b"", b"\n"]
            return String(result)
        end
        result = vcat(result, cur_byte)  
    end
    return String(result)
end

"""
    read(io::IO, ::Type{HDRimage}) :: HDRimage

Read a PFM image from a stream object `io`, and return a `HDRimage` 
object containing the image. If an error occurs, raise a
`InvalidPfmFileFormat` exception.

See also: [`read_line`](@ref)(`::IO`), [`parse_image_size`](@ref)(`::String`),
[`parse_endianness`](@ref)(`::String`), [`read_float`](@ref)(`::IO, `::Float64`),
[`HDRimage`](@ref)
"""
function read(io::IO, ::Type{HDRimage})
    # magic number
    magic = read_line(io)
    magic == "PF" || throw(InvalidPfmFileFormat("invalid magic number in PFM file:"* 
                                                 "$(magic) instead of 'PF'.\n"))
    
    # image dimension
    img_size = read_line(io)
    typeof(parse_img_size(img_size)) == Tuple{Int,Int} || 
        throw(InvalidPfmFileFormat(
            "invalid img size in PFM file: $(parse_img_size(img_size)) is "* 
            "$( typeof(parse_img_size(img_size)) ) instead of 'Tuple{UInt,UInt}'.\n"))
    (width, height) = parse_img_size(img_size)
    
    # endianness
    endianness = parse_endianness(read_line(io))
    endianness in [1.0, -1.0] || throw(InvalidPfmFileFormat(
                                "invalid endianness in PFM file: "*
                                "$(endianness) instead of +1.0 or -1.0.\n"))

    # color matrix
    result = HDRimage(width, height)
    for y in height-1:-1:0, x in 0:width-1

        (r,g,b) = [read_float(io, endianness) for i in 0:2]
        set_pixel(result, x, y, RGB(r,g,b) )
    end

    return result
end 

##########################################################################################92

"""
    parse_command_line((args::Vector{String}) :: (String, String, Float64, Float64)

Interpret the command line when the main is executed, 
and manage eventual argument errors.

# Arguments
An array of strings, with length 2, 3 or 4, cointaining:
- first string (required): input file name, must be a PFM format
- second string (required): output filename, its format can be PNG or TIFF
- [`a`] : scale  factor for luminosity correction (default 0.18, 
used in [`normalize_image!`](@ref))
- [`γ`] : gamma factor for screen correction (default 1.0, used in 
  [`γ_correction!`](@ref))

# Returns
A tuple `(infile, outfile, a, γ)`, with `a` and `γ` with type `Float64`

See also : [`normalize_image!`](@ref), [`γ_correction!`](@ref)
"""
function parse_command_line(args::Vector{String})
    (isempty(args) || length(args)==1 || length(args)>4) && throw(Exception)	  
    infile = nothing; outfile = nothing; a=0.18; γ=1.0
    try
        infile = args[1]
        outfile = args[2]
        open(infile, "r") do io
            read(io, UInt8)
        end
    catch e
        throw(RuntimeError("invalid input file: $(args[1]) does not exist"))
    end

    if length(args)>2
        try
            a = parse(Float64, args[3])
            a > 0. || throw(Exception)
        catch e
            throw(InvalidArgumentError(
                "invalid value for a: $(args[3])  must be a positive number"))
        end

        if length(args) == 4
            try
                γ = parse(Float64, args[4])
                γ > 0. || throw(Exception)
            catch e
                throw(InvalidArgumentError(
                    "invalid value for γ: $(args[4])  must be a positive number"))
            end
        end
    end

    return infile, outfile, a, γ
end


##########################################################################################92

"""
    parse_tonemapping_settings(dict::Dict{String, Any}) 
        :: (String, String, Float64, Float64)

Parse a `Dict{String, T} where {T}` for the [`tone_mapping`](@ref) function.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(pfm, png, a, γ)` containing:

- `pfm::String = dict["pfm_infile"]` : input pfm filename (required)

- `png::String = dict["outfile"]` : output LDR filename (required)

- `a::Float64 = dict["alpha"]` : scale factor (default = 0.18)

- `γ::Float64 = dict["gamma"]` : gamma factor (default = 1.0)

See also:  [`tone_mapping`](@ref)
"""
function parse_tonemapping_settings(dict::Dict{String, T}) where {T}

    keys = ["pfm_infile", "outfile", "alpha", "gamma"]

    for pair in dict
        if (pair[1] in keys) ==false
            throw(ArgumentError(
                "invalid key : $(pair[1])\n"*
                "valid keys for tonemapping function are:\n "*
                "$(["$(key)" for key in keys])"
            ))
        end
    end

    haskey(dict, "pfm_infile") ? 
        pfm::String = dict["pfm_infile"] : 
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
    parse_demo_settings(dict::Dict{String, T}) where {T}
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

    haskey(dict, "camera_type") ? 
        camera_type::String = dict["camera_type"] : 
        camera_type = "per"

    haskey(dict, "camera_position") ?
        begin
            obs::String = dict["camera_position"]
            (x,y,z) = Tuple(parse.(Float64, split(obs, ","))) 
            camera_position = Point(x,y,z)
        end : 
        camera_position =  Point(-1.0 , 0. , 0.)

    haskey(dict, "algorithm") ? 
        algorithm::String = dict["algorithm"] : 
        algorithm = "flat"

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
        pfm = "demo.pfm"

    haskey(dict, "set_png_name") ? 
        png::String = dict["set_png_name"] : 
        png = "demo.png"

    haskey(dict, "bool_print") ? 
        bool_print::Bool = dict["bool_print"] : 
        bool_print = true
    
    haskey(dict, "bool_savepfm") ? 
        bool_savepfm::Bool = dict["bool_savepfm"] : 
        bool_savepfm = true

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
        :: (String, String, Int64, Int64, String)

Parse a `Dict{String, T} where {T}` for the [`demo_animation`](@ref) function.

## Input

A `dict::Dict{String, T} where {T}`

## Returns

A tuple `(ct, al, w, h, anim)` containing the following
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

- `anim::String = dict["set_anim_name"]` : output animation name

See also:  [`demo_animation`](@ref), [`demo`](@ref)
"""
function parse_demoanimation_settings(dict::Dict{String, T}) where {T}

    keys = [
        "camera_type", "algorithm",
        "width", "height", "set_anim_name", 
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

    haskey(dict, "set_anim_name") ? 
        anim::String = dict["set_anim_name"] : 
        anim = "demo_animation.mp4"

    return (camera_type, algorithm, width, height, anim)
end
