module Raytracing

using Colors  #generico
#using IOStream
import ColorTypes:RGB  #specificare sempre cosa si importa. In questo caso posso evitare di secificare nella funzione "x::ColorTypes.RGB{T}"
import Base.:+; import Base.:-; import Base.:≈; import Base.:*
export HDRimage

#=
#T = Float64 errato

function Base.:+(x::RGB{T}, y::RGB{T}) where{T} #in questo modo tipo qualsiasi, per specificare: where{T<:real}
     RGB(x.r + y.r, x.g + y.g, x.b + y.b)
end
=#

Base.:+(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r + b.r, a.g + b.g, a.b + b.b)
Base.:-(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r - b.r, a.g - b.g, a.b - b.b)
Base.:*(scalar, c::RGB{T}) where {T} = RGB(scalar*c.r , scalar*c.g, scalar*c.b)
Base.:*(c::RGB{T}, scalar) where {T} = scalar * c
Base.:≈(a::RGB{T}, b::RGB{T}) where {T} = are_close(a.r,b.r) && are_close(a.g,b.g) && are_close(a.b, b.b)

are_close(x,y,epsilon=1e-10) = abs(x-y) < epsilon

struct HDRimage
    width::Int
    height::Int
    rgb_m::Array{RGB{Float32}}
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


function write(io::IO, img::HDRimage)
    endianness=-1.0
    w = img.width
    h = img.height
    # The PFM header, as a Julia string (UTF-8)
    header = "PF\n$w $h\n$endianness\n"

    # Convert the header into a sequence of bytes
    bytebuf = transcode(UInt8, header)

    #write on io the header in binary code
    println(bytebuf)
    write(io, reinterpret(UInt8, bytebuf))

    println("ciaociaooooo")

    # Write the image (bottom-to-up, left-to-right)
    for y in h:-1:0, x in 0:w
        color = get_pixel(img, x, y)

        println(reinterpret(UInt8,  color.r))
        write(io, reinterpret(UInt8,  color.r))
        write(io, reinterpret(UInt8,  color.g))
        write(io, reinterpret(UInt8,  color.b))
    end


end

end # module
