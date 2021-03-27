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
        # println(x," ", y) # debugging
        color = get_pixel(img, x, y)
        # print_rgb(color)  # debugging
        println(reinterpret(UInt8,  [color.r]))     #!!! reinterpret(UInt8, [...]) bisogna specificare il tipo
        write(io, reinterpret(UInt8,  [color.r]))   # e passargli il vettore [] da cambiare, anche se contiene
        write(io, reinterpret(UInt8,  [color.g]))   # un solo elemento
        write(io, reinterpret(UInt8,  [color.b]))
    end

end # write(::IO, ::HDRimage)

function parse_endianness(es::String)
    # try
        val = parse(Float64, es) # Float32 -> Float64
        if val == 1.0
            return 1.0
        elseif val == -1.0
            return -1.0
        else
            # throw(InvalidPfmFileFormat("invalid endianness in PFM file: $(parse_endianness(es)) instead of +1.0 or -1.0.\n"))
            throw(InvalidPfmFileFormat("invalid endianness in PFM file: needed +1.0 or -1.0.\n"))
        end
#=    catch UndefVarError
        throw(InvalidPfmFileFormat("invalid endianness in PFM file: $(parse_endianness(es)) instead of +1.0 or -1.0.\n"))
    end
=#
  #  catch ArgumentError
   #     throw(InvalidPfmFileFormat("missing endianness in PFM file: $es instead of ±1.0"))
   # end
   #= if val == 1.0
        return 1.0
    elseif val == -1.0
        return -1.0
    else
        throw(InvalidPfmFileFormat("invalid endianness in PFM file: $(parse_endianness(es)) instead of +1.0 or -1.0.\n"))
    =#
    # val == 1.0 ? return 1.0 : (val == -1.0 ? return -1.0 : throw(InvalidPfmFileFormat("invalid endianness in PFM file: $(parse_endianness(endianness_line)) instead of +1.0 or -1.0.\n")))

end

function read_float(io::IO, ess::Float32)
    # controllo che in ingresso abbia una stringa che sia cnovertibile in Float32 
    try
        A = read(io, Float32)   # con Float32 leggo già i 4 bit del colore
    catch
        throw(InvalidPfmFileFormat("not Float32, it's a $typeof(ess)"))
    end
    ess > 0 ? ntoh(A) : ltoh(A) # converto nell'endianness utilizzata dalla macchina
end

function read(io::IO, HDRimage)
    # lettura numero magico
    magic = read_line(io)
    magic == "PF" || throw(InvalidPfmFileFormat("invalid magic number in PFM file: $(magic) instead of 'PF'.\n"))

    # lettura dimensioni immagine
    img_size = read_line(io)
    typeof(parse_img_size(img_size)) == Tuple{UInt,UInt} || throw(InvalidPfmFileFormat("invalid img size in PFM file: $(parse_img_size(img_size)) instead of 'Tuple{UInt,UInt}'.\n"))
    (width, height) = parse_img_size(img_size)

    #lettura endianness
    endianness_line = read_line(io)
    parse_endianness(endianness_line) == 1.0 || parse_endianness(endianness_line)== -1.0 || throw(InvalidPfmFileFormat("invalid endianness in PFM file: $(parse_endianness(endianness_line)) instead of +1.0 or -1.0.\n"))
    endianness = parse_endianness(endianness_line)

    # lettura e assegnazione matrice coloti
    result = HDRimage(width, height)
    for y in height-1:-1:0, x in 0:width-1
        (r,g,b) = (read_float(io, endianness) for i in 0:2) # (read_float(io, endianness), read_float(io, endianness), read_float(io, endianness))
        result.set_pixel(x, y, RGB(r,g,b))
    end # X MATTEO: QUI MANCAVA, NO?

    return result

end # read_pfm_image(::IO)

end # module
