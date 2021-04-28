print(io::IO, v::Vec) = (print(io, "Vec:\t ", v.x, "\t", v.y, "\t", v.z); nothing)
print(v::Vec) = (print(stdout, v); nothing)
println(v::Vec) = (println(stdout,v); nothing)
println(io::IO,v::Vec) = (print(io, v); print("\n"); nothing)

print(io::IO, p::Point) = (print(io, "Point:\t ", p.x, "\t", p.y, "\t", p.z); nothing)
print(p::Point) = (print(stdout, p); nothing)
println(p::Point) = (println(stdout,p); nothing)
println(io::IO,p::Point) = (print(io, p); print("\n"); nothing)

println(c::RGB{T}) where T = println("(", c.r, ", ", c.g, ", ", c.b, ")" )
function println(img::HDRimage)
     println("width = ", img.width, "\t height = ", img.height)
     for c in img.rgb_m
          println(c)
     end 
end