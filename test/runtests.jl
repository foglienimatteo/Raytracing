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

using Raytracing, Raytracing.Interpreter
using Test
using StaticArrays
using LinearAlgebra
import ColorTypes:RGB


##########################################################################################92


@testset "test_RGB" begin
	include("test_RGB.jl")
end

@testset "test_HDRimage" begin
	include("test_HDRimage.jl")
end

# @testset "test_ReadingWriting" begin
# 	include("test_ReadingWriting.jl")
# end


@testset "test_ToneMapping" begin
	include("test_ToneMapping.jl")
end


##########################################################################################92


@testset "test_Geometry" begin
	include("test_Geometry.jl")
end

@testset "test_Transformation" begin
	include("test_Transformation.jl")
end

@testset "test_Rays-Cameras-ImageTracer" begin
	include("test_Rays-Cameras-ImageTracer.jl")

end


##########################################################################################92

@testset "test_AABB" begin
	include("test_AABB.jl")
end

@testset "test_Sphere" begin
	include("test_Sphere.jl")
end

@testset "test_Plane" begin
	include("test_Plane.jl")
end

@testset "test_Cube" begin
	include("test_Cube.jl")
end

@testset "test_Triangle" begin
	include("test_Triangle.jl")
end

@testset "test_Torus" begin
	include("test_Torus.jl")
end

@testset "test_Shapes-World" begin
	include("test_Shapes-World.jl")
end


##########################################################################################92


@testset "test_Pigment" begin
	include("test_Pigment.jl")
end

@testset "test_Renderers" begin
	include("test_Renderers.jl")
end

@testset "test_PCG" begin
	include("test_PCG.jl")
end

@testset "test_OrthoNormalBasis" begin
	include("test_OrthoNormalBasis.jl")
end

@testset "test_Antialiasing" begin
	include("test_antialiasing.jl")
end

##########################################################################################92

@testset "test_RangeTesters" begin
	include("test_RangeTesters.jl")
end

@testset "test_Interpreter" begin
	include("test_Interpreter.jl")
end

@testset "test_Demo-DemoAnimation.jl" begin
	include("test_Demo-DemoAnimation.jl")
end

@testset "test_Render-RenderAnimation.jl" begin
	include("test_Render-RenderAnimation.jl")
end

@testset "test_Raytracer.jl" begin
	include("test_Raytracer.jl")
end
