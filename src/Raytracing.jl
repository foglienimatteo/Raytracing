module Raytracing

using Colors, LinearAlgebra, StaticArrays
using ColorTypes:RGB
#import ColorTypes:RGB  #specificare sempre cosa si importa. In questo caso posso evitare di secificare nella funzione "x::ColorTypes.RGB{T}"
import Base.:+; import Base.:-; import Base.:≈; import Base.:/; import Base.:*
import Base: write, read, print, println;
import LinearAlgebra.:⋅; import LinearAlgebra.:×

export HDRimage, Parameters, Vec, Point, Normal, Transformation, Ray
export translation, scaling, rotation_x, rotation_y, rotation_z, inverse, at

include("Structs.jl")
include("Operations.jl")
include("PrintFunctions.jl")
include("ReadingWriting.jl")
include("ToneMapping.jl")
include("Transformations.jl")
include("ImageTracer.jl")

end  # module