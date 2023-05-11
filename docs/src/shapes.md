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

## Cube

```@docs
Raytracing.Cube
Raytracing.cube_point_to_uv
Raytracing.cube_normal
Raytracing.ray_intersection(::Cube, ::Ray)
```

## Axis-Aligned Bounding Box

```@docs
Raytracing.AABB
Raytracing.ray_intersection(::AABB, ::Ray)
```

## Triangle

```@docs
Raytracing.Triangle
Raytracing.triangle_point_to_uv
Raytracing.triangle_barycenter
Raytracing.triangle_normal
Raytracing.ray_intersection(::Triangle, ::Ray)
```
