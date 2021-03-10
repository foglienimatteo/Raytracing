module Raytracing

import Colors
import ColorTypes
#import Base.:+, Base.:*, Base.:≈

T = Float64
function Base.:+(x::ColorTypes.RGB{T}, y::ColorTypes.RGB{T})
     ColorTypes.RGB(x.r + y.r, x.g + y.g, x.b + y.b)
end

greet() = println("Hello World!")

end # module
