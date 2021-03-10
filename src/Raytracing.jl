module Raytracing

using Colors  #generico
import ColorTypes:RGB  #specificare sempre cosa si importa. In questo caso posso evitare di secificare nella funzione "x::ColorTypes.RGB{T}"
import Base.:+, Base.:*, Base.:≈

#T = Float64 errato
function Base.:+(x::RGB{T}, y::RGB{T}) where{T} #in questo modo tipo qualsiasi, per specificare: where{T<:real}
     RGB(x.r + y.r, x.g + y.g, x.b + y.b)
end

greet() = println("Hello World!")

end # module
