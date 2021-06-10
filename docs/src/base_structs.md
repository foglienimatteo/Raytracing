```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Base Structs and functions of the program

```@docs
Raytracing.HDRimage 
Raytracing.to_RGB 
Raytracing.get_matrix
Raytracing.Parameters
Raytracing.Point
Raytracing.Vec
Raytracing.Normal
Raytracing.Transformation
Raytracing.Ray
Raytracing.at
Raytracing.Camera
Raytracing.fire_ray
Raytracing.ImageTracer
Raytracing.fire_all_rays!
Raytracing.Pigment
Raytracing.BRDF
Raytracing.Material
Raytracing.Shape
Raytracing.Vec2d
Raytracing.HitRecord
Raytracing.PointLight
Raytracing.World
Raytracing.add_shape!
Raytracing.add_light!
Raytracing.PCG
Raytracing.random
Raytracing.create_onb_from_z
Raytracing.scatter_ray
Raytracing.are_close
```
