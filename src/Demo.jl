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


demo() = demo(false, "onoff", 0., 640, 480, "demo.pfm", "demo.png")
demo(ort::Bool) = demo(ort, "onoff", 0., 640, 480, "demo.pfm", "demo.png")
demo(al::String) = demo(false, al, 0., 640, 480, "demo.pfm", "demo.png")
demo(ort::Bool, al::String) = demo(ort, al, 0., 640, 480, "demo.pfm", "demo.png")
demo(ort::Bool, α::Float64) = demo(ort, "onoff", α, 640, 480, "demo.pfm", "demo.png")
demo(w::Int64, h::Int64) = demo(false, "onoff", 0., w, h, "demo.pfm", "demo.png")

function demo(
          orthogonal::Bool,
		algorithm::String,
          α::Float64, 
          width::Int64, 
          height::Int64, 
          pfm_output::String, 
          png_output::String,
		bool_print::Bool=true,
		bool_savepfm::Bool=true
          )

	material1 = Material(DiffuseBRDF(UniformPigment(RGB(0.7, 0.3, 0.2))))
    	material2 = Material(DiffuseBRDF(	CheckeredPigment(
		    							RGB(0.2, 0.7, 0.3), 
	    								RGB(0.3, 0.2, 0.7), 
									4
								)
						)
				)

	sphere_texture = HDRimage(2, 2)
	set_pixel(sphere_texture, 0, 0, RGB(0.1, 0.2, 0.3))
    	set_pixel(sphere_texture, 0, 1, RGB(0.2, 0.1, 0.3))
	set_pixel(sphere_texture, 1, 0, RGB(0.3, 0.2, 0.1))
    	set_pixel(sphere_texture, 1, 1, RGB(0.3, 0.1, 0.2))

	material3 = Material(DiffuseBRDF(ImagePigment(sphere_texture)))

	# Create a world and populate it with a few shapes
	world = World()
	for x in [-0.5, 0.5], y in [-0.5, 0.5], z in [-0.5, 0.5]
		add_shape(world,
				Sphere( 
					translation(Vec(x, y, z)) * scaling(Vec(0.1, 0.1, 0.1)),
					material1
				)
		)
	end

	# Place two other balls in the bottom/left part of the cube, so
	# that we can check if there are issues with the orientation of
	# the image
	add_shape(
		world, 
		Sphere( 
			translation(Vec(0.0, 0.0, -0.5)) * scaling(Vec(0.1, 0.1, 0.1)),
			material2
		)
	)
	add_shape(
		world, 
		Sphere( 
			translation(Vec(0.0, 0.5, 0.0)) * scaling(Vec(0.1, 0.1, 0.1)),
			material3
		)
	)

	# Initialize a camera
	camera_tr = rotation_z(deg2rad(α)) * translation(Vec(-1.0, 0.0, 0.0))
	aspect_ratio = width / height
	camera = orthogonal==true ? 
			OrthogonalCamera(aspect_ratio, camera_tr) :
			PerspectiveCamera(1., aspect_ratio, camera_tr)


	
	# Run the ray-tracer
	image = HDRimage(width, height)
	tracer = ImageTracer(image, camera)

	if algorithm == "onoff"
		(bool_print==true) && (println("Using on/off renderer"))
		renderer = OnOffRenderer(world, BLACK)
	elseif algorithm == "flat"
		(bool_print==true) && (println("Using flat renderer"))
		renderer = FlatRenderer(world, BLACK)
	else
		throw(ArgumentError("Unknown renderer: $algorithm"))
	end

	compute_color(ray::Ray) = call(renderer, ray) 
	fire_all_rays!(tracer, compute_color)
	img = tracer.img
	#print_not_black(img)

	# Save the HDR image
	(bool_savepfm==true) && (open(pfm_output, "w") do outf; write(outf, img); end)
	(bool_print==true) && (println("\nHDR demo image written to $(pfm_output)\n"))

	# Apply tone-mapping to the image
	normalize_image!(img, 0.18)
	clamp_image!(img)
	γ_correction!(img, 1.27)

	# Save the LDR image
	if (typeof(query(png_output)) == File{DataFormat{:UNKNOWN}, String})
		(bool_print==true) && (
			println(
				"File{DataFormat{:UNKNOWN}, String} for $(png_output)\n"*
				"Written as a .png file.\n"
			)
		)
     	Images.save(File{format"PNG"}(png_output), get_matrix(img))
	else
		Images.save(png_output, get_matrix(img))
	end

	(bool_print==true) && (println("\nHDR demo image written to $(png_output)\n"))
end

##########################################################################################92

demo_animation() = demo_animation(false, "onoff", 200, 150, "demo-animation.mp4")
demo_animation(ort::Bool) = demo_animation(ort, "onoff", 200, 150, "demo-animation.mp4")
demo_animation(al::String) = demo_animation(false, al, 200, 150, "demo-animation.mp4")
demo_animation(ort::Bool, al::String) = 
					demo_animation(ort, al, 200, 150, "demo-animation.mp4")
demo_animation(al::String, w::Int64, h::Int64) = 
					demo_animation(false, al, w, h, "demo-animation.mp4")
demo_animation(ort::Bool, al::String, w::Float64, h::Float64) = 
					demo_animation(ort, al, w, h, "demo-animation.mp4")

function demo_animation( 
			ort::Bool,
			algorithm::String,
        		width::Int64, 
        		height::Int64, 
       		anim_output::String
		)
	run(`rm -rf .wip_animation`)
	run(`mkdir .wip_animation`)
	
	iter = ProgressBar(0:359)
	for angle in iter
		angleNNN = @sprintf "%03d" angle
		demo(ort, algorithm, 1.0*angle, width, height, ".wip_animation/demo.pfm",
				".wip_animation/image$(angleNNN).png", false, false)
		set_description(iter, string(@sprintf("Frame generated: ")))
	end

	# -r 25: Number of frames per second
	name = anim_output
	run(`ffmpeg -r 25 -f image2 -s $(width)x$(height) -i 
	.wip_animation/image%03d.png -vcodec libx264 
	-pix_fmt yuv420p $(name)`)

	run(`rm -rf .wip_animation`)
end

#=
for angle in $(seq 0 359); do
    angleNNN=$(printf "%03d" $angle)
    ./main demo --per --width=640 --height=480 --alpha=$angle --set-png-name="animazione/image${angleNNN}.png"
done

# -r 25: Number of frames per second
ffmpeg -r 25 -f image2 -s 50x30 -i animazione/image%03d.png \
    -vcodec libx264 -pix_fmt yuv420p \
    spheres-perspective.mp4
=#
