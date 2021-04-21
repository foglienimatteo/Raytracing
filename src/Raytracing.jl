module Raytracing

using Colors, LinearAlgebra, StaticArrays
using ColorTypes:RGB
#import ColorTypes:RGB  #specificare sempre cosa si importa. In questo caso posso evitare di secificare nella funzione "x::ColorTypes.RGB{T}"
import Base.:+; import Base.:-; import Base.:≈; import Base.:/; import Base.:*
import Base: write, read, print, println;
import LinearAlgebra.:⋅; import LinearAlgebra.:×

export HDRimage, Parameters, Vec, Point, Normal, Transformation


# ----------------------------------------------------------------------------------------------------------------------------------------
# STRUCTs

struct HDRimage
    width::Int64
    height::Int64
    rgb_m::Array{RGB{Float32}}

    HDRimage(w,h) = new(w,h, fill(RGB(0.0, 0.0, 0.0), (w*h,)) )
    function HDRimage(w,h, rgb_m) 
        @assert size(rgb_m) == (w*h,)
        new(w,h, rgb_m)
    end
end # HDRimage

struct Parameters
    infile::String
    outfile::String
    a::Float64
    γ::Float64
    Parameters(in, out, a, γ) = new(in, out, a, γ)
    Parameters(in, out, a) = new(in, out, a, 1.0)
    Parameters(in, out) = new(in, out, 0.18, 1.0)
end

struct Point
    x::Float64
    y::Float64
    z::Float64
    Point(x, y, z) = new(x, y, z)
    Point() = new(0., 0. ,0.)
end

struct Normal
    x::Float64
    y::Float64
    z::Float64

    function Normal(x, y, z)
        m = √(x^2+y^2+z^2)
        new(x/m, y/m, z/m)
    end
end

struct Vec
    x::Float64
    y::Float64
    z::Float64
    Vec(x, y, z) = new(x, y, z)
    Vec()=new(0.0, 0.0, 0.0)
end

struct Transformation
    M::SMatrix{4,4,Float64}
    invM::SMatrix{4,4,Float64}
    Transformation(m, invm) = new(m, invm)
end


# ----------------------------------------------------------------------------------------------------------------------------------------
# NEW OPERATIONS

are_close(x,y,epsilon=1e-10) = abs(x-y) < epsilon
Base.:≈(a::RGB{T}, b::RGB{T}) where {T} = are_close(a.r,b.r) && are_close(a.g,b.g) && are_close(a.b, b.b)
Base.:≈(a::Vec, b::Vec) = are_close(a.x, b.x) && are_close(a.y, b.y) && are_close(a.z, b.z)
Base.:≈(a::Normal, b::Normal) = are_close(a.x, b.x) && are_close(a.y, b.y) && are_close(a.z, b.z)
Base.:≈(a::Point, b::Point) = are_close(a.x, b.x) && are_close(a.y, b.y) && are_close(a.z,b.z)
Base.:≈(m1::SMatrix{4,4,Float64}, m2::SMatrix{4,4,Float64}) = (B = [are_close(m,n) for (m,n) in zip(m1,m2)] ; all(i->(i==true) , B) )
Base.:≈(t1::Transformation, t2::Transformation) = (t1.M ≈ t2.M) && ( t1.invM ≈ t2.invM )

# Definitions of operations for RGB objects
Base.:+(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r + b.r, a.g + b.g, a.b + b.b)
Base.:-(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r - b.r, a.g - b.g, a.b - b.b)
Base.:*(scalar::Real, c::RGB{T}) where {T} = RGB(scalar*c.r , scalar*c.g, scalar*c.b)
Base.:*(c::RGB{T}, scalar::Real) where {T} = scalar * c
Base.:/(c::RGB{T}, scalar::Real) where {T} = RGB(c.r/scalar , c.g/scalar, c.b/scalar)

# Definitions of operations for Vec
Base.:+(a::Vec, b::Vec) = Vec(a.x+b.x, a.y+b.y, a.z+b.z)
Base.:-(a::Vec, b::Vec) = Vec(a.x-b.x, a.y-b.y, a.z-b.z)
Base.:*(s::Real, a::Vec) = Vec(s*a.x, s*a.y, s*a.z)
Base.:*(a::Vec, s::Real) = Vec(s*a.x, s*a.y, s*a.z)
Base.:/(a::Vec, s::Real) = Vec(a.x/s, a.y/s, a.z/s)
LinearAlgebra.:⋅(a::Vec, b::Vec) = a.x*b.x + a.y*b.y + a.z*b.z
LinearAlgebra.:×(a::Vec, b::Vec) = Vec(a.y*b.z-a.z*b.y, b.x*a.z-a.x*b.z, a.x*b.y-a.y*b.x)

# Definitions of operations between Vec and Point
Base.:+(p::Point, v::Vec) = Point(p.x+v.x, p.y+v.y, p.z+v.z)
# Base.:+(v::Vec, p::Point) = Point(p.x+v.x, p.y+v.y, p.z+v.z)
Base.:-(p::Point, v::Vec) = Point(p.x-v.x, p.y-v.y, p.z-v.z)
Base.:*(s::Real, a::Point) = Point(s*a.x, s*a.y, s*a.z)
Base.:*(a::Point, s::Real) = Point(s*a.x, s*a.y, s*a.z)
Base.:-(a::Point, b::Point) = Vec(b.x-a.x, b.y-a.y, b.z-a.z)

# Definitions of operations for Transformations
Base.:*(s::Transformation, t::Transformation) = Transformation(s.M*t.M, t.invM*s.invM)
function Base.:*(t::Transformation, p::Point)
    q = Point(t.M[1] * p.x + t.M[5] *p.y +t.M[9] *p.z +t.M[13],
              t.M[2] * p.x + t.M[6] *p.y +t.M[10] *p.z +t.M[14],
              t.M[3] * p.x + t.M[7]*p.y +t.M[11]*p.z +t.M[15]
    )
    λ = t.M[4] * p.x + t.M[8]*p.y +t.M[12]*p.z +t.M[16]
    λ == 1.0 ? (return q) : (return q/λ)
end
function Base.:*(t::Transformation, p::Vec)
    Vec(t.M[1] * p.x + t.M[5] * p.y + t.M[9]  * p.z, 
        t.M[2] * p.x + t.M[6] * p.y + t.M[10] * p.z, 
        t.M[3] * p.x + t.M[7] * p.y + t.M[11] * p.z)
end
function Base.:*(t::Transformation, n::Normal)
    Mat = transpose(t.invM)
    l = Normal(Mat[1] * n.x + Mat[5] * n.y + Mat[9]  *n.z,
               Mat[2] * n.x + Mat[6] * n.y + Mat[10] *n.z,
               Mat[3] * n.x + Mat[7] * n.y + Mat[11] *n.z
    )
    return l
end


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

luminosity(c::RGB{T}) where {T} = (max(c.r, c.g, c.b) + min(c.r, c.g, c.b))/2.
function avg_lum(img::HDRimage, δ::Number=1e-10)
    cumsum=0.0
    for pix in img.rgb_m
        cumsum += log10(δ + luminosity(pix))
    end
    10^(cumsum/(img.width*img.height))
end # avg_lum

function normalize_image!(img::HDRimage, a::Number=0.18, lum::Union{Number, Nothing}=nothing, δ::Number=1e-10)
    (!isnothing(lum)) || (lum = avg_lum(img, δ))
    img.rgb_m .= img.rgb_m .* a ./lum
    nothing
end # normalize_image

_clamp(x::Number) = x/(x+1)
function clamp_image!(img::HDRimage)
    h=img.height
    w=img.width
    for y in h-1:-1:0, x in 0:w-1
        col = get_pixel(img, x, y)
        T = typeof(col).parameters[1]
        new_col = RGB{T}( _clamp(col.r), _clamp(col.g), _clamp(col.b) )
        set_pixel(img, x,y, new_col)
    end
    nothing
end # clamp_image

function parse_command_line(args)
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
            a = parse(Float64, args[3] )
            a>0. || throw(Exception)
        catch e
            throw(InvalidArgumentError("invalid value for a: $(args[3])  must be a positive number"))
        end

        if length(args)==4
            try
                γ = parse(Float64, args[4] )
                γ>0. || throw(Exception)
            catch e
                throw(InvalidArgumentError("invalid value for γ: $(args[4])  must be a positive number"))
            end
        end
    end

    return infile, outfile, a, γ
end

function overturn(img::HDRimage)
    w = img.width
    h = img.height
    IMG = reshape(img.rgb_m, (w,h))
    IMG = permutedims(IMG)
    #IMG = reverse(IMG, dims=1)

    return IMG
end

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

function rotation_x(ϑ::Float64)
    Transformation(
        [1.0    0.0     0.0     0.0 ;   
         0.0    cos(ϑ)  -sin(ϑ) 0.0 ;
         0.0    sin(ϑ)  cos(ϑ)  0.0 ;
         0.0    0.0     0.0     1.0]
         ,
        [1.0    0.0     0.0     0.0 ;   
         0.0    cos(ϑ)  sin(ϑ)  0.0 ;
         0.0    -sin(ϑ) cos(ϑ)  0.0 ;
         0.0    0.0     0.0     1.0]
    )
end

function rotation_y(ϑ::Float64)
    Transformation(
        [cos(ϑ)     0.0     sin(ϑ)  0.0 ;
         0.0        1.0     0.0     0.0 ;
         -sin(ϑ)    0.0     cos(ϑ)  0.0 ;
         0.0        0.0     0.0     1.0  ]
         ,
        [cos(ϑ)     0.0     -sin(ϑ) 0.0 ;
         0.0        1.0     0.0     0.0 ;
         sin(ϑ)     0.0     cos(ϑ)  0.0 ;
         0.0        0.0     0.0     1.0  ]
    )
end

function rotation_z(ϑ::Float64)
    Transformation(
        [cos(ϑ) -sin(ϑ) 0.0     0.0 ;
         sin(ϑ) cos(ϑ)  0.0     0.0 ;
         0.0    0.0     1.0     0.0 ;
         0.0    0.0     0.0     1.0]
         ,
        [cos(ϑ)     sin(ϑ)  0.0     0.0 ;
         -sin(ϑ)    cos(ϑ)  0.0     0.0 ;
         0.0        0.0     1.0     0.0 ;
         0.0        0.0     0.0     1.0]
    )
end

function scaling(v::Vec)
    Transformation(
        [v.x    0.0     0.0     0.0 ;
         0.0    v.y     0.0     0.0 ;
         0.0    0.0     v.z     0.0 ;
         0.0    0.0     0.0     1.0]
         ,
        [1/v.x  0.0     0.0     0.0 ;
         0.0    1/v.y   0.0     0.0 ;
         0.0    0.0     1/v.z   0.0 ;
         0.0    0.0     0.0     1.0]
    )
end

function translation(v::Vec)
   Transformation(
        [1.0    0.0     0.0     v.x ;
         0.0    1.0     0.0     v.y ;
         0.0    0.0     1.0     v.z ;
         0.0    0.0     0.0     1.0]
         ,
        [1.0    0.0     0.0     -v.x ;
         0.0    1.0     0.0     -v.y ;
         0.0    0.0     1.0     -v.z ;
         0.0    0.0     0.0     1.0]
    )
end

function is_consistent(T::Transformation)
    p = T.M * T.invM
    I = SMatrix{4,4}( Diagonal(ones(4)) )
    return p ≈ I
end

end  # module