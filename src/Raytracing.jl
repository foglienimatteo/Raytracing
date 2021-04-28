module Raytracing

using Colors, LinearAlgebra, StaticArrays
using ColorTypes:RGB
#import ColorTypes:RGB  #specificare sempre cosa si importa. In questo caso posso evitare di secificare nella funzione "x::ColorTypes.RGB{T}"
import Base.:+; import Base.:-; import Base.:≈; import Base.:/; import Base.:*
import Base: write, read, print, println;
import LinearAlgebra.:⋅; import LinearAlgebra.:×

export HDRimage, Parameters, Vec, Point, Normal, Transformation, Ray
export translation, scaling, rotation_x, rotation_y, rotation_z, inverse

include("Structs.jl")
include("Operations.jl")
include("ToneMapping.jl")

# ----------------------------------------------------------------------------------------------------------------------------------------
# READING & WRITING FILE

valid_coordinates(hdr::HDRimage, x::Int, y::Int) = x>=0 && y>=0 && x<hdr.width && y<hdr.height
pixel_offset(hdr::HDRimage, x::Int, y::Int) = (@assert valid_coordinates(hdr, x, y); y*hdr.width + (x+1) )
get_pixel(hdr::HDRimage, x::Int, y::Int) = hdr.rgb_m[pixel_offset(hdr, x, y)]
set_pixel(hdr::HDRimage, x::Int, y::Int, c::RGB{T}) where {T} = (hdr.rgb_m[pixel_offset(hdr, x,y)] = c; nothing)
print_rgb(c::RGB{T}) where {T} = println("RGB component of this color: \t$(c.r) \t$(c.g) \t$(c.b)")

struct InvalidPfmFileFormat <: Exception
    var::String
end #InvalidPfmFileFormat

function write(io::IO, img::HDRimage)
    endianness=-1.0
    w = img.width
    h = img.height
    # The PFM header, as a Julia string (UTF-8)
    header = "PF\n$w $h\n$endianness\n"

    # Convert the header into a sequence of bytes
    bytebuf = transcode(UInt8, header) # transcode scrive in sequenza grezza di byte (8bit)

    # Write on io the header in binary code
    write(io, reinterpret(UInt8, bytebuf))  # reinterpret scrive in sequenza grezza di byte (8bit)

    # Write the image (bottom-to-up, left-to-right)
    for y in h-1:-1:0, x in 0:w-1                   # !!! Julia conta sempre partendo da 1; prende gli estremi
        color = get_pixel(img, x, y)
        write(io, reinterpret(UInt8,  [color.r]))   #!!! reinterpret(UInt8, [...]) bisogna specificare il tipo
        write(io, reinterpret(UInt8,  [color.g]))   # e passargli il vettore [] da cambiare, anche se contiene
        write(io, reinterpret(UInt8,  [color.b]))   # un solo elemento
    end

end # write(::IO, ::HDRimage)

function parse_img_size(line::String)
    elements = split(line, " ")
    length(elements) == 2 || throw(InvalidPfmFileFormat("invalid image size specification: $(length(elements)) instead of 2"))

    try
        width, height = convert.(Int, parse.(Float64, elements))
        (width > 0 && height > 0) || throw(ErrorException)
        return width, height
    catch e
        isa(e, InexactError) || throw(InvalidPfmFileFormat("cannot convert width/heigth $(elements) to Tuple{Int, Int}"))
        isa(e, ErrorException) || throw(InvalidPfmFileFormat("width/heigth cannot be negative, but in $(elements) at least one of them is <0."))
    end

end # parse_img_size

function parse_endianness(ess::String)
    try
        val = parse(Float64, ess)
        (val == 1.0 || val == -1.0) || throw(InvalidPfmFileFormat("invalid endianness in PFM file: $(parse(Float64, ess)) instead of +1.0 or -1.0.\n"))
        return val
    catch e
        throw(InvalidPfmFileFormat("missing endianness in PFM file: $ess instead of ±1.0"))
    end
end # parse_endianness

function read_float(io::IO, ess::Float64)
    # controllo che in ingresso abbia una stringa che sia cnovertibile in Float32
    ess == 1.0 || ess == -1.0 || throw(InvalidPfmFileFormat("endianness $ess not acceptable."))
    try
        value = read(io, Float32)   # con Float32 leggo già i 4 byte del colore
        ess == 1.0 ? value = ntoh(value) : value = ltoh(value) # converto nell'endianness utilizzata dalla macchina
        return value
    catch e
        throw(InvalidPfmFileFormat("color is not Float32, it's a $(typeof(io))"))   # ess → io
    end
end # read_float

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
end # read_line

function read(io::IO, ::Type{HDRimage})
    magic = read_line(io)
    # lettura numero magico
    magic == "PF" || throw(InvalidPfmFileFormat("invalid magic number in PFM file: $(magic) instead of 'PF'.\n"))
    
    # lettura dimensioni immagine
    img_size = read_line(io)
    typeof(parse_img_size(img_size)) == Tuple{Int,Int} || throw(InvalidPfmFileFormat("invalid img size in PFM file: $(parse_img_size(img_size)) is $( typeof(parse_img_size(img_size)) ) instead of 'Tuple{UInt,UInt}'.\n"))
    (width, height) = parse_img_size(img_size)
    
    #lettura endianness
    ess_line = read_line(io)
    parse_endianness(ess_line) == 1.0 || parse_endianness(ess_line)== -1.0 || throw(InvalidPfmFileFormat("invalid endianness in PFM file: $(parse_endianness(ess_line)) instead of +1.0 or -1.0.\n"))
    endianness = parse_endianness(ess_line)

    # lettura e assegnazione matrice coloti
    result = HDRimage(width, height)
    for y in height-1:-1:0, x in 0:width-1

        (r,g,b) = [read_float(io, endianness) for i in 0:2]
        set_pixel(result, x, y, RGB(r,g,b) )
    end

    return result
end # read_pfm_image(::IO)

# ----------------------------------------------------------------------------------------------------------------------------------------
# IMAGE



# ----------------------------------------------------------------------------------------------------------------------------------------
# PRINT VEC, PRINT POINT AND NORM FUNCTIONS

print(io::IO, v::Vec) = (print(io, "Vec:\t ", v.x, "\t", v.y, "\t", v.z); nothing)
print(v::Vec) = (print(stdout, v); nothing)
println(v::Vec) = (println(stdout,v); nothing)
println(io::IO,v::Vec) = (print(io, v); print("\n"); nothing)

print(io::IO, p::Point) = (print(io, "Point:\t ", p.x, "\t", p.y, "\t", p.z); nothing)
print(p::Point) = (print(stdout, p); nothing)
println(p::Point) = (println(stdout,p); nothing)
println(io::IO,p::Point) = (print(io, p); print("\n"); nothing)

squared_norm(v::Union{Vec,Point}) = v.x^2 + v.y^2 + v.z^2
norm(v::Union{Vec,Point}) = √squared_norm(v)
normalize(v::Vec) = v/norm(v)

# ----------------------------------------------------------------------------------------------------------------------------------------
# Transformation FUNCTIONS



# ----------------------------------------------------------------------------------------------------------------------------------------
# base rendering FUNCTIONS

at(r::Ray, t::Float64) = r.origin + r.dir * t

function fire_ray(ImTr::ImageTracer, col::Int64, row::Int64, u_px::Float64=0.5, v_px::Float64=0.5)
    u = (col + u_px) / (ImTr.img.width - 1)
    v = (row + v_px) / (ImTr.img.height - 1)
    return ImTr.cam.fire_ray(u, v)
end # fire_ray

function fire_ray(cam::Camera, u::Float64, v::Float64)
    """Shoot a ray through the camera's screen
        The coordinates (u, v) specify the point on the screen where the ray crosses it. Coordinates (0, 0) represent
        the bottom-left corner, (0, 1) the top-left corner, (1, 0) the bottom-right corner, and (1, 1) the top-right
        corner, as in the following diagram::
            (0, 1)                          (1, 1)
               +------------------------------+
               |                              |
               |                              |
               |                              |
               +------------------------------+
            (0, 0)                          (1, 0)
        """
        origin = Point(-1.0, (1.0 - 2 * u) * cam.a, 2 * v - 1)
        direction = VEC_X
        return cam.T * Ray(origin, direction, 1.0) # OrthogonalCamera
end

end  # module