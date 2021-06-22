push!(LOAD_PATH,"../src/")

using Documenter
using Raytracing

Documenter.makedocs(
	format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
	modules = [Raytracing],
	sitename = "Raytracer.jl",
	pages = [
			"Introduction" => "index.md",
			"Demo" => "demo.md",
			"The Render Function" => "render.md",
			"Interpreter for the Scene File" => "interpreter.md",
			"Base Structs" => "base_structs.md",
			"Reading and Writing PFM files" => "readingwritingpfm.md",
			"BRDFs and Pigments" => "brdfs_and_pigments.md",
			"Cameras" => "cameras.md",
			"Tone Mapping" => "tone_mapping.md",
			"Renderers" => "renderers.md",
			"Transformations" => "transformations.md",
			"Avaiable Shapes" => "shapes.md",
			"Range Tester Functions" => "range_testers.md",
			],
)

deploydocs(repo = "github.com/cosmofico97/Raytracing.git")
