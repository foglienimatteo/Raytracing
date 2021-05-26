# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni

function create_onb_from_z(normal::Union{Vec, Normal})
    (typeof(normal) == Vec) && (normal = Normal(normal))

    s = copysign(1, normal.z)
    a = -1.0/(s + normal.z)
    b = normal.x * normal.y * a

    e1 = Vec(1.0 + s * normal.x^2 * a, s * b, -s * normalx)
    e2 = Vec(b, sign + normal.y * normal.y * a, -normal.y)

    return e1, e2, Vec(normal.x, normal.y, normal.z)
end