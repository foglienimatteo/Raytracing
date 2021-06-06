```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Raytracer.jl : an implementation of a raytracing program in Julia

This is the documentation of [Raytracing.jl](https://github.com/cosmofico97/Raytracing) package, an implementation of a raytracing program written in Julia.

This program has various features: it can generate simple fotorealistic images and animations, read and write High Dynamic Range images in PFM format and manipulate them throug a tone mapping algorithm.


## Demo

Demo [`demo`](@ref) is the function that allows you to appreciate what type of image [Raytracing.jl](https://github.com/cosmofico97/Raytracing) can create. It has two principal scenaries: one very simple used to better understand how every renderer implemented work and see an exemlpe of animation, the other, the other uses most of the shapes and "material" imlpemented. You can both use the function with the default parameters or choose them to directly see functioning of each variable.


## Demo animation

Demo animation is a function showing a simple rotation of 360° around ten spheres (eight on the vertices of a cube and two on two surfaces). Uses [ffmpeg](https://www.ffmpeg.org/) software to generate a video (in `.gif` or `.mp4` format).


## Reading, writing and tone mapping PFM image

A useful features not only generating images but also as a mid step between the generation and the "public" visualization of an image is the possybility of saving a raw image and modify it. Following this pilosophy, after the generation two extension of the image are saved: `.pfm` and `.png`. If the luminosity or the color saturation doesn't correspond to your tastes or doesn't fit the color trait of your screen, you don't have to re-generate the whole image, but just need to find the best parameters to use in the tone mapping algorithm.


## Documentation

The documentation was built using [Documenter.jl](https://github.com/JuliaDocs).

```@example
using Dates # hide
println("Documentation built on $(now()) using Julia $(VERSION).") # hide
```

## Index

```@index
```

