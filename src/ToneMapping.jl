# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#


@doc raw"""
    luminosity(c::RGB{T}) :: Float64

Return the best average luminosity of a color ``c = (R_i, G_i, B_i)``, through
the Shirley & Morley proposal:

```math
l_i = \frac{\max\{R_i, G_i, B_i \} + \min\{R_i, G_i, B_i \}}{2}
```
"""
luminosity(c::RGB{T}) where {T} = (max(c.r, c.g, c.b) + min(c.r, c.g, c.b))/2.

"""
    lum_max(img::HDRimage) :: Float64

Return the maximum luminosity of the given `img` according to the
`luminosity` function of a color.

See also: [`HDRimage`](@ref), [`luminosity`](@ref)
"""
function lum_max(img::HDRimage) 
    lum_max=0.0
    for pix in img.rgb_m
        (lum_max>luminosity(pix)) || (lum_max=luminosity(pix))
    end
    lum_max
end

"""
    avg_lum(img::HDRimage, δ::Number=1e-10) :: Float64

Return the average luminosity of the `img` according to the
`luminosity` function of a color.
The `δ` parameter is used to prevent  numerical problems for 
under-illuminated pixels.

See also: [`HDRimage`](@ref), [`luminosity`](@ref)
"""
function avg_lum(img::HDRimage, δ::Number=1e-10)
    cumsum=0.0
    for pix in img.rgb_m
        cumsum += log10(δ + luminosity(pix))
    end
    10^(cumsum/(img.width*img.height))
end

@doc raw"""
    normalize_image!(  
            img::HDRimage, 
            a::Float64 = 0.18,
            lum::Union{Number, Nothing} = nothing, 
            δ::Number = 1e-10
            )

Normalize the `img` colors through the following formula: 

```math
\forall \; \mathrm{colors} \, c =(R_i, G_i, B_i) \; 
\mathrm{of \, the \, image}   \\\\

X_i \rightarrow \frac{a}{\langle l \rangle} X_i 
    \quad , \quad  
\forall X_i = R_i, G_i, B_i 
```
where ``\langle l \rangle`` is the average luminosity returned
by the `avg_lum` function. 

See also: [`HDRimage`](@ref), [`avg_lum`](@ref)
"""
function normalize_image!(  
            img::HDRimage, 
            a::Float64=0.18,
            lum::Union{Number, Nothing}=nothing, 
            δ::Number=1e-10
            )

    (isnothing(lum) || lum≈0.0 ) && (lum = avg_lum(img, δ))
    img.rgb_m .= img.rgb_m .* a .* (1.0/lum)
    nothing
end 

@doc raw"""
    clamp(x::Number) :: Float64

Clamping function:

```math  
x \rightarrow x/(x+1)
```
"""
clamp(x::Number) = x/(x+1)


"""
    clamp_image!(img::HDRimage)

Adjust the color levels of the brightest pixels in the `img`
through the `clamp` function.

See also: [`HDRimage`](@ref), [`clamp`](@ref)
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
end

"""
    γ_correction!(img::HDRimage, γ::Float64=1.0, k::Float64=1.0)

Corrects the image using the `γ` factor, assuming a potential dependence 
between the input and output signals of a monitor/screen. 

As third optional argument, you can pass the maximum value 'k' of the range 
you want the RGB colors may have. The default value is 'k=1.0', so the range 
RGB colors can span is '[0.0, 1.0]'

See also: [`HDRimage`](@ref)
"""
function γ_correction!(img::HDRimage, γ::Float64=1.0, k::Float64=1.0)
    h=img.height
    w=img.width
    for y in h-1:-1:0, x in 0:w-1
        cur_color = get_pixel(img, x, y)
        T = typeof(cur_color).parameters[1]
        new_col = RGB{T}( floor(255 * cur_color.r^(1/γ)),
                          floor(255 * cur_color.g^(1/γ)),
                          floor(255 * cur_color.b^(1/γ))
        )
        set_pixel(img, x, y, k/255.0*new_col)
    end
    nothing
end


##########################################################################################92


function tone_mapping(x::(Pair{T1,T2} where {T1,T2})...)
	tone_mapping( parse_tonemapping_settings(  Dict( pair for pair in [x...]) )... )
end

function tone_mapping(
            infile::String, 
            outfile::String, 
            a::Float64=0.18, 
            γ::Float64=1.0, 
            ONLY_FOR_TESTS::Bool=false
            )
    (ONLY_FOR_TESTS==false) || (return nothing)       
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

	println("\nFile $(parameters.outfile) has been written into the disk.\n")
end

"""
$(SIGNATURES)

Tone-map the given input pfm file `infile` with luminosity
normalisation `a` and gamma factor `γ`.
Return a file with the input outfile name `outfile` and 
of the specified LDR format, if possible.

In order to do the tone-mapping, this function relies on the
following three function, called in the presented order:

- `normalize_image!` : normalize the image colors
- `clamp_image!` : adjust the color levels of the brightest pixels
- `γ_correction!` : corrects the image using the `γ` factor

See also: [`normalize_image!`](@ref), [`clamp_image!`](@ref), [`γ_correction!`](@ref)
"""
tone_mapping
