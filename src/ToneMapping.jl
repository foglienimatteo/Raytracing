"""Gives the best average luminosity of a Pixel.
    As input needs a ::RGB{T} and returns a ::Float64."""
luminosity(c::RGB{T}) where {T} = (max(c.r, c.g, c.b) + min(c.r, c.g, c.b))/2.

"""Calculates the average luminosity of an ::HDRimage."""
function avg_lum(img::HDRimage, δ::Number=1e-10)
    cumsum=0.0
    for pix in img.rgb_m
        cumsum += log10(δ + luminosity(pix))
    end
    10^(cumsum/(img.width*img.height))
end # avg_lum

"""Normalize all the RGB components of a ::HDRimage with its average luminosity (given by avg_lum(::HDRimage, ::Number)) and a factor 'a' (by default a=0.18, can be changed)."""
function normalize_image!(img::HDRimage, a::Number=0.18, lum::Union{Number, Nothing}=nothing, δ::Number=1e-10)
    (!isnothing(lum)) || (lum = avg_lum(img, δ))
    img.rgb_m .= img.rgb_m .* a ./lum
    nothing
end # normalize_image

"""Execute: x → x/(x+1)"""
_clamp(x::Number) = x/(x+1)

"""Compress the RGB components of a ::HDRimage in the range [0.0; 1.0]."""
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

"""Corrects the image using the γ factor, assuming a potential dependence between the input and putput signals of a monitor/screen.
   As third argument you can pass also a 'k' value if you need a different normalization than having all the RGB values in [0.0, 1.0]."""
function γ_correction!(img::HDRimage, γ::Float64=1.0, k::Float64=255.)
    h=img.height
    w=img.width
    for y in h-1:-1:0, x in 0:w-1
        cur_color = get_pixel(img, x, y)
        T = typeof(cur_color).parameters[1]
        new_col = RGB{T}( floor(255 * cur_color.r^(1/γ) )/k,
                            floor(255 * cur_color.g^(1/γ))/k,
                            floor(255 * cur_color.b^(1/γ))/k
        )
        set_pixel(img, x,y, new_col)
    end
    nothing
end


function get_matrix(img::HDRimage)
    reshape(img.rgb_m, (img.width,img.height))
end

function overturn(m::Matrix{T}) where T
    m = permutedims(m)
    #m = reverse(m, dims=1)
    return m
end