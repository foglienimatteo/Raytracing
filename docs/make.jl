push!(LOAD_PATH,"../src/")

using Documenter
using Raytracing

Documenter.makedocs(
	format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
	modules = [Raytracing],
	sitename = "Raytracer.jl",
	devurl = "stable",
	pages = [
			"Introduction" => "index.md",
			"Demo" => "demo.md",
			"Demo animaiton" => "demo_animation.md",
			"Base Structs" => "base_structs.md",
			"BRDFs and Pigments" => "brdfs_and_pigments.md",
			"Cameras" => "cameras.md",
			"Tone Mapping" => "tone_mapping.md",
			"Renderers" => "renderers.md",
			"Transformations" => "transformations.md",
			"Plane" => "plane.md",
			"Sphere" => "sphere.md",
			],
)

deploydocs(repo = "github.com/cosmofico97/Raytracing.git")
