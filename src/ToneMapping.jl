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
            a = parse(Float64, args[3])
            a > 0. || throw(Exception)
        catch e
            throw(InvalidArgumentError("invalid value for a: $(args[3])  must be a positive number"))
        end

        if length(args) == 4
            try
                γ = parse(Float64, args[4])
                γ > 0. || throw(Exception)
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