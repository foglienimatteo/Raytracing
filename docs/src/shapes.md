```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Avaiable shapes

```@index
Pages = ["shapes.md"]
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

## Cube

```@docs
Raytracing.Cube
Raytracing.cube_point_to_uv
Raytracing.cube_normal
Raytracing.ray_intersection(::Cube, ::Ray)
```

## Triangle

```@docs
Raytracing.Triangle
Raytracing.triangle_point_to_uv
Raytracing.triangle_barycenter
Raytracing.triangle_normal
Raytracing.ray_intersection(::Triangle, ::Ray)
```
