```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Avaiable shapes

```@docs
ray_intersection(::Shape, ::Ray)
ray_intersection(::World, ::Ray)
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

## Torus

```@docs
Raytracing.Torus
Raytracing.torus_point_to_uv
Raytracing.torus_normal
Raytracing.ray_intersection(::Torus, ::Ray)
```
