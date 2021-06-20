# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


##########################################################################################92

"""
    valid_coordinates(img::HDRimage, x::Int, y::Int) :: Bool

Return `true` if (`x`, `y`) are valid coordinates for the 
2D matrix of the `HDRimage`, else return `false`.

See also: [`HDRimage`](@ref)
"""
function valid_coordinates(img::HDRimage, x::Int, y::Int)
    x>=0 && y>=0 && x<img.width && y<img.height
end

"""
    pixel_offset(img::HDRimage, x::Int, y::Int) :: Int64

Return the index in the 1D array of the specified pixel (`x`, `y`) 
for the given `HDRimage`.
Internally checks also if  (`x`, `y`)  are valid coordinates for `img` through
the `valid_coordinates` function.

See also: [`valid_coordinates`](@ref), [`HDRimage`](@ref)
"""
function pixel_offset(img::HDRimage, x::Int, y::Int)
    @assert valid_coordinates(img, x, y)
    return y*img.width + (x+1)
end

"""
    get_pixel(img::HDRimage, x::Int, y::Int) :: RBG{Float32}

Return the `RBG{Float32}` color for the (`x`, `y`) pixel in the 
given `HDRimage`, obtained through the `pixel_offset` function.
The indexes for a `HDRimage` pixel matrix 
with `w` width and `h` height follow this sketch:
```ditaa
|  (0,0)    (0,1)    (0,2)   ...   (0,w-1)  |
|  (1,0)    (1,1)    (1,2)   ...   (1,w-1)  |
|   ...      ...      ...    ...     ...    |
| (h-1,0)  (h-1,1)  (h-1,2)  ...  (h-1,w-1) |
```

See also: [`pixel_offset`](@ref), [`HDRimage`](@ref)
"""
function get_pixel(img::HDRimage, x::Int, y::Int)
    return img.rgb_m[pixel_offset(img, x, y)]
end

function set_pixel(img::HDRimage, x::Int, y::Int, c::RGB{Float32}) 
    img.rgb_m[pixel_offset(img, x,y)] = c
    return nothing
end

function set_pixel(img::HDRimage, x::Int, y::Int, c::RGB{T}) where {T}
    img.rgb_m[pixel_offset(img,x,y)] = convert(RGB{Float32}, c)
    return nothing
end

"""
    set_pixel(img::HDRimage, x::Int, y::Int, c::RGB{Float32})
    set_pixel(img::HDRimage, x::Int, y::Int, c::RGB{T}) where {T}

Set the new RGB color `c` for the (`x`, `y`) pixel in 
the given `HDRimage`, acceded through the `pixel_offset` function.
The indexes for a `HDRimage` pixel 
matrix with `w` width and `h` height follow this sketch:
```ditaa
|  (0,0)    (0,1)    (0,2)   ...   (0,w-1)  |
|  (1,0)    (1,1)    (1,2)   ...   (1,w-1)  |
|   ...      ...      ...    ...     ...    |
| (h-1,0)  (h-1,1)  (h-1,2)  ...  (h-1,w-1) |
```

If `c` is of a type `RGB{T}` where `T ≠ Float32`, it's called the
`convert(RGB{Float32}, c)` function, which raises an exception if the
conversion is not possible.

See also: [`pixel_offset`](@ref), [`HDRimage`](@ref)
"""
set_pixel

##########################################################################################92

"""
    write(io::IO, img::HDRimage)

Write the given `HDRimage` image using the given `IO` stream as a PFM file.
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

"""
    InvalidPfmFileFormat <: Exception (var::String)

Self-made exception raised by thne following function
in case a reading operation of a PFM file fails:

- [`parse_img_size`](@ref)

- [`parse_endianness`](@ref)

- [`read_line`](@ref)

- [`read_float`](@ref)

- [`read(::IO, ::Type{HDRimage})`](@ref)

"""
struct InvalidPfmFileFormat <: Exception
    var::String
end

"""
    parse_img_size(line::String) :: (Int64, Int64)

Return the size `(width, height)` parsed from a given `String`, throwing 
`InvalidPfmFileFormat` exception if encounters invalid values.
It works inside the `read(::IO, ::Type{HDRimage})` function.

See also: [`read(::IO, ::Type{HDRimage})`](@ref), 
[`InvalidPfmFileFormat`](@ref)
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

Return the endianness parsed from a given `String`, throwing 
`InvalidPfmFileFormat` exception if encounters an invalid value.
It works inside the `read(::IO, ::Type{HDRimage})` function.

See also: [`read(::IO, ::Type{HDRimage})`](@ref), 
[`InvalidPfmFileFormat`](@ref)
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
It works inside the `read(::IO, ::Type{HDRimage})` function.

See also: [`read(::IO, ::Type{HDRimage})`](@ref), 
[`InvalidPfmFileFormat`](@ref)
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
It works inside the `read(::IO, ::Type{HDRimage})` function.

See also: [`read(::IO, ::Type{HDRimage})`](@ref), 
[`InvalidPfmFileFormat`](@ref)
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
Calls internally the following functions:

- [`parse_img_size`](@ref)

- [`parse_endianness`](@ref)

- [`read_line`](@ref)

- [`read_float`](@ref)

See also:  [`parse_img_size`](@ref), [`parse_endianness`](@ref), 
[`read_line`](@ref), [`read_float`](@ref), [`InvalidPfmFileFormat`](@ref),
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
    parse_command_line(args::Vector{String}) :: 
        (String, String, Float64, Float64)

Interpret the command line when the main is executed, 
and manage eventual argument errors.

## Input

A `args::Vector{String})` with length 2, 3 or 4.

## Returns

A tuple `(infile, outfile, a, γ)` containing:

- `infile::String` : first string (required), is the input file 
  name, which must be a PFM format.

- `outfile::String` : second string (required), is the output filename; 
  its format can be PNG or TIFF.

- `a::Float64` : third argument (optional), is the scale factor for 
  luminosity correction (default 0.18), passed to `normalize_image!`

- `γ::Float64` : fourth argument (optional), is the gamma factor for 
  screen correction (default 1.0), passed to `γ_correction!`

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


"""
    load_image(path::Union{String, IO}) :: HDRimage

Load an image from the specified `path` in an HDR image format.

See also: [`HDRimage`](@ref)
"""
function load_image(path::Union{String, IO})
    img = load(path)
    img_float32 = float32.(img)
    width, height = size(img_float32)
    vec = reshape(permutedims(img_float32), (width*height,))
    #vec = reshape(reverse(permutedims(img_float32), dims=1), (width*height,))

    return HDRimage(height, width, vec)
end

"""
    ldr2pfm(path::String, outfile::String)

Load an image from the specified `path`, convert it in a pfm file format
and save it as `outfile`.
It works through the `load_image` and the  `write(::IO, ::HDRimage)` function.

See also: [`HDRimage`](@ref), [`load_image`](@ref),  
[`write(::IO, ::HDRimage)`](@ref)
"""
function ldr2pfm(path::String, outfile::String)
    img = load_image(path)
    open(outfile, "w") do outf; 
        write(outf, img)
    end
    nothing
end


##########################################################################################92


"""
    check_is_color(string::String="") :: Bool

Checks if the input `string` is a color written in RGB components
as "<R, G, B>".
"""
function check_is_color(string::String="")
    println(string)
	(string == "") && (return true)
	color = filter(x -> !isspace(x) && x≠"\"", string)

	(color[begin] == '<' && color[end] == '>') || (return false)

	color = color[begin+1:end-1]
	color = split(color, ",")
	(length(color)==3) || (return false)

	for c in color
		!isnothing(tryparse(Float64, c)) || (return false)
	end

	return true
end

"""
    string2color(string::String="") :: RGB{Float32}

Checks if the input `string` is a color written in RGB components
as "<R, G, B>" with [`check_is_color`](@ref), and return it.
"""
function string2color(string::String)
    if check_is_color(string)==false
        throw(ArgumentError(
            "invalid color sintax; must be: <R, G, B>\n"*
            "Example: --background_color=<1,2,3>"
        ))
    end

    if string==""
        return RGB{Float32}(0,0,0)
    end

	color = filter(x -> !isspace(x)&& x≠"\"", string)[begin+1:end-1]
	rgb = Vector{String}(split(color, ","))
    R, G, B = tuple(parse.(Float64, rgb)...)

    println(R,G,B)
	return RGB{Float32}(R,G,B)
end


"""
    check_is_vector(string::String="") :: Bool

Checks if the input `string` is a vector written in X,Y,Z components
as "[X, Y, Z]".
"""
function check_is_vector(string::String="")
	(string == "") && (return true)
	color = filter(x -> !isspace(x), string)

	(color[begin] == '[' && color[end] == ']') || (return false)

	color = color[begin+1:end-1]
	color = split(color, ",")
	(length(color)==3) || (return false)

	for c in color
		!isnothing(tryparse(Float64, c)) || (return false)
	end

	return true
end

"""
    string2vector(string::String="") :: Union{Vec, Nothing}

Checks if the input `string` is  a vector written in X,Y,Z components
as "[X, Y, Z]" with [`check_is_vector`](@ref), and return `Vec(X,Y,Z)`.

See also: [`Vec`](@ref)
"""
function string2vector(string::String)
    if check_is_vector(string)==false
        throw(ArgumentError(
            "invalid vector sintax; must be: [1,2,3]\n"*
            "Example: --camera_position=[1,2,3]"
        ))
    end

    if string==""
        return Vec(0,0,0)
    end

	color = filter(x -> !isspace(x) && x≠"\"", string)[begin+1:end-1]
	Vec = split(color, ",")
    x, y, z = parse.(Float64, RGB)

	return Vec(x, y, z)
end

"""
    check_is_declare_float(string::String="") 

Checks if the input `string` is a declaration of one (or more) floats
in the form "NAME:VALUE" with [`check_is_declare_float`](@ref).
Examples:
```bash
    --declare_float=name:1.0
    --declare_float=name1:1.0,name2:2.0
    --declare_float=" name1 : 1.0 , name2: 2.0"
```
"""
function check_is_declare_float(string::String="")
	(string == "") && (return true)
	string_without_spaces = filter(x -> !isspace(x), string)

	vec_nameval = split.(split(string_without_spaces, ","), ":" )
	for declare_float ∈ vec_nameval
		if !(length(declare_float)==2 && !isnothing(tryparse(Float64, declare_float[2])))
			return false
		end
	end

	return true
end

"""
    declare_float2dict(string::String) :: Union{Dict{String, Float64}, Nothing}

Checks if the input `string` is a declaration of one (or more) floats
in the form "NAME:VALUE" with [`check_is_declare_float`](@ref).
Return a `Dict{String, Float64}` that associates each NAME (as keys) with
its `Float64` value, or nothing if `string==""`.
"""
function declare_float2dict(string::String)
    if check_is_declare_float(string)==false
        throw(ArgumentError(
            "invalid declare_float usage. Correct usage: \n"*
            "\t--declare_float=name:1.0\n"*
            "\t--declare_float=name1:1.0,name2:2.0\n"*
            """\t--declare_float=" name1 : 1.0 , name2: 2.0\n"""
        ))
    end

    if string==""
        return nothing
    end

	string_without_spaces = filter(x -> !isspace(x), string)
    vec_nameval = split.(split(string_without_spaces, ","), ":" )
    declare_float = Dict{String, Float64}([v[1]=>parse(Float64, v[2]) for v in vec_nameval]...)
    return declare_float
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
