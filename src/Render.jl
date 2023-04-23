# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni.
#

function print_JSON_render(
     png_output::String,
     pfm_output::Union{String, Nothing},
     scenefile::String,
     time_of_start::String,
     algorithm::Renderer,
     camera::Camera,
     α::Float64, 
     width::Int64, 
	height::Int64, 
     samples_per_side::Int64,
     declare_float::Union{Dict, Nothing},
     rendering_time_s::Float64,
     a::Float64,
     γ::Float64,
     lum::Union{Number, Nothing},
     )

     dict_camera = if typeof(camera) == OrthogonalCamera
               Dict(
                    "projection" => "ort", #"orthogonal",
                    "aspect_ratio" => camera.a,
                    "transformation" => camera.T.M,
               )

          elseif typeof(camera) == PerspectiveCamera
               Dict(
                    "projection" => "per", # "perspective",     #MODIFIED
                    "distance" => camera.d,
                    "aspect ratio" => camera.a,
                    "transformation" => camera.T.M,
               )
          end

     dict_renderer = if typeof(algorithm) == OnOffRenderer
              Dict(
                    "algorithm" => "On-Off Renderer",
                    "background color" => algorithm.background_color,
                    "color" => algorithm.color,
               )

          elseif typeof(algorithm) == FlatRenderer
              Dict(
                    "algorithm" => "Flat Renderer",
                    "background color" => algorithm.background_color,
               )
          elseif typeof(algorithm) == PathTracer
              Dict(
                    "algorithm" => "Path-Tracing Renderer",
                    "background color" => algorithm.background_color,
                    "PCG" => Dict(
                         "initial state" => get_state(algorithm.pcg),
                         "initial sequence" => get_inc(algorithm.pcg),
                         ),
                    "number of rays" => algorithm.num_of_rays,
                    "max depth" => algorithm.max_depth,
                    "russian roulette limit" => algorithm.russian_roulette_limit,
               )
          elseif typeof(algorithm) == PointLightRenderer
               Dict(
                    "algorithm" => "Point-Light Renderer",
                    "background color" => algorithm.background_color,
                    "color" => algorithm.ambient_color,
                    "dark parameter" => algorithm.dark_parameter,
               )
          end

     tonemapping = Dict(
          "normalization" => a,
          "gamma"=> γ,
          "input average luminosity" => lum,
     )


     data = Dict(
          "scene file" => scenefile,
          "time of start" => time_of_start,
          "png output" => png_output,
          "pfm output" => pfm_output,
          "camera" => dict_camera, 
          "renderer" => dict_renderer,
          "alpha" => α,
          "width" => width,
          "height" => height,
          "tonemapping" => tonemapping,
          "samples per pixel (0 means no antialiasing)" => samples_per_side^2,
          "declared float from Command Line" => declare_float,
          "rendering time (in s)"=> @sprintf("%.3f", rendering_time_s),
     )



     open( join(map(x->x*".", split(png_output,".")[1:end-1])) * "json","w") do f
          JSON.print(f, data, 4)
     end
end


##########################################################################################92



function render(x::(Pair{T1,T2} where {T1,T2})...)
	render( parse_render_settings(  Dict( pair for pair in [x...]) )... )
end

function render(
          scenefile::String,
          renderer::Renderer = FlatRenderer(),
     	camera_type::Union{String, Nothing} = nothing,
		camera_position::Union{Point, Vec, Nothing} = nothing, 
     	α::Float64 = 0., 
     	width::Int64 = 640, 
     	height::Int64 = 480, 
          a::Float64 = 0.18,
          γ::Float64 = 1.27,
          lum::Union{Number, Nothing} = nothing,
     	pfm_output::String = "scene.pfm", 
        	png_output::String = "scene.png",
          samples_per_pixel::Int64 = 0,
		bool_print::Bool = true,
		bool_savepfm::Bool = true,
          declare_float::Union{Dict{String,Float64}, Nothing} = nothing,
          ONLY_FOR_TESTS::Bool = false,
     )

     (bool_print==true) && println("\n\nStarting the image rendering of \"$(scenefile)\"...")

     (ONLY_FOR_TESTS==false) || (return nothing)  
     
     time_of_start = Dates.format(now(), DateFormat("Y-m-d : H:M:S"))
     time_1 = time()

     scene = open(scenefile, "r") do stream
          if isnothing(declare_float)
               inputstream = InputStream(stream, scenefile)
               parse_scene(inputstream)
          else
               inputstream = InputStream(stream, scenefile)
               parse_scene(inputstream, declare_float)
          end
     end

     if typeof(scene.camera) == OrthogonalCamera
          camera_type = "ort"
     elseif typeof(scene.camera) == PerspectiveCamera
          camera_type = "per"
     end

     (bool_print==true) && println("\nReaded and parsed \"$(scenefile)\", now initialize camera and renderer...\n")

     renderer.world = scene.world
     
     samples_per_side = string2rootint64(string(samples_per_pixel))

     # if I have a value from command line I'll use it, else the one from the .txt file
     observer_vec = isnothing(camera_position) ?
          nothing :
          # typeof(camera_position) == Point ?
		# camera_position - Point(0., 0., 0.) :
		# camera_position
          Vec(scene.camera.T * Point(0., 0., 0.))
     
     aspect_ratio = width / height   
     
     
     if isnothing(camera_type) && isnothing(observer_vec) && isnothing(scene.camera) 
          camera = PerspectiveCamera(-1.0, aspect_ratio, rotation_z(deg2rad(α)))

     elseif isnothing(camera_type) && isnothing(observer_vec)
          camera = scene.camera 
          camera.a = aspect_ratio

     elseif isnothing(camera_type) && isnothing(scene.camera) 
          camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec)
          camera = PerspectiveCamera(-1.0, aspect_ratio, camera_tr)

     elseif isnothing(observer_vec) && isnothing(scene.camera) 
          if camera_type == "per"
		     (bool_print==true) && (println("Choosen perspective camera..."))
		     camera = PerspectiveCamera(1.0, aspect_ratio, rotation_z(deg2rad(α)))
	     elseif camera_type == "ort"
		     (bool_print==true) && (println("Choosen orthogonal camera..."))
		     camera = OrthogonalCamera(aspect_ratio, rotation_z(deg2rad(α))) 
	     else
		     throw(ArgumentError("Unknown camera: \"$(camera_type)\""))
	     end

     elseif isnothing(camera_type)
          camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec)
          if typeof(scene.camera) == OrthogonalCamera
               (bool_print==true) && (println("Choosen perspective camera..."))
               camera = OrthogonalCamera(aspect_ratio, camera_tr)
          elseif typeof(scene.camera) == PerspectiveCamera
               (bool_print==true) && (println("Choosen orthogonal camera..."))
               camera = PerspectiveCamera(scene.camera.d, aspect_ratio, camera_tr)
          else
		     throw(ArgumentError("Unknown camera: \"$(camera_type)\""))
	     end

     elseif isnothing(observer_vec)
          if camera_type == "per"
		     (bool_print==true) && (println("Choosen perspective camera..."))
		     camera = PerspectiveCamera(scene.camera.d, aspect_ratio, rotation_z(deg2rad(α)) * scene.camera.T)
	     elseif camera_type == "ort"
		     (bool_print==true) && (println("Choosen orthogonal camera..."))
		     camera = OrthogonalCamera(aspect_ratio, rotation_z(deg2rad(α)) * scene.camera.T) 
	     else
		     throw(ArgumentError("Unknown camera: \"$(camera_type)\""))
	     end

     elseif isnothing(scene.camera)
          camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec)
          if camera_type == "per"
		     (bool_print==true) && (println("Choosen perspective camera..."))
		     camera = PerspectiveCamera(1.0, aspect_ratio, camera_tr)
	     elseif camera_type == "ort"
		     (bool_print==true) && (println("Choosen orthogonal camera..."))
		     camera = OrthogonalCamera(aspect_ratio, camera_tr) 
	     else
		     throw(ArgumentError("Unknown camera: \"$(camera_type)\""))
	     end



     else
          camera_tr = rotation_z(deg2rad(α)) * translation(observer_vec)
          if camera_type == "per"
		     (bool_print==true) && (println("Choosen perspective camera..."))
		     camera = PerspectiveCamera(scene.camera.d, aspect_ratio, camera_tr)
	     elseif camera_type == "ort"
		     (bool_print==true) && (println("Choosen orthogonal camera..."))
		     camera = OrthogonalCamera(aspect_ratio, camera_tr) 
	     else
		     throw(ArgumentError("Unknown camera: \"$(camera_type)\""))
	     end

     end

     if typeof(scene.camera) == OrthogonalCamera
          camera_type = "ort"
     elseif typeof(scene.camera) == PerspectiveCamera
          camera_type = "per"
     end
    
   
     if typeof(renderer) == OnOffRenderer
		(bool_print==true) && (println("Choosen on-off renderer..."))
	elseif typeof(renderer) == FlatRenderer
		(bool_print==true) && (println("Choosen flat renderer..."))
	elseif typeof(renderer) == PathTracer
		(bool_print==true) && (println("Choosen path-tracing renderer..."))
	elseif typeof(renderer) == PointLightRenderer
          (bool_print==true) && (println("Choosen point-light renderer..."))
	else
		throw(ArgumentError("Unknown renderer: \"$(typeof(renderer))\""))
	end

	image = HDRimage(width, height)
	tracer = ImageTracer(image, camera, samples_per_side)

     algorithm = copy(renderer)

     (bool_print==true) && println("\nNow starts the rendering!\n")

     if (bool_print==true)
	     fire_all_rays!(tracer, renderer, (r,c) -> print_progress(r,c,image.height, image.width))
     else
          fire_all_rays!(tracer, renderer) 
     end
	
     (bool_print==true) && println("\nRendering completed! Now saving the files...")

     img = tracer.img

	(bool_savepfm==true) && (open(pfm_output, "w") do outf; write(outf, img); end)
	(bool_print==true) && (println("\nHDR demo image written to \"$(pfm_output)\"!"))

     normalize_image!(img, a, lum)
	clamp_image!(img)
	γ_correction!(img, γ)

	if (typeof(query(png_output)) == File{DataFormat{:UNKNOWN}, String})
		(bool_print==true) && (
			println(
				"File{DataFormat{:UNKNOWN}, String} for \"$(png_output)\"n"*
				"Written as a .png file.\n"
			)
		)
     	Images.save(File{format"PNG"}(png_output), get_matrix(img))
	else
		Images.save(png_output, get_matrix(img))
	end

	(bool_print==true) && (println("\nHDR demo image written to \"$(png_output)\"!"))

     time_2 = time()
     rendering_time_s = time_2 - time_1

     (bool_savepfm==true) && print_JSON_render(
          png_output,
          pfm_output,
          scenefile,
          time_of_start,
          algorithm,
          camera,
          α, 
     	width, 
     	height, 
          samples_per_side,
          declare_float,
          rendering_time_s,
          a, γ, lum,
     )

     name_json = join(map(x->x*".", split(png_output,".")[1:end-1])) * "json"
     (bool_print==true) && println("\nJSON file \"$(name_json)\" correctly created.")
     (bool_print==true) && println("\nEND OF RENDERING\n")
end




"""
	render(
          scenefile::String,
          renderer::Renderer = FlatRenderer(),
     	camera_type::Union{String, Nothing} = nothing,
		camera_position::Union{Point, Vec, Nothing} = nothing, 
     	α::Float64 = 0., 
     	width::Int64 = 640, 
     	height::Int64 = 480, 
          a::Float64 = 0.18,
          γ::Float64 = 1.27,
          lum::Union{Number, Nothing} = nothing,
     	pfm_output::String = "scene.pfm", 
        	png_output::String = "scene.png",
          samples_per_pixel::Int64 = 0,
		bool_print::Bool = true,
		bool_savepfm::Bool = true,
          declare_float::Union{Dict{String,Float64}, Nothing} = nothing,
          ONLY_FOR_TESTS::Bool = false,
          )

	render(x::(Pair{T1,T2} where {T1,T2})...) = 
	     render( parse_render_settings(  Dict( pair for pair in [x...]) )... )

Render the input `scenefile` with the specified options, and creates the following
three files:
- the PFM image (`scene.pfm` is the default name, if none is specified from the command line)
- the LDR image (`scene.png` is the default name, if none is specified from the command line)
- the JSON file (which has the same name of the LDR image and `.json` estention, so 
  `scene.json` is the default name, if none LDR image name is specified from the command line),
  that saves some datas about input commands, rendering time etc.
  

## Arguments

The following input arguments refers to the first method presented in the signature;
it's obviously very uncomfortable to use that method, so it's recommended to take 
advantage of the second one, which allows to write the input values in a dictionary
like syntax with arbitrary order and comfort. See the documentation of  
[`parse_render_settings`](@ref) to learn how to use the keys:

- `renderer::Renderer = FlatRenderer()` : renderer to be used in the rendering, with all
  the settings already setted (exception made for the `world`, that will be overridden
  and created here)

- `camera_type::String = "per"` : set the perspective projection view:
  - `camera_type=="per"` -> set [`PerspectiveCamera`](@ref)  (default value)
  - `camera_type=="ort"`  -> set [`OrthogonalCamera`](@ref)

- `camera_position::Union{Point, Vec} = Point(-1.,0.,0.)` : set the point of observation 
  in (`X`,`Y,`Z`) coordinates, as a `Point`or a `Vec` input object.

- `α::Float64 = 0.` : angle of rotation _*IN RADIANTS*_, relative to the vertical
  (i.e. z) axis with a right-handed rule convention (clockwise rotation for entering (x,y,z)-axis 
  corresponds to a positive input rotation angle)

- `width::Int64 = 640` and `height::Int64 = 480` : pixel dimensions of the demo image;
  they must be both even positive integers.

- `a::Float64 = 0.18` : normalization scale factor for the tone mapping.

- `γ::Float64 = 1.27` : gamma factor for the tone mapping.

- `lum::Union{Number, Nothing} = nothing ` : average luminosity of the image; iIf not specified or equal to 0, 
  it's calculated through [`avg_lum`](@ref)

- `pfm_output::String = "demo.pfm"` : name of the output pfm file

- `png_output::String = "demo.png"` : name of the output LDR file

- `samples_per_pixel::Int64 = 0` : number of rays per pixel to be used (antialiasing);
  it must be a perfect square positive integer (0, 1, 4, 9, ...) and if is set to
  0 (default value) is choosen, no anti-aliasing occurs, and only one pixel-centered 
  ray is fired for each pixel.

- `bool_print::Bool = true` : specifies if the WIP messages of the demo
  function should be printed or not (useful option for [`render_animation`](@ref))

- `bool_savepfm::Bool = true` : bool that specifies if the pfm file should be saved
  or not (useful option for [`render_animation`](@ref))

- `declare_float::Union{Dict{String,Float64}, Nothing} = nothing` : an option (for the 
  command line in particularly) to manually override the values of the float variables in 
  the scene file; each overriden variable name (the key) is associated with its float value 
  (i.e. `declare_float = Dict("var1"=>0.1, "var2"=>2.5)`)

- `ONLY_FOR_TESTS::Bool = false` : it's a bool variable conceived only to
  test the correct behaviour of the renderer for the input arguments; if set to `true`, 
  no rendering is made!

See also: [`Point`](@ref), [`Vec`](@ref), [`Renderer`](@ref) [`OnOffRenderer`](@ref), 
[`FlatRenderer`](@ref), [`PathTracer`](@ref), [`PointLightRenderer`](@ref),
[`parse_render_settings`](@ref)
""" 
render

