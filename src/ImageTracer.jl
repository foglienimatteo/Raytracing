at(r::Ray, t::Float64) = r.origin + r.dir * t

function fire_ray(ImTr::ImageTracer, col::Int64, row::Int64, u_px::Float64=0.5, v_px::Float64=0.5)
    u = (col + u_px) / (ImTr.img.width - 1)
    v = (row + v_px) / (ImTr.img.height - 1)
    return ImTr.cam.fire_ray(u, v)
end # fire_ray

function fire_ray(cam::Camera, u::Float64, v::Float64)
    """Shoot a ray through the camera's screen
        The coordinates (u, v) specify the point on the screen where the ray crosses it. Coordinates (0, 0) represent
        the bottom-left corner, (0, 1) the top-left corner, (1, 0) the bottom-right corner, and (1, 1) the top-right
        corner, as in the following diagram::
            (0, 1)                          (1, 1)
               +------------------------------+
               |                              |
               |                              |
               |                              |
               +------------------------------+
            (0, 0)                          (1, 0)
        """
        origin = Point(-1.0, (1.0 - 2 * u) * cam.a, 2 * v - 1)
        direction = VEC_X
        return cam.T * Ray(origin, direction, 1.0) # OrthogonalCamera
end