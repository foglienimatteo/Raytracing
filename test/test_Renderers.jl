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



@testset "test_OnOffRenderer" begin
     sphere = Sphere(translation(Vec(2, 0, 0)) * scaling(Vec(0.2, 0.2, 0.2)),
                    Material(DiffuseBRDF(UniformPigment(WHITE))))
     image = HDRimage(3, 3)
     camera = OrthogonalCamera()
     tracer = ImageTracer(image,camera)
     world = World()
     add(world, sphere)
     renderer = OnOffRenderer(world)
     fire_all_rays!(tracer, renderer)

     @test get_pixel(image, 0, 0) ≈ BLACK
     @test get_pixel(image, 1, 0) ≈ BLACK
     @test get_pixel(image, 2, 0) ≈ BLACK

     @test get_pixel(image, 0, 1) ≈ BLACK
     @test get_pixel(image, 1, 1) ≈ WHITE
     @test get_pixel(image, 2, 1) ≈ BLACK

     @test get_pixel(image, 0, 2) ≈ BLACK
     @test get_pixel(image, 1, 2) ≈ BLACK
     @test get_pixel(image, 2, 2) ≈ BLACK
end

@testset "test_FlatRenderer" begin
     sphere_color = RGB(1.0, 2.0, 3.0)
     sphere = Sphere(translation(Vec(2, 0, 0)) * scaling(Vec(0.2, 0.2, 0.2)),
                    Material(DiffuseBRDF(UniformPigment(sphere_color))))
     image = HDRimage(3, 3)
     camera = OrthogonalCamera()
     tracer = ImageTracer(image, camera)
     world = World()
     add(world, sphere)
     renderer = FlatRenderer(world)
     fire_all_rays!(tracer, renderer)

     @test get_pixel(image, 0, 0) ≈ BLACK
     @test get_pixel(image, 1, 0) ≈ BLACK
     @test get_pixel(image, 2, 0) ≈ BLACK

     @test get_pixel(image, 0, 1) ≈ BLACK
     @test get_pixel(image, 1, 1) ≈ sphere_color
     @test get_pixel(image, 2, 1) ≈ BLACK

     @test get_pixel(image, 0, 2) ≈ BLACK
     @test get_pixel(image, 1, 2) ≈ BLACK
     @test get_pixel(image, 2, 2) ≈ BLACK
end