# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.




@testset "test_transformations_basic" begin
     err=1e-11
     A = SMatrix{4,4,Float64}([1.0 2.0 3.0 4.0; 5.0 6.0 7.0 8.0; 9.0 9.0 8.0 7.0; 6.0 5.0 4.0 1.0])
     invA = SMatrix{4,4,Float64}([-3.75  2.75   -1.0 0.0; 4.375  -3.875 2.0  -0.5; 0.5    0.5    -1.0 1.0; -1.375 0.875   0.0 -0.5])
     B = SMatrix{4,4,Float64}([3.0 5.0 2.0 4.0; 4.0 1.0 0.0 5.0; 6.0 3.0 2.0 0.0; 1.0 4.0 2.0 1.0])
     invB = SMatrix{4,4,Float64}([0.4 -0.2 0.2 -0.6; 2.9 -1.7 0.2 -3.1; -5.55 3.15 -0.4 6.45; -0.9 0.7 -0.2 1.1])
     C = SMatrix{4,4,Float64}([1.0 2.0 3.0 4.0; 5.0 6.0 7.0 8.0; 9.0 9.0 8.0 7.0; 0.0 0.0 0.0 1.0])
     invC = SMatrix{4,4,Float64}([-3.75 2.75 -1 0; 5.75 -4.75 2.0 1.0; -2.25 2.25 -1.0 -2.0; 0.0 0.0 0.0 1.0])
     D = SMatrix{4,4,Float64}([33.0 32.0 16.0 18.0; 89.0 84.0 40.0 58.0; 118.0 106.0 48.0 88.0; 63.0 51.0 22.0 50.0])
     invD = SMatrix{4,4,Float64}([-1.45 1.45 -1.0 0.6; -13.95 11.95 -6.5 2.6; 25.525 -22.025 12.25 -5.2; 4.825 -4.325 2.5 -1.1])
     
     m1 = Transformation(A, invA)
     m2 = Transformation(B, invB)
     m = Transformation(C, invC)
     exp = Transformation(D, invD)

     exp_v = Vec(14.0, 38.0, 51.0+err)
     exp_p = Point(18.0, 46.0, 58.0-2*err)
     exp_n = Normal(-8.75, 7.75+6*err, -3.0)

     # is_consistent for manual definition of Transformation
     @test Raytracing.is_consistent(m1)
     @test Raytracing.is_consistent(m2)
     @test Raytracing.is_consistent(m)
     @test Raytracing.is_consistent(exp)

     # approx for multiplications with Transformation
     @test exp ≈ (m1 * m2)
     @test exp_v ≈ (m * Vec(1.0, 2.0, 3.0))
     @test exp_p ≈ (m * Point(1.0, 2.0, 3.0))
     @test exp_n ≈ (m * Normal(3.0, 2.0, 4.0))

end

@testset "test_transformations_rotations" begin
     err = 1e-11
     @test Raytracing.is_consistent(rotation_x(0.1))
     @test Raytracing.is_consistent(rotation_y(0.1))
     @test Raytracing.is_consistent(rotation_z(0.1))
     @test (rotation_x(π/2) * Vec(0.0, 1.0, 0.0+3*err)) ≈ (Vec(0.0, 0.0, 1.0))
     @test (rotation_y(π/2) * Vec(0.0, 0.0-2*err, 1.0)) ≈ (Vec(1.0, 0.0, 0.0))
     @test (rotation_z(π/2) * Vec(1.0+err, 0.0, 0.0)) ≈ (Vec(0.0, 1.0, 0.0))
end

@testset "test_transformations_scaling" begin
     err = 1e-11
     tr1 = scaling(Vec(2.0, 5.0, 10.0+err))
     tr2 = scaling(Vec(3.0, 2.0, 4.0))
     exp = scaling(Vec(6.0, 10.0, 40.0))

     @test Raytracing.is_consistent(tr1)
     @test Raytracing.is_consistent(tr2)
     @test exp ≈ (tr1 * tr2)
end

@testset "test_transformations_translation" begin
     err=1e-11
     tr1 = translation(Vec(1.0, 2.0, 3.0))
     tr2 = translation(Vec(4.0, 6.0, 8.0))
     prd = tr1 * tr2
     exp = translation(Vec(5.0, 8.0, 11.0-7*err))
     
     @test Raytracing.is_consistent(tr1)
     @test Raytracing.is_consistent(tr2)
     @test Raytracing.is_consistent(prd)
     @test prd ≈ exp
end

@testset "test_transformations_inverse" begin
     A = SMatrix{4,4,Float64}([1.0 2.0 3.0 4.0 ; 5.0 6.0 7.0 8.0 ; 9.0 9.0 8.0 7.0 ; 6.0 5.0 4.0 1.0])
     invA = SMatrix{4,4,Float64}([-3.75 2.75 -1 0 ; 4.375 -3.875 2.0 -0.5 ; 0.5 0.5 -1.0 1.0 ; -1.375 0.875 0.0 -0.5])
     m1 = Transformation(A, invA)
     m2 = inverse(m1)

     @test Raytracing.is_consistent(m2)
     @test Raytracing.is_consistent(m1*m2)
     @test m1*m2 ≈ Transformation()

end
