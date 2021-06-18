# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni.
#

function render(x::(Pair{T1,T2} where {T1,T2})...)
	render( parse_render_settings(  Dict( pair for pair in [x...]) )... )
end

function render(
          scenefile::String,
          renderer::Renderer = FlatRenderer(),
     	camera_type::Union{String, Nothing} = nothing,
		camera_position::Union{Point, Nothing} = nothing, 
     	α::Float64 = 0., 
     	width::Int64 = 640, 
     	height::Int64 = 480, 
     	pfm_output::String = "scene.pfm", 
        	png_output::String = "scene.png",
		bool_print::Bool = true,
		bool_savepfm::Bool = true,
		samples_per_pixel::Int64 = 0,
          declare_float::Union{Dict{String,Float64}, Nothing} = nothing,
     )

     scene = open(scenefile, "r") do stream
          if isnothing(declare_float)
               inputstream = InputStream(stream)
               parse_scene(inputstream)
          else
               inputstream = InputStream(stream)
               parse_scene(inputstream, declare_float)
          end
     end

     samples_per_side = Int64(floor(√samples_per_pixel))
    (samples_per_side^2 ≈ samples_per_pixel) ||
		throw(ArgumentError(
				"the number of samples per pixel "*
				"$(samples_per_pixel) must be a perfect square")
	)

	renderer.world = scene.world

     if isnothing(camera_type) && isnothing(camera_position) && isnothing(scene.camera) 
          camera = PerspectiveCamera(-1.0, 1.0, rotation_z(deg2rad(α)))

     elseif isnothing(camera_type) && isnothing(camera_position)
          camera = scene.camera 

     elseif isnothing(camera_type) && isnothing(scene.camera) 
          observer_vec = camera_position - Point(0., 0., 0.)
          camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec)
          camera = PerspectiveCamera(-1.0, 1.0, camera_tr)

     elseif isnothing(camera_position) && isnothing(scene.camera) 
          if camera_type == "per"
		     (bool_print==true) && (println("Using perspective camera"))
		     camera = PerspectiveCamera(1., 1.0, rotation_z(deg2rad(α)))
	     elseif camera_type == "ort"
		     (bool_print==true) && (println("Using orthogonal camera"))
		     camera = OrthogonalCamera(1.0, rotation_z(deg2rad(α))) 
	     else
		     throw(ArgumentError("Unknown camera: $camera_type"))
	     end

     elseif isnothing(camera_type)
          observer_vec = camera_position - Point(0., 0., 0.)
          camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec) * scene.camera.T
          if typeof(scene.camera) == OrthogonalCamera
               (bool_print==true) && (println("Using perspective camera"))
               camera = OrthogonalCamera(scene.camera.a, camera_tr)
          elseif typeof(scene.camera) == PerspectiveCamera
               (bool_print==true) && (println("Using orthogonal camera"))
               camera = PerspectiveCamera(scene.camera.d, scene.camera.a, camera_tr)
          else
		     throw(ArgumentError("Unknown camera: $camera_type"))
	     end

     elseif isnothing(camera_position)
          if camera_type == "per"
		     (bool_print==true) && (println("Using perspective camera"))
		     camera = PerspectiveCamera(scene.camera.d, scene.camera.a, rotation_z(deg2rad(α)) * scene.camera.T)
	     elseif camera_type == "ort"
		     (bool_print==true) && (println("Using orthogonal camera"))
		     camera = OrthogonalCamera(scene.camera.a, rotation_z(deg2rad(α)) * scene.camera.T) 
	     else
		     throw(ArgumentError("Unknown camera: $camera_type"))
	     end

     elseif isnothing(scene.camera)
          observer_vec = camera_position - Point(0., 0., 0.)
          camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec)
          if camera_type == "per"
		     (bool_print==true) && (println("Using perspective camera"))
		     camera = PerspectiveCamera(1.0, 1.0, camera_tr)
	     elseif camera_type == "ort"
		     (bool_print==true) && (println("Using orthogonal camera"))
		     camera = OrthogonalCamera(1.0, camera_tr) 
	     else
		     throw(ArgumentError("Unknown camera: $camera_type"))
	     end



     else
          observer_vec = camera_position - Point(0., 0., 0.)
          camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec) * scene.camera.T
          if camera_type == "per"
		     (bool_print==true) && (println("Using perspective camera"))
		     camera = PerspectiveCamera(scene.camera.d, scene.camera.a, camera_tr)
	     elseif camera_type == "ort"
		     (bool_print==true) && (println("Using orthogonal camera"))
		     camera = OrthogonalCamera(scene.camera.a, camera_tr) 
	     else
		     throw(ArgumentError("Unknown camera: $camera_type"))
	     end

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
	
	image = HDRimage(width, height)
	tracer = ImageTracer(image, camera, samples_per_side)

	function print_progress(row::Int64, col::Int64)
     	print("Rendered row $(image.height - row)/$(image.height) \t= ")
		@printf "%.2f" 100*((image.height - row)/image.height)
		print("%\n")
	end

	fire_all_rays!(tracer, renderer, print_progress)
	img = tracer.img

	(bool_savepfm==true) && (open(pfm_output, "w") do outf; write(outf, img); end)
	(bool_print==true) && (println("\nHDR demo image written to $(pfm_output)\n"))

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
