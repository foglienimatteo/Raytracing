push!(LOAD_PATH,"../src/")

using Documenter
using Raytracing

Documenter.makedocs(
	root="./",
	source="src",
	build="build",
	clean=false,
	doctest=true,
	format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
	modules = [Raytracing],
	sitename = "Raytracer.jl",
	pages = [
			"Introduction" => "index.md",
			"Demo" => "demo.md",
			"Demo animaiton" => "demo_animation.md",
			],
)

deploydocs(repo = "github.com/cosmofico97/Raytracing.git")
