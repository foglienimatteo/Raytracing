print(io::IO, v::Vec) = (print(io, "Vec:\t ", v.x, "\t", v.y, "\t", v.z); nothing)
print(v::Vec) = (print(stdout, v); nothing)
println(io::IO,v::Vec) = (print(io, v); print("\n"); nothing)
println(v::Vec) = (println(stdout,v); nothing)

print(io::IO, p::Point) = (print(io, "Point:\t ", p.x, "\t", p.y, "\t", p.z); nothing)
print(p::Point) = (print(stdout, p); nothing)
println(io::IO,p::Point) = (print(io, p); print("\n"); nothing)
println(p::Point) = (println(stdout,p); nothing)

println(c::RGB{T}) where T = println("(", c.r, ", ", c.g, ", ", c.b, ")" )
function println(img::HDRimage, n::Int64=5)
     n>=1 || throw(ArgumentError("not a valid index; $n must be >0"))
     n<=50 || throw(ArgumentError("too big index; $n must be <=50"))

     w=img.width
     h=img.height
     println("HDRImage to be printed")
     println("width = ", w, "\t height = ", h)
     if w*h <= 2*n
          for c in img.rgb_m; println(c); end
     else
          for i in 1:n; println(img.rgb_m[n]);end
          println("...")
          for i in 1:n; println(img.rgb_m[end-n+i]);end
     end
     nothing
end