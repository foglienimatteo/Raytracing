module Raytracing

using Colors  #generico
#using IOStream
import ColorTypes:RGB  #specificare sempre cosa si importa. In questo caso posso evitare di secificare nella funzione "x::ColorTypes.RGB{T}"
import Base.:+; import Base.:-; import Base.:≈; import Base.:*
import Base.write; import Base.read

#=
#T = Float64 errato

function Base.:+(x::RGB{T}, y::RGB{T}) where{T} #in questo modo tipo qualsiasi, per specificare: where{T<:real}
     RGB(x.r + y.r, x.g + y.g, x.b + y.b)
end
=#

# Definizione nuove operazioni con oggetti RGB
Base.:+(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r + b.r, a.g + b.g, a.b + b.b)
Base.:-(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r - b.r, a.g - b.g, a.b - b.b)
Base.:*(scalar, c::RGB{T}) where {T} = RGB(scalar*c.r , scalar*c.g, scalar*c.b)
Base.:*(c::RGB{T}, scalar) where {T} = scalar * c
Base.:≈(a::RGB{T}, b::RGB{T}) where {T} = are_close(a.r,b.r) && are_close(a.g,b.g) && are_close(a.b, b.b)

# Funzione di approssimazione
are_close(x,y,epsilon=1e-10) = abs(x-y) < epsilon

struct HDRimage
    width::Int
    height::Int
    rgb_m::Array{RGB{Float32}}

    # Costrutti
    HDRimage(w,h) = new(w,h, fill(RGB(0.0, 0.0, 0.0), (w*h,)) )
    
    function HDRimage(w,h, rgb_m) 
        @assert size(rgb_m) == (w*h,)
        new(w,h, rgb_m)
    end
end

valid_coordinates(hdr::HDRimage, x::Int, y::Int) = x>=0 && y>=0 && x<hdr.width && y<hdr.height

function pixel_offset(hdr::HDRimage, x::Int, y::Int)
    @assert valid_coordinates(hdr, x, y)
    y*hdr.width + (x+1)
end

get_pixel(hdr::HDRimage, x::Int, y::Int) = hdr.rgb_m[pixel_offset(hdr, x, y)]

function set_pixel(hdr::HDRimage, x::Int, y::Int, c::RGB{T}) where {T}
    hdr.rgb_m[pixel_offset(hdr, x,y)] = c
    return nothing
end

function print_rgb(c::RGB{T}) where {T}
    println("RGB component of this color: \t$(c.r) \t$(c.g) \t$(c.b)")
end


struct InvalidPfmFileFormat <: Exception
    var::Symbol
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
        println(x," ", y)
        color = get_pixel(img, x, y)
        print_rgb(color)
        println(reinterpret(UInt8,  [color.r]))     #!!! reinterpret(UInt8, [...]) bisogna specificare il tipo
        write(io, reinterpret(UInt8,  [color.r]))   # e passargli il vettore [] da cambiare, anche se contiene
        write(io, reinterpret(UInt8,  [color.g]))   # un solo elemento
        write(io, reinterpret(UInt8,  [color.b]))
    end

end # write(::IO, ::HDRimage)


function read(io::IO, HDRimage)
    magic = read_line(io)
    magic == "PF" || throw(InvalidPfmFileFormat("invalid magic number in PFM file: $(magic) instead of 'PF'.\n"))

    img_size = read_line(io)
    typeof(parse_img_size(img_size)) == Tuple{UInt,UInt} || throw(InvalidPfmFileFormat("invalid img size in PFM file: $(parse_img_size(img_size)) instead of 'Tuple{UInt,UInt}'.\n"))
    (width, height) = parse_img_size(img_size)

    endianness_line = read_line(io)
    parse_endianness(endianness_line) == 1.0 || parse_endianness(endianness_line)== -1.0 || throw(InvalidPfmFileFormat("invalid endianness in PFM file: $(parse_endianness(endianness_line)) instead of +1.0 or -1.0.\n"))
    endianness = parse_endianness(endianness_line)


    result = HDRimage(width, height)
    for y in height-1:-1:0, x in 0:width-1
        (r,g,b) = [read_float(io, endianness) for i in 0:2]
        result.set_pixel(x,y,RGB(r,g,b))

    return result

end #read_pfm_image(::IO)


#=
def read_pfm_image(stream):
    # The first bytes in a binary file are usually called «magic bytes»
    magic = _read_line(stream)
    if magic != "PF":
        raise InvalidPfmFileFormat("invalid magic in PFM file")

    img_size = _read_line(stream)
    (width, height) = _parse_img_size(img_size)

    endianness_line = _read_line(stream)
    endianness = _parse_endianness(endianness_line)

    result = HdrImage(width=width, height=height)
    for y in range(height - 1, -1, -1):
        for x in range(width):
            (r, g, b) = [_read_float(stream, endianness) for i in range(3)]
            result.set_pixel(x, y, Color(r, g, b))

    return result
=#
end # module
