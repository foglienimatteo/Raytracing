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

