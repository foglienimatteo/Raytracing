```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Reading and Writing PFM file

```@docs
Raytracing.valid_coordinates
Raytracing.pixel_offset
Raytracing.get_pixel
Raytracing.set_pixel
Raytracing.write(::IO, ::HDRimage)
Raytracing.parse_img_size
Raytracing.parse_endianness
Raytracing.read_float
Raytracing.read_line
read(::IO, ::Type{HDRimage})
load_image
ldr2pfm
```