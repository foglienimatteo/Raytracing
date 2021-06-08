```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Avaiable shapes

## Sphere

```@docs
Raytracing.Sphere
Raytracing.sphere_point_to_uv
Raytracing.sphere_normal
Raytracing.ray_intersection(::Sphere, ::Ray)
```


## Plane

```@docs
Raytracing.Plane
Raytracing.plane_point_to_uv
Raytracing.plane_normal
Raytracing.ray_intersection(::Plane, ::Ray)
```
