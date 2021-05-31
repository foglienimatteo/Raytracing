# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#




function first_world()
	material1 = Material(DiffuseBRDF(UniformPigment(RGB(0.7, 0.3, 0.2))))
    	material2 = Material(DiffuseBRDF(CheckeredPigment(RGB(0.2, 0.7, 0.3), 
	    											  RGB(0.3, 0.2, 0.7), 
									                  4) )	)

	sphere_texture = HDRimage(2, 2)
	set_pixel(sphere_texture, 0, 0, RGB(0.1, 0.2, 0.3))
    	set_pixel(sphere_texture, 0, 1, RGB(0.2, 0.1, 0.3))
	set_pixel(sphere_texture, 1, 0, RGB(0.3, 0.2, 0.1))
    	set_pixel(sphere_texture, 1, 1, RGB(0.3, 0.1, 0.2))

	material3 = Material(DiffuseBRDF(ImagePigment(sphere_texture)))

	# Create a world and populate it with a few shapes
	world = World()
	for x in [-0.5, 0.5], y in [-0.5, 0.5], z in [-0.5, 0.5]
		add_shape!(world,
				Sphere( 
					translation(Vec(x, y, z)) * scaling(Vec(0.1, 0.1, 0.1)),
					material1
				)
		)
	end

	# Place two other balls in the bottom/left part of the cube, so
	# that we can check if there are issues with the orientation of
	# the image
	add_shape!(
		world, 
		Sphere( 
			translation(Vec(0.0, 0.0, -0.5)) * scaling(Vec(0.1, 0.1, 0.1)),
			material2
		)
	)
	add_shape!(
		world, 
		Sphere( 
			translation(Vec(0.0, 0.5, 0.0)) * scaling(Vec(0.1, 0.1, 0.1)),
			material3
		)
	)

	return world
end

function second_world()
	world = World()

	sky_material = 
		Material(
			DiffuseBRDF(UniformPigment(RGB{Float32}(0., 0., 0.))),
			UniformPigment(RGB{Float32}(1.0, 0.9, 0.5)),
		)

	ground_material = 
		Material(
			DiffuseBRDF(
				CheckeredPigment(
					RGB{Float32}(0.3, 0.5, 0.1),
					RGB{Float32}(0.1, 0.2, 0.5),
				)
			)
		)

	sphere_material = 
		Material(DiffuseBRDF(UniformPigment(RGB{Float32}(0.3, 0.4, 0.8))))
	mirror_material = 
		Material(SpecularBRDF(UniformPigment(RGB{Float32}(0.6, 0.2, 0.3))))
	
	
	add_shape!(
		world,
		Sphere(
			scaling(Vec(50, 50, 50)) * translation(Vec(0, 0, 0)),
			sky_material,
		)
	)
	
	add_shape!(
		world, 
		Plane(
			Transformation(), 
			ground_material,
		)
	)

	s1, s2 = 0.6, 1.0
	add_shape!(
		world,
		Sphere(
			translation(Vec(0, 0, 0.3)) * scaling(Vec(s1, s1, s1)),
			sphere_material,
		)
	)
	add_shape!(
		world,
		Sphere(
			translation(Vec(0.4, 1.5, 0)) * scaling(Vec(s2, s2, s2)),
			mirror_material,
		)
	)

	return world
end

function select_world(type::String)
	(type=="A") && (return first_world())
	(type=="B") && (return second_world())

	throw(ArgumentError("The input type of world $type does not exists"))
end

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
		bool_savepfm::Bool=true,
		type::String = "A",
		obs::Point = Point(-1., 0., 0.)
          )

	world = select_world(type)

	# Initialize a camera
	observer_vec = Point(0., 0., 0.) - obs
	camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec)
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
	elseif algorithm == "pathtracing"
		(bool_print==true) && (println("Using path tracing renderer"))
		renderer = PathTracer(world, BLACK, PCG(), 10, 2, 3)
	else
		throw(ArgumentError("Unknown renderer: $algorithm"))
	end

	fire_all_rays!(tracer, renderer)
	img = tracer.img

	# Save the HDR image
	(bool_savepfm==true) && (open(pfm_output, "w") do outf; write(outf, img); end)
	(bool_print==true) && (println("\nHDR demo image written to $(pfm_output)\n"))

	# Apply tone-mapping to the image
	if algorithm == "onoff"
		normalize_image!(img, 0.18, nothing)
	elseif algorithm == "flat"
		normalize_image!(img, 0.18, 0.1)
	elseif algorithm == "pathtracing"
		normalize_image!(img, 0.18, 0.1)
	end
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
	nothing
end


"""
	function demo(
          orthogonal::Bool, algorithm::String,
          α::Float64, 
          width::Int64, height::Int64, 
          pfm_output::String, png_output::String,
		bool_print::Bool=true, bool_savepfm::Bool=true
		type::String = "A"
          ) 

Creates a demo image with the specified options. 

There are two possible demo image "world" to be rendered, specified through the
input string `type`.

The `type=="A"` demo image world consist in a set of 10 spheres of equal radius 0.1:
8 spheres are placed at the verteces of a cube of side 1.0, one in the center of
the lower cube face and the last one in the center of the left cube face.

The creation of the demo image has the objective to check the correct behaviour of
the rendering software, specifically the orientation upside-down and left-right.

## Arguments

- `orthogonal::Bool` : bool variable tha set the perspective projection view:
		- `orthogonal==false` -> set [`PerspectiveCamera`](@ref)  (default value)
		- `orthogonal==true`  -> set [`OrthogonalCamera`](@ref)

- `algorithm::String` : string specifing the algorithm to be used in the rendered
  demo image prova:
		- `algorithm==onoff` -> [`OnOffRenderer`](@ref) algorithm (default value)
		- `algorithm==flat` -> [`FlatRenderer`](@ref) algorithm 

- `α::Float64` : angle of rotation _*IN RADIANTS*_, relative to the vertical
  (i.e. z) axis, of the view direction

- `width::Int64` and `height::Int64` : pixel dimensions of the demo image

- `pfm_output::String` : name of the output pfm file; default is `demo.pfm`

- `png_output::String` : name of the output ldr file; default is `demo.png`

- `bool_print::Bool=true` : bool that specifies if the WIP messages of the demo
  function should be printed or not (useful option for [`demo_animation`](@ref))

- `bool_savepfm::Bool=true` : bool that specifies if the pfm file should be saved
  or not (useful option for [`demo_animation`](@ref))

- `type::String="A"` : specifies the type of world to be rendered ("A" or "B")

See also: [`OnOffRenderer`](@ref), [`FlatRenderer`](@ref), [`demo_animation`](@ref)
""" 
demo

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

"""
	function demo_animation( 
				ort::Bool,
				algorithm::String,
        			width::Int64, 
        			height::Int64, 
       			anim_output::String
			)
	
Creates an animation of the demo image with the specified options. It's
necessary to have istalled the ffmpeg software to run this function.

This function works following this steps:
- creates an hidden directory, called ".wip_animation"; if it already exists,
  it will be destroyed and recreated.
- inside ".wpi_animation", creates 360 png images of the demo image (using the 
  [`demo`](@ref) function with the specified projection, algorithm and image 
  dims); each image correspons to a frame of the future animation
- through the `ffmpeg` software, the 360 png images are converted into the
  animation mp4 file, and saved in the main directory
- the ".wpi_animation" directory and all the png images inside it are destroyed


## Arguments

- `ort::Bool` : bool variable tha set the perspective projection view:
		- `ort==false` -> set [`PerspectiveCamera`](@ref)  (default value)
		- `ort==true`  -> set [`OrthogonalCamera`](@ref)

- `algorithm::String` : string specifing the algorithm to be used in the rendered
  demo image prova:
		- `algorithm==onoff` -> [`OnOffRenderer`](@ref) algorithm (default value)
		- `algorithm==flat` -> [`FlatRenderer`](@ref) algorithm
		
- `width::Int64` and `height::Int64` : pixel dimensions of the demo animation

- `pfm_output::String` : name of the output animation file; default is "demo-animation.mp4"

See also: [`OnOffRenderer`](@ref), [`FlatRenderer`](@ref), [`demo`](@ref)
"""
demo_animation
#=
for angle in $(seq 0 359); do
    angleNNN=$(printf "%03d" $angle)
    ./main demo --per --width=640 --height=480 --alpha=$angle --set-png-name="animazione/image${angleNNN}.png"
done

# -r 25: Number of frames per second
ffmpeg -r 25 -f image2 -s 50x30 -i animazione/image%03d.png \
    -vcodec libx264 -pix_fmt yuv420p \
    spheres-perspective.mp4

ffmpeg -i demo/demo_anim_Flat_640x480x360.mp4 -t 14 
	-pix_fmt rgb24 demo/demo_anim_Flat_640x480x360.gif
=#
