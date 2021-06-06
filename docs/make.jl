push!(LOAD_PATH,"../src/")

using Documenter
using Raytracing

Documenter.makedocs(
	root="./",
	source="src",
	build="build",
	clean=false,
	doctest=true,
	modules = [Raytracing],
	sitename = "Raytracer.jl Documentation",
	pages = [
			"Index" => "index.md",
			]
)

deploydocs(repo = "github.com/cosmofico97/Raytracing.git")
