# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

@testset "test_OrthoNormalBasis" begin
    pcg = PCG()

    for i in 1:100000
        normal = Normal(random(pcg), random(pcg), random(pcg))
        e1, e2, e3 = create_onb_from_z(normal)

        @test e3 ≈ normal # z axis must be aligned with the normal
        
        # testing orthogonality
        @test are_close(e1 ⋅ e2, 0.)
        @test are_close(e1 ⋅ e3, 0.)
        @test are_close(e3 ⋅ e2, 0.)
        
        # testing normality
        @test are_close(squared_norm(e1), 1.)
        @test are_close(squared_norm(e2), 1.)
        @test are_close(squared_norm(e3), 1.)
    end
end