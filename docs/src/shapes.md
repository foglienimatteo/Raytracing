```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Avaiable shapes

## Sphere

```@docs
Sphere
sphere_point_to_uv
sphere_normal
ray_intersection(sphere::Sphere, ray::Ray)
```


## Plane

```@docs
Plane
plane_point_to_uv
plane_normal
ray_intersection(plane::Plane, ray::Ray)
```
