push!(LOAD_PATH,"../src/")

using Documenter
# using Raytracing
# using Pkg
# Pkg.activate(normpath(@__DIR__))

# using Colors, Images, ImageIO, ArgParse, Polynomials, Documenter
# using ColorTypes:RGB
# import FileIO: @format_str, query
# using Raytracing

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
