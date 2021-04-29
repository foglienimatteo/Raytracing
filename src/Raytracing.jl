module Raytracing

using Colors, LinearAlgebra, StaticArrays
using ColorTypes:RGB
import Base.:+; import Base.:-; import Base.:≈; import Base.:/; import Base.:*
import Base: write, read, print, println;
import LinearAlgebra.:⋅; import LinearAlgebra.:×

# from Structs.jl
export HDRimage, Parameters, Vec, Point, Normal, Transformation
export Ray, OrthogonalCamera, PerspectiveCamera, ImageTracer
#from Operations.jl
export squared_norm, norm
# from Transformations.jl
export translation, scaling, rotation_x, rotation_y, rotation_z, inverse
# from ImageTracer.jl
export fire_ray, fire_all_rays!, at

include("Structs.jl")
include("Operations.jl")
include("PrintFunctions.jl")
include("ReadingWriting.jl")
include("ToneMapping.jl")
include("Transformations.jl")
include("ImageTracer.jl")

end  # module