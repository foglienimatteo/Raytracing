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


##########################################################################################92

demo() = demo(true, 0., 640, 480, "demo.pfm", "demo.png")
demo(ort::Bool) = demo(ort, 0., 640, 480, "demo.pfm", "demo.png")
demo(ort::Bool, α::Float64) = demo(ort, α, 640, 480, "demo.pfm", "demo.png")
demo(w::Int64, h::Int64) = demo(true, 0., w, h, "demo.pfm", "demo.png")
function demo(
          orthogonal::Bool,
          α::Float64, 
          width::Int64, 
          height::Int64, 
          pfm_output::String="demo.pfm", 
          png_output::String="demo.png"
          )
     
	image = HDRimage(width, height)

	# Create a world and populate it with a few shapes
	world = World()

	for x in [-0.5, 0.5], y in [-0.5, 0.5], z in [-0.5, 0.5]
		add_shape(world, Sphere( translation(Vec(x, y, z)) * scaling(Vec(0.1, 0.1, 0.1)) ))
	end

	# Place two other balls in the bottom/left part of the cube, so
	# that we can check if there are issues with the orientation of
	# the image
	add_shape(world, Sphere( translation(Vec(0.0, 0.0, -0.5)) * scaling(Vec(0.1, 0.1, 0.1)) ))
	add_shape(world, Sphere( translation(Vec(0.0, 0.5, 0.0)) * scaling(Vec(0.1, 0.1, 0.1)) ))

	# Initialize a camera
	camera_tr = rotation_z(deg2rad(α)) * translation(Vec(-1.0, 0.0, 0.0))
	if orthogonal==true
		camera = OrthogonalCamera(width / height, camera_tr)
	else
		camera = PerspectiveCamera(1., width / height, camera_tr)
	end


	# Run the ray-tracer
	tracer = ImageTracer(image, camera)
	function compute_color(ray::Ray)
		if ray_intersection(world,ray) ≠ nothing
			return WHITE
		else
			return BLACK
		end
	end

	fire_all_rays!(tracer, compute_color)
	img = tracer.img

	# Save the HDR image
	open(pfm_output, "w") do outf
		write(outf, img)
	end

	println("\nHDR demo image written to $(pfm_output)\n")

	# Apply tone-mapping to the image
	normalize_image!(img, 0.18)
	clamp_image!(img)
	γ_correction!(img, 1.27)

	#println(img, 3)

	# Save the LDR image
	Images.save(png_output, get_matrix(img))

	println("\nHDR demo image written to $(png_output)\n")
end
