# -*- encoding: utf-8 -*-
#
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

##########################################################################################92

"""
    valid_coordinates(hdr::HDRimage, x::Int, y::Int) -> Bool

Return `True` if `(x, y)` are valid coordinates for the 
2D matrix of the [`HDRimage`](@ref)
"""
valid_coordinates(hdr::HDRimage, x::Int, y::Int) = 
    x>=0 && y>=0 && x<hdr.width && y<hdr.height

##########################################################################################92

"""
    pixel_offset(hdr::HDRimage, x::Int, y::Int) -> Int64

Return the index in the 1D array of the specified pixel `(x, y)` for the 
given [`HDRimage`](@ref)
"""
pixel_offset(hdr::HDRimage, x::Int, y::Int) = 
    (@assert valid_coordinates(hdr, x, y); y*hdr.width + (x+1) )

##########################################################################################92

"""
    get_pixel(hdr::HDRimage, x::Int, y::Int) -> RBG{Float32}

Return the `RBG{Float32}` color for the `(x, y)` pixel in the given [`HDRimage`](@ref).
The indexes for a `HDRimage` pixel matrix with `w` width and `h` height 
follow this sketch:
```ditaa
    (0,0) - (0,1) - ... - (0,w)
    (1,0) - (1,1) - ... - (1,w)
    ...
    (h,1) - (h,2) - ... - (h,w)
```
"""
get_pixel(hdr::HDRimage, x::Int, y::Int) = hdr.rgb_m[pixel_offset(hdr, x, y)]

##########################################################################################92

"""
    set_pixel(hdr::HDRimage, x::Int, y::Int, c::RGB{Float32})

Set the new `RGB{Float32}` color for the `(x, y)` pixel in the given [`HDRimage`](@ref).
The indexes for a `HDRimage` pixel matrix with `w` width and `h` height 
follow this sketch:
```ditaa
    (0,0) - (0,1) - ... - (0,w)
    (1,0) - (1,1) - ... - (1,w)
    ...
    (h,1) - (h,2) - ... - (h,w)
```
"""
set_pixel(hdr::HDRimage, x::Int, y::Int, c::RGB{Float32}) = 
    (hdr.rgb_m[pixel_offset(hdr, x,y)] = c; nothing)

set_pixel(hdr::HDRimage, x::Int, y::Int, c::RGB{T}) where {T}= 
    (hdr.rgb_m[pixel_offset(hdr,x,y)] = convert(RGB{Float32}, c); nothing)
##########################################################################################92

struct InvalidPfmFileFormat <: Exception
    var::String
end

##########################################################################################92

"""
    write(io::IO, img::HDRimage)

Write the given [`HDRimage`](@ref) image using the given `IO` stream.
The `endianness` used for writing the file is Little Endian (`-1.0`).
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
    parse_img_size(line::String) -> (Int64, Int64)

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

##########################################################################################92

"""
    parse_endianness(ess::String) -> Float64

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

##########################################################################################92

"""
    read_float(io::IO, ess::Float64) -> Float32
    
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

##########################################################################################92

"""
    read_line(io::IO) -> String

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

##########################################################################################92

"""
    read(io::IO, ::Type{HDRimage}) -> HDRimage

Read a PFM image from a stream object `io`.
Return a [`HDRimage`](@ref) object containing the image. If an error occurs, raise a
`InvalidPfmFileFormat` exception.

See also: [`read_line`](@ref)(`::IO`), [`parse_image_size`](@ref)(`::String`),
[`parse_endianness`](@ref)(`::String`), [`read_float`](@ref)(`::IO, `::Float64`)
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
    parse_command_line((args::Vector{String}) -> (String, String, Float64, Float64)

Interpret the command line when the main is executed, 
and manage eventual argument errors.

# Arguments
An array of strings, with length 2, 3 or 4, cointaining:
- first string (required): input file name, must be a PFM format
- second string (required): output filename, its format can be PNG or TIFF
- [`a`] : scale  factor for luminosity correction (default 0.18, 
used in [`normalize_image!`](@ref))
- [`γ`] : gamma factor for screen correction (default 1.0, used in [`γ_correction!`](@ref)

# Returns
A tuple `(infile, outfile, a, γ)`, with `a` and `γ` with type `Float64`

See also : [`normalize_image!`](@ref)), [`γ_correction!`](@ref)
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
        -> (String, String, Float64, Float64)

Parse a `Dict{String, Any}` for the [`tone_mapping`](@ref) function;
return a tuple `(pfm, png, a, γ)` containing the pfm input filename `pfm`, 
the LDR output filename `png`, the scale factor `a` and the gamma factor `γ`.

The keys for the input `Dict` are, respectively: "alpha", "gamma", "pfm_infile", "outfile"

See also:  [`tone_mapping`](@ref)
"""
function parse_tonemapping_settings(dict::Dict{String, Any})
    a::Float64 = dict["alpha"]
    γ::Float64 = dict["gamma"]
    pfm::String = dict["pfm_infile"]
    png::String = dict["outfile"]
    return (pfm, png, a, γ)
end

"""
    parse_demo_settings(dict::Dict{String, Any}) 
        -> (Bool, String, Float64, Int64, Int64, String, String)

Parse a `Dict{String, Any}` for the [`demo`](@ref) function;
return a tuple `(view_ort, α, w, h, pfm, png)` containing a bool `view_ort` for the choosen point of view
(`true`->Orthogonal, `false`->Perspective), the angle of view `α`, the number of pixels
on width `w` and height `h`, the pfm output filename `pfm` and the LDR
output filename `png`.

The keys for the input `Dict` are, respectively: "camera_type", "algorithm", "alpha",
 "width", "height", "set-pfm-name", "set-png-name"

See also:  [`demo`](@ref)
"""
function parse_demo_settings(dict::Dict{String, Any})
    view::String = dict["camera_type"]
    alg::String = dict["algorithm"]
    α::Float64 = dict["alpha"]
    w::Int64 = dict["width"]
    h::Int64 = dict["height"]
    pfm::String = dict["set-pfm-name"]
    png::String = dict["set-png-name"]

    view_ort = nothing
    view == "ort" ? view_ort = true : nothing
    view == "per" ? view_ort = false : nothing
    !(isnothing(view_ort)) || 
        throw(ArgumentError("""view must be "ort" or "per", but instead is equal to view=$view"""))

    return (view_ort, alg, α, w, h, pfm, png)
end


"""
    parse_demoanimation_settings(dict::Dict{String, Any}) 
        -> (Bool, String, Int64, Int64, String)

Parse a `Dict{String, Any}` for the [`demo_animation`](@ref) function;
return a tuple `(view_ort, w, h, anim)` containing a bool `view_ort` for the choosen point of view
(`true`->Orthogonal, `false`->Perspective), the number of pixels
on width `w` and height `h` and the output animation name `anim`.

The keys for the input `Dict` are, respectively: "camera_type", "algorithm",
 "width", "height", "set-anim-name"

See also:  [`demo_animation`](@ref), [`demo`](@ref)
"""
function parse_demoanimation_settings(dict::Dict{String, Any})
    view::String = dict["camera_type"]
    alg::String = dict["algorithm"]
    w::Int64 = dict["width"]
    h::Int64 = dict["height"]
    anim::String = dict["set-anim-name"]


    view_ort = nothing
    view == "ort" ? view_ort = true : nothing
    view == "per" ? view_ort = false : nothing
    !(isnothing(view_ort)) || 
        throw(ArgumentError("""view must be "ort" or "per", but instead is equal to view=$view"""))

    return (view_ort, alg, w, h, anim)
end
