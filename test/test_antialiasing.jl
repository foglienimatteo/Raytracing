# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

@testset "test_Antialiasing" begin
    num_of_rays = 0
    small_image = HDRimage(1, 1)
    camera = OrthogonalCamera(1.0)
    tracer = ImageTracer(small_image, camera, 10, pcg=PCG())

    function trace_ray(ray::Ray, number_rays::Int64)
        num_of_rays = number_rays
        point = ray.at(1)

        # Check that all the rays intersect the screen within the region [−1, 1] × [−1, 1]
        @test abs(point.x) < 1e-5
        @test -1.0 <= point.y <= 1.0
        @test -1.0 <= point.z <= 1.0

        num_of_rays += 1

        return RGB{Float64}(0.0, 0.0, 0.0)
    end

    fire_all_rays!(tracer, trace_ray)

    # Check that the number of rays that were fired is what we expect (10²)
    @test num_of_rays == 100
end