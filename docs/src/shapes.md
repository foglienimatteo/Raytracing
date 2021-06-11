```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Avaiable shapes

```@index
```

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

## Triangle

```@docs
Raytracing.Triangle
Raytracing.triangle_point_to_uv
Raytracing.triangle_barycenter
Raytracing.triangle_normal
Raytracing.ray_intersection(::Triangle, ::Ray)
```
