# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#



"""
	first_world() :: World

Render the first world (identified with the string "A").

This world consists in a set of 10 spheres of equal radius 0.1:
8 brown spheres are placed at the verteces of a cube of side 1.0, one green-purple 
checked sphere is in the center of the lower cube face and another multi-colored sphere is
in the center of the left cube face.

See also: [`World`](@ref), [`demo`](@ref), [`demo_animation`](@ref)
"""
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

	add_light!(
		world, 
		PointLight(Point(-10.0, 10.0, 10.0), 
		RGB{Float32}(1.0, 1.0, 1.0))
	)

	return world
end


"""
	second_world() :: World

Render the second world (identified with the string "B").

This world consists in a checked x-y plane, a blue opaque 
sphere, a red reflecting sphere, and a green oblique reflecting plane, all
inside a giant emetting sphere.

See also: [`World`](@ref), [`demo`](@ref), [`demo_animation`](@ref)
"""
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
		Material(DiffuseBRDF(UniformPigment(to_RGB(0, 128, 240))))
	mirror_material = 
		Material(SpecularBRDF(UniformPigment(to_RGB(232, 10, 10))))
	mirror_material_2 = 
		Material(SpecularBRDF(UniformPigment(to_RGB(178, 255, 102))))
	
	
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
	add_shape!(
		world, 
		Plane(
			translation(Vec(0., -2., 0)) * rotation_z(π/6.) * rotation_x(π/2.), 
			mirror_material_2,
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

	add_light!(
		world, 
		PointLight(Point(-1.0, 1.0, 1.0), 
		RGB{Float32}(100.0, 100.0, 100.0))
	)

	return world
end


"""
	select_world(type_world::String) ::Function

Select which demo world is used
"""
function select_world(type_world::String)
	(type_world=="A") && (return first_world())
	(type_world=="B") && (return second_world())

	throw(ArgumentError("The input type of world $type does not exists"))
end

##########################################################################################92

function print_progress(row::Int64, col::Int64, height::Int64, width::Int64)
	print("Rendered row $(height - row)/$(height) \t= ")
	@printf "%.2f" 100*((height - row)/height)
	print("%\n")
end

function demo(x::(Pair{T1,T2} where {T1,T2})...)
	demo( parse_demo_settings(  Dict( pair for pair in [x...]) )... )
end

function demo(
		renderer::Renderer = FlatRenderer(),
		camera_type::String = "per",
		camera_position::Union{Point, Vec} = Point(-1.,0.,0.), 
     	α::Float64 = 0., 
     	width::Int64 = 640, 
     	height::Int64 = 480, 
     	pfm_output::String = "demo.pfm", 
        	png_output::String = "demo.png",
		samples_per_pixel::Int64 = 0, 
		world_type::String = "A",
		bool_print::Bool = true,
		bool_savepfm::Bool = true,
    )


	renderer.world = select_world(world_type)

	samples_per_side = string2rootint64(string(samples_per_pixel))

	observer_vec = typeof(camera_position) == Point ?
		camera_position - Point(0., 0., 0.) :
		camera_position

	camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec)
	aspect_ratio = width / height

	if camera_type == "per"
		(bool_print==true) && (println("Using perspective camera"))
		camera = PerspectiveCamera(1., aspect_ratio, camera_tr)
	elseif camera_type == "ort"
		(bool_print==true) && (println("Using orthogonal camera"))
		camera = OrthogonalCamera(aspect_ratio, camera_tr) 
	else
		throw(ArgumentError("Unknown camera: $camera_type"))
	end


	if typeof(renderer) == OnOffRenderer
		(bool_print==true) && (println("Using on/off renderer"))
	elseif typeof(renderer) == FlatRenderer
		(bool_print==true) && (println("Using flat renderer"))
	elseif typeof(renderer) == PathTracer
		(bool_print==true) && (println("Using path tracing renderer"))
	elseif typeof(renderer) == PointLightRenderer
          (bool_print==true) && (println("Using point-light renderer"))
	else
		throw(ArgumentError("Unknown renderer: $(typeof(renderer))"))
	end

	# Run the ray-tracer
	image = HDRimage(width, height)
	tracer = ImageTracer(image, camera, samples_per_side)

	fire_all_rays!(tracer, renderer, (r,c) -> print_progress(r,c,image.height, image.width) )
	img = tracer.img

	# Save the HDR image
	(bool_savepfm==true) && (open(pfm_output, "w") do outf; write(outf, img); end)
	(bool_print==true) && (println("\nHDR demo image written to $(pfm_output)\n"))

	# Apply tone-mapping to the image
	 if typeof(renderer) == OnOffRenderer
		normalize_image!(img, 0.18, nothing)
	elseif typeof(renderer) == FlatRenderer
		normalize_image!(img, 0.18, 0.5)
	elseif typeof(renderer) == PathTracer
		normalize_image!(img, 0.18, 0.1)
	elseif typeof(renderer) == PointLightRenderer
          normalize_image!(img, 0.18, 0.1)
	else
		throw(ArgumentError("Unknown renderer: $(typeof(renderer))"))
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
	demo(
         	renderer::Renderer = FlatRenderer(),
		camera_type::String = "per",
		camera_position::Union{Point, Vec} = Point(-1.,0.,0.), 
     	α::Float64 = 0., 
     	width::Int64 = 640, 
     	height::Int64 = 480, 
     	pfm_output::String = "demo.pfm", 
        	png_output::String = "demo.png",
		samples_per_pixel::Int64 = 0, 
		world_type::String = "A",
		bool_print::Bool = true,
		bool_savepfm::Bool = true,
          )

Creates a demo image with the specified options. 

There are two possible demo image "world" to be rendered, specified through the
input string `type`.

The `type=="A"` demo image world consist in a set of 10 spheres of equal radius 0.1:
8 brown spheres are placed at the verteces of a cube of side 1.0, one green-purple 
checked sphere is in the center of the lower cube face and another multi-colored sphere is
in the center of the left cube face.

The `type=="B"` demo image world consists in a checked x-y plane, a blue opaque 
sphere, a red reflecting sphere, and a green oblique reflecting plane, all
inside a giant emetting sphere.

The creation of the demo image has the objective to check the correct behaviour of
the rendering software, specifically the orientation upside-down and left-right.

## Arguments

- `camera_type::String = "per"` : set the perspective projection view:
		- `camera_type=="per"` -> set [`PerspectiveCamera`](@ref)  (default value)
		- `camera_type=="ort"`  -> set [`OrthogonalCamera`](@ref)

- `camera_position::Point = Point(-1.,0.,0.)` : set the point of observation 
  in (`X`,`Y,`Z`) coordinates

- `renderer::String = "flat"` : renderer to be used in the rendered:
  - `renderer=="onoff"` -> [`OnOffRenderer`](@ref) renderer 
  - `renderer=="flat"` -> [`FlatRenderer`](@ref) renderer (default value)
  - `renderer=="pathtracing"` -> [`PathTracer`](@ref) renderer 
  - `renderer=="pointlight"` -> [`PointLightRenderer`](@ref) renderer

- `α::Float64 = 0.` : angle of rotation _*IN RADIANTS*_, relative to the vertical
  (i.e. z) axis, of the view direction

- `width::Int64 = 640` and `height::Int64 = 480` : pixel dimensions of the demo image

- `pfm_output::String = "demo.pfm"` : name of the output pfm file

- `png_output::String = "demo.png"` : name of the output LDR file

- `bool_print::Bool = true` : specifies if the WIP messages of the demo
  function should be printed or not (useful option for [`demo_animation`](@ref))

- `bool_savepfm::Bool = true` : bool that specifies if the pfm file should be saved
  or not (useful option for [`demo_animation`](@ref))

- `world_type::String = "A"` : specifies the type of world to be rendered ("A", "B" or "C")

- `init_state::Int64 = 45` : initial state of the PCG random number generator

- `init_seq::Int64 = 54` : initial sequence of the PCG random number generator

- `samples_per_pixel::Int64 = 0` : number of rays per pixel to be used (antialiasing)

See also: [`Point`](@ref) ,[`OnOffRenderer`](@ref), [`FlatRenderer`](@ref), 
[`PathTracer`](@ref), [`demo_animation`](@ref)
""" 
demo

##########################################################################################92


function demo_animation(x::(Pair{T1,T2} where {T1,T2})...)
	demo_animation( parse_demoanimation_settings(  Dict( pair for pair in [x...]) )... )
end

function demo_animation(
			renderer::Renderer = FlatRenderer(),
			camera_type::String = "per",
			camera_position::Union{Point, Vec} = Point(-1.,0.,0.), 
        		width::Int64 = 200, 
        		height::Int64 = 150,
       		anim_output::String = "demo-animation.mp4",
			samples_per_pixel::Int64 = 0,
			world_type::String = "A", 
		)

	run(`rm -rf .wip_animation`)
	run(`mkdir .wip_animation`)
	
	dict_gen = Dict(
			"camera_type"=>camera_type,
			"camera_position"=>camera_position,
			"renderer"=>renderer, 
			"width"=>width,
			"height"=>height,
			"samples_per_pixel"=>samples_per_pixel,
			"world_type" => world_type,
			"set_pfm_name"=>".wip_animation/demo.pfm",
			"bool_print"=>false,
			"bool_savepfm"=>false,
			)

	iter = ProgressBar(0:359)
	for angle in iter
		angleNNN = @sprintf "%03d" angle
		dict_spec = Dict(
					"alpha"=>1.0*angle,
					"set_png_name"=>".wip_animation/image$(angleNNN).png"
					)
		demo(parse_demo_settings(merge(dict_gen, dict_spec))...)
		set_description(iter, string(@sprintf("Frame generated: ")))
	end

	# -r 25: Number of frames per second
	run(`ffmpeg -r 25 -f image2 -s $(width)x$(height) -i 
	.wip_animation/image%03d.png -vcodec libx264 
	-pix_fmt yuv420p $(anim_output)`)

	run(`rm -rf .wip_animation`)
end

"""
	demo_animation( 
			renderer::Renderer = FlatRenderer(),
			camera_type::String = "per",
        		width::Int64 = 200, 
        		height::Int64 = 150,
       		anim_output::String = "demo-animation.mp4",
			samples_per_pixel::Int64 = 0,
			world_type::String = "A", 
		)
	
Creates an animation of the demo image with the specified options. It's
necessary to have istalled the ffmpeg software to run this function.

This function works following this steps:
- creates an hidden directory, called ".wip_animation"; if it already exists,
  it will be destroyed and recreated.
- inside ".wpi_animation", creates 360 png images of the demo image (using the 
  [`demo`](@ref) function with the specified projection, renderer and image 
  dims); each image correspons to a frame of the future animation
- through the `ffmpeg` software, the 360 png images are converted into the
  animation mp4 file, and saved in the main directory
- the ".wpi_animation" directory and all the png images inside it are destroyed


## Arguments

- `camera_type::String = "per"` : set the perspective projection view:
		- `camera_type=="per"` -> set [`PerspectiveCamera`](@ref)  (default value)
		- `camera_type=="ort"`  -> set [`OrthogonalCamera`](@ref)
		
- `renderer::String = "flat"` : renderer to be used in the rendered:
  - `renderer=="onoff"` -> [`OnOffRenderer`](@ref) renderer 
  - `renderer=="flat"` -> [`FlatRenderer`](@ref) renderer (default value)
  - `renderer=="pathtracing"` -> [`PathTracer`](@ref) renderer
  - `renderer=="pointlight"` -> [`PointLightRenderer`](@ref) renderer

- `width::Int64 = 640` and `height::Int64 = 480` : pixel dimensions of the demo image

- `world_type::String = "A"` : specifies the type of world to be rendered ("A", "B" or "C")

- `anim_output::String = "demo-animation.mp4"` : name of the output animation file

- `samples_per_pixel::Int64 = 0` : number of rays per pixel to be used (antialiasing)

See also: [`OnOffRenderer`](@ref), [`FlatRenderer`](@ref), 
[`PathTracer`](@ref), [`demo`](@ref)
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
