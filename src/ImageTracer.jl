"""Returns the position of a ::Point along a direction defined by a ::Vec at a given t."""
at(r::Ray, t::Float64) = r.origin + r.dir * t

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
function fire_ray(Ocam::OrthogonalCamera, u, v)
    origin = Point(-1.0, (1.0 - 2 * u) * Ocam.a, 2 * v - 1)
    direction = Vec(1.0, 0.0, 0.0)
    return Ocam.T*Ray(origin, direction, 1.0)
end

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
function fire_ray(Pcam::PerspectiveCamera, u, v)
    origin = Point(-Pcam.d, 0.0, 0.0)
    direction = Vec(Pcam.d, (1.0 - 2 * u) * Pcam.a, 2 * v - 1)
    return Pcam.T*Ray(origin, direction, 1.0)
end

"""Give a ::Ray that goes through a pixel (you can set a position "inside" the pixel, as default it's in its center)"""
function fire_ray(ImTr::ImageTracer, col::Int64, row::Int64, u_px::Float64=0.5, v_px::Float64=0.5)
    u = (col + u_px) / (ImTr.img.width - 1)
    v = (row + v_px) / (ImTr.img.height - 1)
    return fire_ray(ImTr.cam, u, v)
end # fire_ray


function fire_all_rays!(ImTr::ImageTracer, func::Function)
    for row in ImTr.img.height-1:-1:0, col in 0:ImTr.img.width-1
        ray = fire_ray(ImTr, col, row)
        color::RGB = func(ray)
        set_pixel(ImTr.img, col, row, color)
    end
    nothing
end
