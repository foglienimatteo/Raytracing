# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

"""
    create_onb_from_z(normal::Union{Vec, Normal}) :: (Normal, Normal, Normal)

Return an orthonormal base of 3 `Normal`s with the z-axes 
(i.e. the third `Normal` returned) parallel to the 
input `Vec`/ `Normal`.

The implementation of this function is based on the paper
of Duff et al. (2017), which improved the already efficient
work made by Frisvad (2012).

## References

- Duff et al. (2017), ["Building an Orthonormal Basis, 
  Revisited"](https://graphics.pixar.com/library/OrthonormalB/paper.pdf)

- Frisvad (2012), ["Building an Orthonormal Basis from a 3D 
  Unit Vector Without Normalization"](https://backend.orbit.dtu.dk/ws/portalfiles/portal/126824972/onb_frisvad_jgt2012_v2.pdf)

See also: [`Vec`](@ref), [`Normal`](@ref)
"""
function create_onb_from_z(normal::Union{Vec, Normal})
    (typeof(normal) == Vec) && (normal = Normal(normal))

    s = copysign(1, normal.v[3])
    a = -1.0/(s + normal.v[3])
    b = normal.v[1] * normal.v[2] * a

    e1 = Normal(1.0 + s * normal.v[1]^2 * a, s * b, -s * normal.v[1])
    e2 = Normal(b, s + normal.v[2]^2 * a, -normal.v[2])

    return e1, e2, Normal(normal.v[1], normal.v[2], normal.v[3])
end
