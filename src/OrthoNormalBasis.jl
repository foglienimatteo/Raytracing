# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni

"""
Create an orthonormal base with the z-axes parallel to the normal of the surface
"""
function create_onb_from_z(normal::Union{Vec, Normal})
    (typeof(normal) == Vec) && (normal = Normal(normal))

    s = copysign(1, normal.z)
    a = -1.0/(s + normal.z)
    b = normal.x * normal.y * a

    e1 = Normal(1.0 + s * normal.x^2 * a, s * b, -s * normal.x)
    e2 = Normal(b, sign + normal.y^2 * a, -normal.y)

    return e1, e2, Normal(normal.x, normal.y, normal.z)
end
