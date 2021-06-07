```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Base Structs and functions of the program

```@docs
HDRimage 
to_RGB 
get_matrix
Parameters
Point
Vec
Normal
Transformation
Ray
at
Camera
fire_ray
ImageTracer
fire_all_rays!
Pigment
BRDF
Material
Shape
Vec2d
HitRecord
PointLight
World
add_shape!
add_light!
PCG
random
create_onb_from_z
scatter_ray
```
