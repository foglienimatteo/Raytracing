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
    luminosity(c::RGB{T}) -> Float64

Gives the best average luminosity of a Pixel.
As input needs a `::RGB{T}` and returns a `::Float64`.
"""
luminosity(c::RGB{T}) where {T} = (max(c.r, c.g, c.b) + min(c.r, c.g, c.b))/2.

##########################################################################################92

"""
    avg_lum(img::HDRimage, δ::Number=1e-10) -> Float64

Return the average luminosity of the image
The `delta` parameter is used to prevent  numerical problems for underilluminated pixels
"""
function avg_lum(img::HDRimage, δ::Number=1e-10)
    cumsum=0.0
    for pix in img.rgb_m
        cumsum += log10(δ + luminosity(pix))
    end
    10^(cumsum/(img.width*img.height))
end # avg_lum

##########################################################################################92

"""
    normalize_image!(img::HDRimage, a::Number=0.18, lum::Union{Number, Nothing}=nothing,
    δ::Number=1e-10)

Normalize all the RGB components of a `::HDRimage` with its average luminosity
(given by avg_lum(`::HDRimage`, `::Number`)) and a factor 'a' (by default a=0.18,
can be changed).
"""
function normalize_image!(img::HDRimage, a::Number=0.18,
                          lum::Union{Number, Nothing}=nothing, δ::Number=1e-10
    )
    (!isnothing(lum)) || (lum = avg_lum(img, δ))
    img.rgb_m .= img.rgb_m .* a ./lum
    nothing
end # normalize_image

##########################################################################################92

"""
    clamp(x::Number) -> Float64

Execute: x → x/(x+1)
"""
clamp(x::Number) = x/(x+1)

##########################################################################################92

"""
    clamp_image!(img::HDRimage)

Adjust the color levels of the brightest pixels in the image.
"""
function clamp_image!(img::HDRimage)
    h=img.height
    w=img.width
    for y in h-1:-1:0, x in 0:w-1
        col = get_pixel(img, x, y)
        T = typeof(col).parameters[1]
        new_col = RGB{T}( clamp(col.r), clamp(col.g), clamp(col.b) )
        set_pixel(img, x,y, new_col)
    end
    nothing
end # clamp_image

##########################################################################################92

"""
    γ_correction!(img::HDRimage, γ::Float64=1.0, k::Float64=1.)

Corrects the image using the γ factor, assuming a potential dependence between the input
and putput signals of a monitor/screen. 

As third optional argument, you can pass the maximum value 'k' of the range you want the
RGB colors may have. The default value is 'k=1.0', so the range RGB colors can span
is '[0.0, 1.0]'.
"""
function γ_correction!(img::HDRimage, γ::Float64=1.0, k::Float64=1.)
    h=img.height
    w=img.width
    for y in h-1:-1:0, x in 0:w-1
        cur_color = get_pixel(img, x, y)
        T = typeof(cur_color).parameters[1]
        new_col = RGB{T}( floor(255 * cur_color.r^(1/γ)),
                          floor(255 * cur_color.g^(1/γ)),
                          floor(255 * cur_color.b^(1/γ))
        )
        set_pixel(img, x,y, k/255.0*new_col)
    end
    nothing
end

##########################################################################################92

function overturn(m::Matrix{T}) where T
    m = permutedims(m)
    #m = reverse(m, dims=1)
    return m
end

##########################################################################################92

function get_matrix(img::HDRimage)
    m = reshape(img.rgb_m, (img.width,img.height))
    return overturn(m)
end

##########################################################################################92


function tone_mapping(infile::String, outfile::String, a::Float64=0.18, γ::Float64=1.0)
    tone_mapping(["$(infile)", "$(outfile)", "$a", "$γ"])
end

function tone_mapping(args::Vector{String})
    correct_usage =  
        "\ncorrect usage of tone mapping function for vector of string arguments:\n"*
        "julia>  tonemapping([\"infile\",\"outfile\" ])\n"*
        "julia>  tonemapping([\"infile\",\"outfile\", \"a\"])\n"*
        "julia>  tonemapping([\"infile\",\"outfile\",  \"a\",  \"γ\" ])\n\n"*
        "default values are a=0.18 and γ=1.0\n\n"
    if isempty(args) || length(args)==1 || length(args)>4
        throw(ArgumentError(correct_usage))
		return nothing

    end
	parameters = nothing
	try
		parameters =  Parameters(parse_command_line(args)...)
	catch e
		println("Error: ", e)
        println(correct_usage)
		return nothing
	end

	img = open(parameters.infile, "r") do inpf; read(inpf, HDRimage); end
	
	println("\nfile $(parameters.infile) has been read from disk.\n")

	normalize_image!(img, parameters.a)
	clamp_image!(img)
	Raytracing.γ_correction!(img, parameters.γ)
	#println(img, 3)
	
	matrix = get_matrix(img)
	Images.save(parameters.outfile, matrix)
	#Images.save(Images.File(PNG,parameters.outfile), img.rgb_m)
	#Images.save(File("PNG", parameters.outfile), img.rgb_m)

	println("\nFile $(parameters.outfile) has been written into the disk.\n")

end
