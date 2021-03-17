module Raytracing

using Colors  #generico
import ColorTypes:RGB  #specificare sempre cosa si importa. In questo caso posso evitare di secificare nella funzione "x::ColorTypes.RGB{T}"
import Base.:+, Base.:*, Base.:-, Base.:≈

#=
#T = Float64 errato
function Base.:+(x::RGB{T}, y::RGB{T}) where{T} #in questo modo tipo qualsiasi, per specificare: where{T<:real}
     RGB(x.r + y.r, x.g + y.g, x.b + y.b)
end
=#

Base.:+(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r + b.r, a.g + b.g, a.b + b.b)
Base.:-(a::RGB{T}, b::RGB{T}) where {T} = RGB(a.r - b.r, a.g - b.g, a.b - b.b)
Base.:*(scalar, c::RGB{T}) where {T} = RGB(scalar*c.r , scalar*c.g, scalar*c.b)
Base.:*(c::RGB{T}, scalar) where {T} = scalar * c
Base.:≈(a::RGB{T}, b::RGB{T}) where {T} = are_close(a.r,b.r) && are_close(a.g,b.g) && are_close(a.b, b.b)
are_close(x,y,epsilon=1e-10) = abs(x-y) < epsilon

struct HDRimage
    width
    heigth
    Color_matrix::RGB{T}[] where {T}

end

end # module
